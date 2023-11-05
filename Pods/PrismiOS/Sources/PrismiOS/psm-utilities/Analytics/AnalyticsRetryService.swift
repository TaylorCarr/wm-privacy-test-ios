//
//  AnalyticsRetryService.swift
//  
//
//  Created by Nirvan Nagar on 6/11/20.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import Foundation

class AnalyticsRetryService {
    
    private let network: NetworkHelper
    private let userDefaults: UserDefaultsManager
    private let loggingService: LoggingService
    private let appConfig: AppConfig
    private let supportedRetryEventKeys: [PsmUserDefaultsKeys]
    
    init(network: NetworkHelper, userDefaults: UserDefaultsManager, loggingService: LoggingService, appConfig: AppConfig) {
        self.network = network
        self.userDefaults = userDefaults
        self.loggingService = loggingService
        self.appConfig = appConfig
        
        supportedRetryEventKeys = [
            .HouseholdIdResolutionEventNeedsRetry,
            .ReceiveAnalyticsEventNeedsRetry
        ]
    }
    
    func addEventForRetry<T: AnalyticsEvent>(event: T, endpoint: String, key: PsmUserDefaultsKeys) {
        let retryEvent = RetryEvent<T>(event: event, endpoint: endpoint)
        
        do {
            let data = try JSONEncoder().encode(retryEvent)
            userDefaults.setValue(data, forKey: key)
        } catch {
            loggingService.error(
                message: "Could not encode \(retryEvent) of type \(RetryEvent.self)",
                logInfo: LogInfo(eventType: "Analytics", method: "saveEventForRetry")
            )
        }
    }
    
    func clearEventForRetry(key: PsmUserDefaultsKeys) {
        userDefaults.removeValue(forKey: key)
    }
    
    func retryAllEvents() {
        for key in supportedRetryEventKeys {
            if let retriableEvent = getRetriableEvent(key: key) {
                retryEvent(retriableEvent: retriableEvent, key: key) { (data, error) in
                    self.handleRetryCallback(retriableEvent: retriableEvent, key: key, error: error)
                }
            }
        }
    }
    
    private func getRetriableEvent<T: AnalyticsEvent>(key: PsmUserDefaultsKeys) -> RetryEvent<T>? {
        guard let data = userDefaults.getObjectValue(forKey: key) as? Data else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(RetryEvent<T>.self, from: data)
        } catch {
            loggingService.error(
                message: "Error decoding \(RetryEvent<T>.self) for key \(key)",
                logInfo: LogInfo(eventType: "Analytics", method: "getRetriableEvent")
            )
            
            return nil
        }
    }
    
    private func retryEvent<T: AnalyticsEvent>(retriableEvent: RetryEvent<T>, key: PsmUserDefaultsKeys,
                            completion: @escaping (_ data: Data?, _ error: String?) -> ()) {
        
        let event = retriableEvent.event
        let endpoint = retriableEvent.endpoint
        
        var body: Data!
        do {
            body = try JSONEncoder().encode(event)
        } catch {
            loggingService.error(
                message: "Error when encoding \(event): \(error.localizedDescription)",
                logInfo: LogInfo(eventType: "Analytics", method: "retryEvent")
            )
            
            return
        }
        
        network.post(endpoint, body: body) { (data, error) in
            completion(data, error)
        }
    }
    
    private func handleRetryCallback<T: AnalyticsEvent>(retriableEvent: RetryEvent<T>, key: PsmUserDefaultsKeys, error: String?) {
        if let error = error {
            self.loggingService.info(message: "Error when retrying event \(retriableEvent.event): \(error)")
        } else {
            self.loggingService.debug(message: "Successfully retried event \(retriableEvent.event) and sent to the endpoint \(retriableEvent.endpoint).")
            
            self.userDefaults.removeValue(forKey: key)
        }
    }
    
}

