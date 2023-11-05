//
//  PsmIdSdk.swift
//  psm-ios
//
//  Created by Nirvan Nagar on 4/8/20.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import AdSupport

// Adding the @objc attribute and NSObject dependency because clients
// might need to interop swift with objective-c.
public class PsmIdSdk: NSObject, FeatureFlagDelegate {
    
    private let userDefaults: UserDefaultsManager
    private let network: NetworkHelper
    private let analyticsService: AnalyticsService
    internal let featureFlag: FeatureFlag
    private let loggingService: LoggingService
    
    private var advertisingIdentifier: String {
        ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    private var savedAdId: String? {
        userDefaults.getStringValue(forKey: .AdvertisingIdentifier)
    }
    
    init(
        userDefaults: UserDefaultsManager,
        network: NetworkHelper,
        analyticsService: AnalyticsService,
        featureFlag: FeatureFlag,
        loggingService: LoggingService
    ) {
        
        self.userDefaults = userDefaults
        self.network = network
        self.analyticsService = analyticsService
        self.featureFlag = featureFlag
        self.loggingService = loggingService
        
        super.init()
        
        analyticsService.delegate = self
        featureFlag.analyticsService.delegate = self
    }
    
    public func getWMUKID() -> String? {
        guard !featureFlag.featureIsDisabled(featureId: FeatureFlag.DOPPLER_IDENTITY_APPLOAD) else {
            return nil
        }
        
        guard let location = getLocationInfo(), PrivacyUtils.isSupportedLocation(location: location.country) else {
            return nil
        }

        guard let wmUkId = userDefaults.getStringValue(forKey: .WMUKID) else {
            return nil
        }
        
        if savedAdId == nil {
            saveAdvertisingIdToDefaults()
        }

        return wmUkId
    }
    
    @discardableResult public func setupApploadEvent() -> String? {
        guard !featureFlag.featureIsDisabled(featureId: FeatureFlag.DOPPLER_IDENTITY_APPLOAD) else {
            return nil
        }
        
        guard let location = getLocationInfo(), PrivacyUtils.isSupportedLocation(location: location.country) else {
            return nil
        }
        
        let wmukId = initializeWMUKID()
        
        // the AppLoad event will be performed only once, when the app was loaded
        analyticsService.sendReceiveEvent(type: ReceiveEventType.identity.rawValue,
                                          name: ReceiveEventName.appLoad.rawValue,
                                          allFeatureFlags: featureFlag.getAllFeatureFlags())
        return wmukId
    }
    
    @discardableResult private func initializeWMUKID() -> String {
        // check to see whether any IDFA is stored in userDefaults
        if savedAdId == nil {
            // if no IDFA in userDefaults, try to save IDFA to userDefaults
            saveAdvertisingIdToDefaults()
        } else if let validAdId = savedAdId, validAdId != advertisingIdentifier {
            // if IDFA has changed, save or delete the IDFA
            saveAdvertisingIdToDefaults()
        }
        
        var wmukId = ""
        if let savedWmukId = userDefaults.getStringValue(forKey: .WMUKID) {
            wmukId = savedWmukId
            
        } else { // the WMUKID is saved only one time in user defaults, it should NOT be changed anymore
            wmukId = UUID().uuidString.lowercased()
            userDefaults.setValue(wmukId, forKey: .WMUKID)
            loggingService.info(message: "WMUKID was saved: \(wmukId)")
        }
        return wmukId
    }
    
    @discardableResult public func setupForegroundEvent() -> String? {
        guard !featureFlag.featureIsDisabled(featureId: FeatureFlag.DOPPLER_IDENTITY_APPFOREGROUND) else {
            return nil
        }
        
        guard let location = getLocationInfo(), PrivacyUtils.isSupportedLocation(location: location.country) else {
            return nil
        }
        
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        #endif
        
        return initializeWMUKID()
    }
    
    @discardableResult public func setupBackgroundEvent() -> String? {
        guard !featureFlag.featureIsDisabled(featureId: FeatureFlag.DOPPLER_IDENTITY_APPBACKGROUND) else {
            return nil
        }
        
        guard let location = getLocationInfo(), PrivacyUtils.isSupportedLocation(location: location.country) else {
            return nil
        }
        
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        #endif
        
        return initializeWMUKID()
    }
    
    
    @objc private func appEnteredForeground() {
        analyticsService.sendReceiveEvent(type: ReceiveEventType.identity.rawValue,
                                          name: ReceiveEventName.appForeground.rawValue,
                                          allFeatureFlags: featureFlag.getAllFeatureFlags())
    }
    
    @objc private func appEnteredBackground() {
        analyticsService.sendReceiveEvent(type: ReceiveEventType.identity.rawValue,
                                          name: ReceiveEventName.appBackground.rawValue,
                                          allFeatureFlags: featureFlag.getAllFeatureFlags())
    }
    
    private func saveAdvertisingIdToDefaults() {
        let adIdentifier = advertisingIdentifier
        guard adIdentifier != "00000000-0000-0000-0000-000000000000" else {
            // the user changed to not allow tracking, so the previous saved IDFA has to be deleted
            userDefaults.removeValue(forKey: .AdvertisingIdentifier)
            return
        }
        
        userDefaults.setValue(adIdentifier, forKey: .AdvertisingIdentifier)
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
}
