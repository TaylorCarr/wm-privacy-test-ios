//
//  PsmSdk.swift
//  psm-ios
//
//  Created by Nirvan Nagar on 4/8/20.
//  Copyright © 2020 WarnerMedia. All rights reserved.
//

import FeatureFlagging
import Foundation

// Adding the @objc attribute and NSObject dependency because clients
// might need to interop swift with objective-c.
@objc public class PsmSdk: NSObject, FeatureFlagDelegate {
    private let privacy: PsmPrivacySdk
    private let id: PsmIdSdk
    private let householdId: PsmHouseholdIdResolution
    let featureFlag: FeatureFlag
    private let context: ClientConfiguration
    private let loggingService: LoggingService
    private let analyticsRetryService: AnalyticsRetryService
    private let bdsdk: PsmBdsdk

    @objc public init(psmApp: PsmApp) throws {
        if let location = psmApp.location {
            let locationSanitized = location.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)

            if locationSanitized == "" || (locationSanitized.count > 2 || locationSanitized.count < 2) {
                throw PsmError(message: "Expected a 2-character country code but got \(location)")
            }
        }

        let appConfig = AppConfig(psmApp: psmApp)

        let targetingProperties = [
            "brand": psmApp.brand,
            "platform": DeviceInfoService.shared.getDeviceInfo().osName,
            "subBrand": psmApp.subBrand,
        ]

        context = ClientConfiguration(
            userId: nil,
            configUrl: appConfig.featureFlagConfigEndpoint,
            targetingProperties: targetingProperties,
            configPollingEnabled: true,
            configPollingInterval: FeatureFlag.POLLING_INTERVAL
        )

        loggingService = LoggingService(
            network: NetworkHelper.shared,
            userDefaults: UserDefaultsManager.shared,
            deviceInfoService: DeviceInfoService.shared,
            appConfig: appConfig
        )

        analyticsRetryService = AnalyticsRetryService(
            network: NetworkHelper.shared,
            userDefaults: UserDefaultsManager.shared,
            loggingService: loggingService,
            appConfig: appConfig
        )

        let analyticsService = AnalyticsService(
            network: NetworkHelper.shared,
            userDefaults: UserDefaultsManager.shared,
            deviceInfoService: DeviceInfoService.shared,
            loggingService: loggingService,
            delegate: nil,
            appConfig: appConfig,
            analyticsRetryService: analyticsRetryService
        )

        featureFlag = try FeatureFlag(
            context: context,
            analyticsService: analyticsService,
            loggingService: loggingService,
            appConfig: appConfig
        )

        privacy = PsmPrivacySdk(
            userDefaults: UserDefaultsManager.shared,
            analytics: analyticsService,
            featureFlag: featureFlag,
            loggingService: loggingService
        )

        id = PsmIdSdk(
            userDefaults: UserDefaultsManager.shared,
            network: NetworkHelper.shared,
            analyticsService: analyticsService,
            featureFlag: featureFlag,
            loggingService: loggingService
        )

        householdId = PsmHouseholdIdResolution(
            userDefaults: UserDefaultsManager.shared,
            analyticsService: analyticsService,
            featureFlag: featureFlag,
            loggingService: loggingService
        )

        bdsdk = PsmBdsdk(
            userDefaults: UserDefaultsManager.shared,
            featureFlag: featureFlag,
            privacySdk: privacy,
            idSdk: id,
            loggingService: loggingService
        )

        super.init()

        analyticsService.delegate = self
        featureFlag.analyticsService.delegate = self

