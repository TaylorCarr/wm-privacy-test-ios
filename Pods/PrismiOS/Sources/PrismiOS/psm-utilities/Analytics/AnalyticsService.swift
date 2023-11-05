//
//  AnalyticsService.swift
//  
//
//  Created by Nirvan Nagar on 4/28/20.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import Foundation
import FeatureFlagging

class AnalyticsService {
    weak var delegate: FeatureFlagDelegate?
    
    private let network: NetworkHelper
    private let userDefaults: UserDefaultsManager
    private let deviceInfoService: DeviceInfoService
    private let loggingService: LoggingService
    private let appConfig: AppConfig
    private let retryService: AnalyticsRetryService
    
    init(network: NetworkHelper,
         userDefaults: UserDefaultsManager,
         deviceInfoService: DeviceInfoService,
         loggingService: LoggingService,
         delegate: FeatureFlagDelegate?,
         appConfig: AppConfig,
         analyticsRetryService: AnalyticsRetryService
    ) {
        self.network = network
        self.userDefaults = userDefaults
        self.deviceInfoService = deviceInfoService
        self.loggingService = loggingService
        self.delegate = delegate
        self.appConfig = appConfig
        self.retryService = analyticsRetryService
    }
    
    func sendReceiveEvent(type: String, name: String, allFeatureFlags: [FlagQueryResult]) {
        let eventData = getRequiredDataForEvent()
        let geolocation = getGeolocation()
        
        let appId = eventData.psmApp?.appId ?? AnalyticsServiceConstants.UNKNOWN
        let environment = eventData.psmApp?.environment
        let device = deviceInfoService.getDeviceInfo()
        let platform = device.osName
        let companyName = AnalyticsServiceConstants.COMPANY_NAME
        let brand = eventData.psmApp?.brand ?? AnalyticsServiceConstants.UNKNOWN
        let subBrand = eventData.psmApp?.subBrand ?? AnalyticsServiceConstants.UNKNOWN
        let productName = eventData.psmApp?.productName ?? AnalyticsServiceConstants.UNKNOWN
        let wmukId = eventData.wmUkId ?? AnalyticsServiceConstants.UNKNOWN
        let eventId = UUID().uuidString.lowercased()
        let timestamp = getTimestampAsString()
        
        let receiveIds = getReceiveIdsObject()
        let clientResolvedIp = geolocation?.ipAddress ?? AnalyticsServiceConstants.UNKNOWN
        let city = geolocation?.states.first?.cities.first
        let state = geolocation?.states.first?.state
        let zip = geolocation?.states.first?.zipcodes.first
        let country = geolocation?.country
        let receiveLocation = ReceiveLocation.init(city: city, state: state, country: country, zip: zip,
                                                   timezone: TimeZone.current.identifier,
                                                   locale: Locale.current.identifier,
                                                   language: Locale.preferredLanguages.first)
        
        let uspString = userDefaults.getStringValue(forKey: .USPString) ?? AnalyticsServiceConstants.UNKNOWN
        let trackingStatus = OSAdvertisingTracking.getTrackingStatus()
        let consentProperties = ConsentProperties(uspString: uspString, trackingAuthorizationStatus: trackingStatus)
        let eventProperties = EventProperties(doNotSell: isOptOut(), featureFlagValues: allFeatureFlags)
        
        let library = Library(name: AnalyticsServiceConstants.LIBRARY_NAME, version: PsmLibrary.version, initConfig: .init(appId: appId, platform: platform, companyName: companyName, brand: brand, subBrand: subBrand, productName: productName, countryCode: country, psmEnvironment: environment))
        
        let receiveEvent = ReceiveAnalyticsEvent(appId: appId, platform: platform, companyName: companyName, brand: brand, subBrand: subBrand, productName: productName,
                                                 wmukid: wmukId, eventId: eventId, eventTimestamp: timestamp, sentAtTimestamp: timestamp,
                                                 eventType: type, eventName: name,
                                                 ids: receiveIds, device: device, clientResolvedIp: clientResolvedIp, location: receiveLocation,
                                                 consentProperties: consentProperties, library: library, eventProperties: eventProperties)
        loggingService.debug(message: "ID event: \(receiveEvent)")
        
        var requestBody: Data!
        do {
            requestBody = try JSONEncoder().encode(receiveEvent)
        } catch {
            loggingService.error(
                message: "Error when encoding \(ReceiveAnalyticsEvent.self) for event \(receiveEvent): \(error.localizedDescription)",
                logInfo: LogInfo(eventType: EventType.id.rawValue, method: "sendIdEvent")
            )
            retryService.addEventForRetry(event: receiveEvent, endpoint: appConfig.receiveEndpoint, key: .ReceiveAnalyticsEventNeedsRetry)
            return
        }
        
        network.post(appConfig.receiveEndpoint, body: requestBody) { (data, error) in
            if let error = error {
                self.loggingService.error(message: error, logInfo: LogInfo(eventType: EventType.id.rawValue, method: "sendIdEvent"))
                self.retryService.addEventForRetry(event: receiveEvent, endpoint: self.appConfig.receiveEndpoint, key: .ReceiveAnalyticsEventNeedsRetry)
                
            } else {
                self.loggingService.debug(message: "Successfully sent ID event to \(self.appConfig.receiveEndpoint).")
                self.retryService.clearEventForRetry(key: .ReceiveAnalyticsEventNeedsRetry)
            }
        }
    }
            
