//
//  PsmPrivacySdk.swift
//  psm-ios
//
//  Created by Nirvan Nagar on 4/8/20.
//  Copyright © 2020 WarnerMedia. All rights reserved.
//

import Foundation

// Adding the @objc attribute and NSObject dependency because clients
// might need to interop swift with objective-c.
public class PsmPrivacySdk: NSObject, FeatureFlagDelegate {
    
    private let userDefaults: UserDefaultsManager
    private let analytics: AnalyticsService
    private let loggingService: LoggingService
    var featureFlag: FeatureFlag

    init(userDefaults: UserDefaultsManager, analytics: AnalyticsService, featureFlag: FeatureFlag, loggingService: LoggingService) {
        self.userDefaults = userDefaults
        self.analytics = analytics
        self.featureFlag = featureFlag
        self.loggingService = loggingService
        
        super.init()
        
        analytics.delegate = self
        featureFlag.analyticsService.delegate = self
    }
    
    public func isPrivacyFeatureEnabled() -> Bool {
       return !featureFlag.featureIsDisabled(featureId: FeatureFlag.DOPPLER_CONSENT_UPDATE)
    }
    
    public func getUSPData() -> USPData? {
        guard !featureFlag.featureIsDisabled(featureId: FeatureFlag.DOPPLER_CONSENT_UPDATE),
            let location = getLocationInfo() else {
            return nil
        }

        let usp = getUspStringHelper(location: location)
        
        let index = usp.index(usp.startIndex, offsetBy: 0)
        let version = usp[index].wholeNumberValue

        if let version = version {
            return USPData(version: version, usp: usp)
        } else {
            // Could not parse the version number, return nil.
            // This would only happen if a dev accidentally made the version
            // a non-number; which would be caught with the unit tests.
            // This could never happen in prod.
            return nil
        }
    }
    
    public func setUSPData(optOutOfDataSharing: Bool) {
        guard !featureFlag.featureIsDisabled(featureId: FeatureFlag.DOPPLER_CONSENT_UPDATE) else {
            return
        }
        
        guard let location = getLocationInfo(), PrivacyUtils.isSupportedLocation(location: location.country) else {
            return
        }
        
        if optOutOfDataSharing {
            ccpaDoNotShareData()
        } else {
            ccpaShareData()
        }
    }
    
    public func ccpaShareData() {
        guard !featureFlag.featureIsDisabled(featureId: FeatureFlag.DOPPLER_CONSENT_UPDATE) else {
            return
        }
        
        guard let location = getLocationInfo(), PrivacyUtils.isSupportedLocation(location: location.country) else {
            return
        }
        
        persistConsentState(newConsentValue: PrivacyUtils.ccpaAllowDataSale)
    }
    

    public func ccpaDoNotShareData() {
        guard !featureFlag.featureIsDisabled(featureId: FeatureFlag.DOPPLER_CONSENT_UPDATE) else {
            return
        }
        
        guard let location = getLocationInfo(), PrivacyUtils.isSupportedLocation(location: location.country) else {
            return
        }
        
        persistConsentState(newConsentValue: PrivacyUtils.ccpaDoNotAllowDataSale)
    }
    
    private func persistConsentState(newConsentValue: String) {
        let savedConsentValue = userDefaults.getStringValue(forKey: .USPString)
        
        let defaultUspInfo = PrivacyUtils.getDefaultUSPInfo()
        
        if (savedConsentValue == nil && newConsentValue == defaultUspInfo.usp) || newConsentValue == savedConsentValue {
            if savedConsentValue == nil {
                userDefaults.setValue(newConsentValue, forKey: .USPString)
            }
            return
        }
        
        userDefaults.setValue(newConsentValue, forKey: .USPString)
        verifyAdIdStatus()
        
        analytics.sendReceiveEvent(type: ReceiveEventType.privacy.rawValue,
                                   name: ReceiveEventName.consentUpdate.rawValue,
                                   allFeatureFlags: featureFlag.getAllFeatureFlags())
    }
    
    public func getUSPObject() -> USPObject? {
        guard !featureFlag.featureIsDisabled(featureId: FeatureFlag.DOPPLER_CONSENT_UPDATE),
            let location = getLocationInfo() else {
            return nil
        }

        let usp = getUspStringHelper(location: location)
        return USPObject(usp: usp, comScore: PrivacyUtils.getComScoreForUsp(usp: usp))
    }
    
    public func getUSPString() -> String? {
        guard !featureFlag.featureIsDisabled(featureId: FeatureFlag.DOPPLER_CONSENT_UPDATE),
            let location = getLocationInfo() else {
            return nil
        }
        
        return getUspStringHelper(location: location)
    }
    
    private func getUspStringHelper(location: Location) -> String {
        if PrivacyUtils.isSupportedLocation(location: location.country) {
            return userDefaults.getStringValue(forKey: .USPString) ?? PrivacyUtils.ccpaAllowDataSale
        } else {
            return PrivacyUtils.ccpaUnsupportedLocation
        }
    }
    
    /*
     * Returns true if the user has opted out of selling their data and false if they have not opted out.
     */
    public func getUSPBool() -> Bool {
        guard !featureFlag.featureIsDisabled(featureId: FeatureFlag.DOPPLER_CONSENT_UPDATE),
            let location = getLocationInfo() else {
            return PrivacyUtils.getDefaultUSPInfo().uspBool
        }
        
        let usp = getUspStringHelper(location: location)
        
        return usp == PrivacyUtils.ccpaDoNotAllowDataSale
    }
    
    /*
     * Returns 1 if the user has opted out of selling their data and 0 if they have not opted out.
     */
    public func getUSPInt() -> Int {
        guard !featureFlag.featureIsDisabled(featureId: FeatureFlag.DOPPLER_CONSENT_UPDATE),
            let location = getLocationInfo() else {
            return PrivacyUtils.getDefaultUSPInfo().uspInt
        }

        let usp = getUspStringHelper(location: location)
        
        if usp == PrivacyUtils.ccpaDoNotAllowDataSale {
            return 1
        } else {
            return 0
        }
    }
    
    public func __uspapi() {
        // TODO
    }
    
    public func getLocation() -> Location? {
        return getLocationInfo()
    }
    
    private func getLocationInfo() -> Location? {
        guard let data = UserDefaultsManager.shared.getObjectValue(forKey: .Location) as? Data else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(Location.self, from: data)
        } catch {
            loggingService.error(
                message: "Unable to decode the Location data due to the following error: \(error.localizedDescription)",
                logInfo: LogInfo(eventType: EventType.privacy.rawValue, method: "getLocationInfo"))
            return nil
        }
    }
    
    private func verifyAdIdStatus() {
        let id = PsmIdSdk(userDefaults: self.userDefaults,
                          network: NetworkHelper.shared,
                          analyticsService: self.analytics,
                          featureFlag: self.featureFlag,
                          loggingService: self.loggingService)
        let _ = id.getWMUKID()
    }
}