        finishInitialization(psmApp: psmApp, completion: nil)
    }

    @objc public init(psmApp: PsmApp, completion: @escaping (_ sdk: PsmSdk?, _ error: String?) -> Void) throws {
        if let location = psmApp.location {
            let locationSanitized = location.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)

            if locationSanitized == "" || (locationSanitized.count > 2 || locationSanitized.count < 2) {
                throw PsmError(message: "Expected a 2-character country code but got \(location)")
            }
        }

        let appConfig = AppConfig(psmApp: psmApp)

        let targetingProperties = [
            "brand": psmApp.brand,
            "platform": DeviceInfoService.shared.getDeviceInfo().osName,
            "subBrand": psmApp.subBrand,
        ]

        context = ClientConfiguration(
            userId: nil,
            configUrl: appConfig.featureFlagConfigEndpoint,
            targetingProperties: targetingProperties,
            configPollingEnabled: true,
            configPollingInterval: FeatureFlag.POLLING_INTERVAL
        )

        loggingService = LoggingService(
            network: NetworkHelper.shared,
            userDefaults: UserDefaultsManager.shared,
            deviceInfoService: DeviceInfoService.shared,
            appConfig: appConfig
        )

        analyticsRetryService = AnalyticsRetryService(
            network: NetworkHelper.shared,
            userDefaults: UserDefaultsManager.shared,
            loggingService: loggingService,
            appConfig: appConfig
        )

        let analyticsService = AnalyticsService(
            network: NetworkHelper.shared,
            userDefaults: UserDefaultsManager.shared,
            deviceInfoService: DeviceInfoService.shared,
            loggingService: loggingService,
            delegate: nil,
            appConfig: appConfig,
            analyticsRetryService: analyticsRetryService
        )

        featureFlag = try FeatureFlag(
            context: context,
            analyticsService: analyticsService,
            loggingService: loggingService,
            appConfig: appConfig
        )

        privacy = PsmPrivacySdk(
            userDefaults: UserDefaultsManager.shared,
            analytics: analyticsService,
            featureFlag: featureFlag,
            loggingService: loggingService
        )

        id = PsmIdSdk(
            userDefaults: UserDefaultsManager.shared,
            network: NetworkHelper.shared,
            analyticsService: analyticsService,
            featureFlag: featureFlag,
            loggingService: loggingService
        )

        bdsdk = PsmBdsdk(
            userDefaults: UserDefaultsManager.shared,
            featureFlag: featureFlag,
            privacySdk: privacy,
            idSdk: id,
            loggingService: loggingService
        )

        householdId = PsmHouseholdIdResolution(
            userDefaults: UserDefaultsManager.shared,
            analyticsService: analyticsService,
            featureFlag: featureFlag,
            loggingService: loggingService
        )

        super.init()

        analyticsService.delegate = self
        featureFlag.analyticsService.delegate = self

        finishInitialization(psmApp: psmApp) { error in
            if error != nil {
                completion(nil, error)
            } else {
                completion(self, nil)
            }
        }
    }

    internal func geolocationManager() -> GeolocationProtocol {
        return GeolocationManager()
    }

    private func finishInitialization(psmApp: PsmApp, completion: ((_ error: String?) -> Void)?) {
        savePsmApp(psmApp: psmApp)

        geolocationManager().getCountry { country, error in
            guard let geoLocationCountry = country else {
                if let psmLocation = psmApp.location {
                    let locationSanitized = self.sanitizeString(input: psmLocation)
                    self.storeCountryInfoForLaterUse(locationSanitized)
                    completion?(nil)

                } else {
                    self.loggingService.error(
                        message: "getGeolocation failed to return valid data, with error: \(error ?? "NA") and there is no valid country from the psmApp",
                        logInfo: LogInfo(eventType: "init", method: "finishInitialization")
                    )
                    // If the geo location call failed and there is no valid country from the psmApp,
                    // we are going to not store a default privacy rule (since we don't know which rule to give).
                    completion?(error)
                }
                return
            }

            self.storeCountryInfoForLaterUse(geoLocationCountry)
            completion?(nil)
        }
    }

    private func savePsmApp(psmApp: PsmApp) {
        do {
            let data = try JSONEncoder().encode(psmApp)
            UserDefaultsManager.shared.setValue(data, forKey: .PsmApp)
        } catch {
            // This should never happen in production, since we have control on the data model for `AppInfo`
            // and it would be caught in testing.
            loggingService.error(
                message: "Error when encoding the PsmApp object \(psmApp) with error \(error.localizedDescription)",
                logInfo: LogInfo(eventType: "init", method: "savePsmApp")
            )
        }
    }

    private func storeCountryInfoForLaterUse(_ country: String) {
        saveLocation(location: Location(country: country))
        setupWmUkIdIfNecessary(location: country)
        verifyHouseholdIds(location: country)

        featureFlag.trackAllFlags()

        analyticsRetryService.retryAllEvents()
    }

    private func setupWmUkIdIfNecessary(location: String) {
        if PrivacyUtils.isSupportedLocation(location: location) {
            id.setupApploadEvent()
            id.setupForegroundEvent()
//            self.id.setupBackgroundEvent()
            bdsdk.wmUkIdDidChange()
        }
    }

    private func verifyHouseholdIds(location: String) {
        if PrivacyUtils.isSupportedLocation(location: location) {
            if householdId.verifyIdsFromToday() == false {
                householdId.updateHouseholdIds()
            }
        }
    }

    private func saveLocation(location: Location) {
        do {
            let data = try JSONEncoder().encode(location)
            UserDefaultsManager.shared.setValue(data, forKey: .Location)
        } catch {
            // This should never happen in production, since we have control on the data model for `Location`
            // and it would be caught in testing.
            loggingService.error(message: "Error when encoding the Location object \(location) with error \(error.localizedDescription)",
                                 logInfo: LogInfo(eventType: EventType.privacy.rawValue, method: "saveLocation"))
        }
    }

    private func sanitizeString(input: String) -> String {
        return input.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @objc public func getWMUKID() -> String? {
        return id.getWMUKID()
    }

    @objc public func getUSPData() -> USPData? {
        return privacy.getUSPData()
    }

    @objc public func setUSPData(isOptedOutOfDataSharing: Bool) {
        privacy.setUSPData(optOutOfDataSharing: isOptedOutOfDataSharing)
        bdsdk.consentDidChange()
    }

    @objc public func ccpaShareData() {
        privacy.ccpaShareData()
        bdsdk.consentDidChange()
    }

    @objc public func ccpaDoNotShareData() {
        privacy.ccpaDoNotShareData()
        bdsdk.consentDidChange()
    }

    @objc public func getUSPObject() -> USPObject? {
        return privacy.getUSPObject()
    }

    @objc public func getUSPString() -> String? {
        return privacy.getUSPString()
    }

    @objc public func getUSPBool() -> Bool {
        return privacy.getUSPBool()
    }

    @objc public func getUSPInt() -> Int {
        return privacy.getUSPInt()
    }

    @objc public func __uspapi() {
        return privacy.__uspapi()
    }

    @objc public func getLocation() -> Location? {
        return privacy.getLocation()
    }

    @objc public func featureDisabled(featureId: String) -> Bool {
        return featureFlag.featureIsDisabled(featureId: featureId)
    }

    /**
      Starts the BDSDK (collect data and upload a pre-defined set of metrics)
     */
    @objc public func bdsdkEnable() {
        if #available(iOS 12.0, tvOS 12.0, *) {
            bdsdk.initializeBdsdk()
        }
    }

    /**
     Stops the BDSDK (to not collect data anymore)
     */
    @objc public func bdsdkDisable() {
        if #available(iOS 12.0, tvOS 12.0, *) {
            bdsdk.disable()
        }
    }

    /**
      * Indicates the current state of bdsdk.
       *
       * @return The current set flags. '0' if the bdsdk is running or a combination of
       * [PsmBdSdk.NOT_RUNNING_LOCATION_PERMISSION_DENIED], [PsmBdSdk.NOT_RUNNING_FF_DISABLED],
       * [PsmBdSdk.NOT_RUNNING_DATA_SALE_DENIED], or [PsmBdSdk.NOT_RUNNING_OUTSIDE_US]
     */
    @objc public func getBdsdkRunningStatus() -> Int {
        if #available(iOS 12.0, tvOS 12.0, *) {
            return bdsdk.bdsdkReasons.rawValue
        } else {
            return BdsdkReasons.NOT_RUNNING_BDSDK_VERSION_ERROR.rawValue
        }
    }
}