    func sendHouseholdIdEvent(_ completion: @escaping (_ data: Data?) -> ()) {
        let eventData = getRequiredDataForEvent()
        let wmukId = eventData.wmUkId ?? AnalyticsServiceConstants.UNKNOWN
        let householdIds = getHouseholdIdsObject()
        
        let event = HouseholdIdEvent(wmukid: wmukId, ids: householdIds)
        let eventList = [event]
        loggingService.debug(message: "HouseholdId event: \(eventList)")
        
        var requestData: Data!
        do {
            requestData = try JSONEncoder().encode(event)
        } catch {
            loggingService.error(message: "Error when encoding \(HouseholdIdEvent.self) for event \(event): \(error.localizedDescription)",
                                 logInfo: LogInfo(eventType: EventType.householdId.rawValue, method: "sendHouseholdIdEvent"))
            retryService.addEventForRetry(event: event, endpoint: appConfig.householdIdEndpoint, key: .HouseholdIdResolutionEventNeedsRetry)
            completion(nil)
            return
        }
        
        network.post(appConfig.householdIdEndpoint, body: requestData) { (data, error) in
            if let error = error {
                self.loggingService.error(message: "Error receiving data for the HOUSEHOLD ID endpoint ( \(self.appConfig.householdIdEndpoint) ): \(error).",
                                          logInfo: LogInfo(eventType: EventType.householdId.rawValue, method: "sendHouseholdIdEvent"))
                self.retryService.addEventForRetry(event: event, endpoint: self.appConfig.householdIdEndpoint, key: .HouseholdIdResolutionEventNeedsRetry)
                completion(nil)
                
            } else {
                self.loggingService.debug(message: "Successfully sent HOUSEHOLD ID event to \(self.appConfig.householdIdEndpoint).")
                self.retryService.clearEventForRetry(key: .HouseholdIdResolutionEventNeedsRetry)
                completion(data)
            }
        }
    }
    
    private func getRequiredDataForEvent() -> (wmUkId: String?, psmApp: PsmApp?) {
        let wmUkId = userDefaults.getStringValue(forKey: .WMUKID)
        
        guard let psmAppData = userDefaults.getObjectValue(forKey: .PsmApp) as? Data else {
            // This would never happen since the PsmApp should always be saved on the init of Psm
            loggingService.error(
                message: "Expected 'PsmApp' to already have been set.",
                logInfo: LogInfo(eventType: "analytics", method: "getRequiredDataForEvent")
            )
            return (wmUkId, nil)
        }
        
        do {
            let psmApp = try JSONDecoder().decode(PsmApp.self, from: psmAppData)
            return (wmUkId, psmApp)
        } catch {
            // This would never happen since the PsmApp should always be saved on the init of Psm
            loggingService.error(
                message: "Could not decode 'PsmApp' after reading from UserDefaults",
                logInfo: LogInfo(eventType: "analytics", method: "getRequiredDataForEvent")
            )
            return (wmUkId, nil)
        }
    }
    
    private func getHouseholdIdsObject() -> HouseholdIds {
        let kruxId = getKruxId()
        #if os(tvOS)
        return HouseholdIds(kruxid: kruxId)
        #else
        return HouseholdIds(kruxid: kruxId, maid: kruxId)
        #endif
    }
    
    private func getReceiveIdsObject() -> ReceiveIds {
        let kruxId = getKruxId()
        let wmhhid = userDefaults.getStringValue(forKey: .WMHHID)
        let wminid = userDefaults.getStringValue(forKey: .WMINID)
        let vendorId = deviceInfoService.getIdentifierForVendor()
        #if os(tvOS)
        return ReceiveIds(kruxid: kruxId, ctvid: kruxId, wmhhid: wmhhid, wminid: wminid, vendorid: vendorId)
        #else
        return ReceiveIds(kruxid: kruxId, maid: kruxId, wmhhid: wmhhid, wminid: wminid, vendorid: vendorId)
        #endif
    }
        
    private func getKruxId() -> String? {
        return UserDefaultsManager.shared.getStringValue(forKey: .AdvertisingIdentifier)
    }
    
    private func getGeolocation() -> Geolocation? {
        guard let data = UserDefaultsManager.shared.getObjectValue(forKey: .Geolocation) as? Data else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(Geolocation.self, from: data)
        } catch {
            loggingService.error(
                message: "Could not decode 'Geolocation' after reading from UserDefaults. Error: \(error.localizedDescription)",
                logInfo: LogInfo(eventType: "analytics", method: "getGeolocation")
            )
            return nil
        }
    }
    
    private func isOptOut() -> Bool {
        guard let usp = userDefaults.getStringValue(forKey: .USPString) else {
            return PrivacyUtils.getDefaultUSPInfo().uspBool
        }
        
        return usp == PrivacyUtils.ccpaDoNotAllowDataSale
    }
    
    private func getTimestampAsString() -> String {
        let date = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter.string(from: date)
    }
}
