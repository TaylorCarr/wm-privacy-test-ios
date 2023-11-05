//
//  PsmBdsdk.swift
//
//
//  Created by SS079m on 2/9/21.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import Foundation
import FeatureFlagging
#if canImport(UIKit)
import BrightDiagnostics
#endif
import CoreLocation

public class PsmBdsdk: NSObject {
    
    private let userDefaults: UserDefaultsManager
    internal let featureFlag: FeatureFlag
    private let loggingService: LoggingService
    private let privacySdk: PsmPrivacySdk
    private let idSdk: PsmIdSdk
    private let timeInterval: TimeInterval

#if canImport(UIKit)
    private let locationManager = CLLocationManager()
    private var authorizationStatusForLocationManager : CLAuthorizationStatus {
        if #available(iOS 14.0, tvOS 14, *) {
            return locationManager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }
#endif
    
    var bdsdkReasons: BdsdkReasons = [BdsdkReasons(rawValue: BdsdkReasons.NOT_INITIALIZED.rawValue)]

    init(
        userDefaults: UserDefaultsManager,
        featureFlag: FeatureFlag,
        privacySdk: PsmPrivacySdk,
        idSdk: PsmIdSdk,
        loggingService: LoggingService,
        timeInterval: TimeInterval = BdsdkConstants.timeInterval
    ) {
        self.userDefaults = userDefaults
        self.featureFlag = featureFlag
        self.privacySdk = privacySdk
        self.idSdk = idSdk
        self.loggingService = loggingService
        self.timeInterval = timeInterval
        super.init()
    }
    
    /**
    Enables the BrightDiagnostics and starts collecting metrics
    */
    @available(iOS 12.0, tvOS 12.0, *)
    public func initializeBdsdk() {
        guard !bdsdkReasons.isEmpty else { // if it's already running, do not start BDSDK again
            return
        }
        guard enable() else {
            return
        }
        
#if canImport(UIKit)
        let wmUkId = idSdk.getWMUKID()
        let configuration = BRTConfiguration.default()
            .withDataAdvertisingInfo(true)
            .withDataLocationInfo(true)
            .withDeviceId(wmUkId)
            .withTimeInterval(timeInterval)

        BrightDiagnostics.enabled = true
        BrightDiagnostics.configure(with: configuration) { (configurationApplied) in
            guard configurationApplied else {
                self.bdsdkReasons = [BdsdkReasons(rawValue: BdsdkReasons.NOT_RUNNING_BDSDK_INTERNAL_ERROR.rawValue)]
                self.loggingService.error(
                    message: "BDSDK Internal Error",
                    logInfo: LogInfo(eventType: EventType.bdsdk.rawValue, method: "startBdsdk"))
                return
            }
            
             // do the first collection after the BrightDiagnostics has started
            BrightDiagnostics.collect()
        }
#endif
    }

    @available(iOS 12.0, tvOS 12.0, *)
    private func enable() -> Bool {
        var isEnabled = true
        bdsdkReasons = [BdsdkReasons(rawValue: 0)]
        if !isBDSDKFlagEnabled() {
            isEnabled = false
        }
        if !isDataCollectionAllowed() {
            isEnabled = false
        }
        if !isSupportedLocation() {
            isEnabled = false
        }
        if !isLocationAuthorized() {
            isEnabled = false
        }
        return isEnabled
    }

    /**
     Disables the BrightDiagnostics
    */
    @available(iOS 12.0, tvOS 12.0, *)
    public func disable() {
#if canImport(UIKit)
        if !isLocationAuthorized() {
            bdsdkReasons = bdsdkReasons.union(BdsdkReasons.NOT_RUNNING_LOCATION_PERMISSION_DENIED)
        } else {
            bdsdkReasons = bdsdkReasons.union(BdsdkReasons.STOPPED_FROM_API)
        }
        DispatchQueue.global().async {
            BrightDiagnostics.enabled = false
        }
#endif
    }
    
    /**
    The user has changed his consent, if it's not allowed the BrightDiagnostics will be disabled
    */
    func consentDidChange() {
        if #available(iOS 12.0, tvOS 12.0, *) {
            let isDataAllowed = isDataCollectionAllowed()
            if !isDataAllowed, bdsdkReasons.isEmpty {
                bdsdkReasons = bdsdkReasons.union(BdsdkReasons.NOT_RUNNING_DATA_SALE_DENIED)
                disable()
            } else if isDataAllowed {
                initializeBdsdk()
            }
        }
    }
    
    /**
    Update the wmUkId in  BrightDiagnostics
    */
    func wmUkIdDidChange() {
#if canImport(UIKit)
        if let wmUkId = idSdk.getWMUKID() {
            if bdsdkReasons.isEmpty {
                BrightDiagnostics.deviceID = wmUkId
            }
        }
#endif
    }
    
    // Checks User has given the consent
    private func isDataCollectionAllowed() -> Bool {
        let isDataNotAllowed = privacySdk.getUSPBool()
        if isDataNotAllowed {
            bdsdkReasons = bdsdkReasons.union(BdsdkReasons.NOT_RUNNING_DATA_SALE_DENIED)
        } else {
            bdsdkReasons.remove(BdsdkReasons.NOT_RUNNING_DATA_SALE_DENIED)
        }
        return !isDataNotAllowed
    }
    
    // Checks BDSDK Feature Flag Enabled
    private func isBDSDKFlagEnabled() -> Bool {
        let bdsdkFlagStatus = featureFlag.featureIsDisabled(featureId: FeatureFlag.BDSDK)
        if bdsdkFlagStatus {
            bdsdkReasons = bdsdkReasons.union(BdsdkReasons.NOT_RUNNING_FF_DISABLED)
        } else {
            bdsdkReasons.remove(BdsdkReasons.NOT_RUNNING_FF_DISABLED)
        }
        return !bdsdkFlagStatus
    }
    
    // Checks location is in US
    private func isSupportedLocation() -> Bool {
        let isNotSupportedLocation = (privacySdk.getUSPString() == PrivacyUtils.ccpaUnsupportedLocation)
        if isNotSupportedLocation {
            bdsdkReasons = bdsdkReasons.union(BdsdkReasons.NOT_RUNNING_OUTSIDE_US)
        } else {
            bdsdkReasons.remove(BdsdkReasons.NOT_RUNNING_OUTSIDE_US)
        }
        return !isNotSupportedLocation
    }
    
    // Checks user granted location authorization
    private func isLocationAuthorized() -> Bool {
#if canImport(UIKit)
        let isLocationAuthorized = authorizationStatusForLocationManager == .authorizedAlways ||
            authorizationStatusForLocationManager == .authorizedWhenInUse
        if !isLocationAuthorized {
            bdsdkReasons = bdsdkReasons.union(BdsdkReasons.NOT_RUNNING_LOCATION_PERMISSION_DENIED)
        } else {
            bdsdkReasons.remove(BdsdkReasons.NOT_RUNNING_LOCATION_PERMISSION_DENIED)
        }
        return isLocationAuthorized
#else
        return false
#endif
    }

}
