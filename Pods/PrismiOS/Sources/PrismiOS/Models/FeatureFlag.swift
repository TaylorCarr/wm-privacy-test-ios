//
//  FeatureFlag.swift
//  
//
//  Created by Dan Esrey on 5/7/20.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import Foundation
import FeatureFlagging

protocol FeatureFlagDelegate: AnyObject {
    func featureDisabled(featureId: String) -> Bool
    var featureFlag: FeatureFlag { get }
}

public class FeatureFlag {
    
    let context: ClientConfiguration
    let featureFlagClient: FeatureFlagClient
    let analyticsService: AnalyticsService
    let loggingService: LoggingService
    let appConfig: AppConfig
    
    init(context: ClientConfiguration,
         analyticsService: AnalyticsService,
         loggingService: LoggingService,
         appConfig: AppConfig
    ) throws {
        self.context = context
        self.analyticsService = analyticsService
        self.loggingService = loggingService
        self.appConfig = appConfig
        
        let fallbackConfig = try appConfig.getFeatureFlagFallbackConfig()
        featureFlagClient = FlagClientFactory.shared.createClientAsyncRemote(clientConfig: context, fallbackConfig: fallbackConfig)
    }
    
    func featureIsDisabled(featureId: String, disabledOnFailure: Bool = false) -> Bool {
        do {
            let queryResult = try featureFlagClient.queryFeatureFlag(flagId: featureId)
            
            return !queryResult.enabled
        } catch {
            loggingService.error(
                message: "Error when querying for feature flag with id \(featureId). Error: \(error.localizedDescription)",
                logInfo: LogInfo(eventType: "Feature", method: "featureIsDisabled", flagName: featureId, flagEnabled: disabledOnFailure)
            )
            return disabledOnFailure
        }
    }
    
    func trackAllFlags() {
        do {
            let allFlags = try featureFlagClient.queryAllFeatureFlags()
            
            loggingService.debug(message: "Feature flags loaded: \(allFlags)")
            
            if let flag = allFlags.first {
                if !flag.warnings.isEmpty {
                    loggingService.info(message: "Feature Flag Warnings: \(flag.warnings)")
                }
            } else {
                // All flags is empty if this code block is executed
                loggingService.error(message: "No feature flags available.",
                                     logInfo: LogInfo(eventType: EventType.featureFlagging.rawValue, method: "trackAllFlags")
                )
            }
            
        } catch {
            loggingService.error(
                message: "Could not query all the feature flags for sending feature analytics events because of the following error: \(error.localizedDescription)",
                logInfo: LogInfo(eventType: EventType.featureFlagging.rawValue, method: "trackAllFlags")
            )
        }
    }
    
    func getAllFeatureFlags() -> [FlagQueryResult] {
        do {
            let allFlags = try featureFlagClient.queryAllFeatureFlags()
            
            loggingService.debug(message: "Feature flags loaded: \(allFlags)")
            
            if let flag = allFlags.first {
                if !flag.warnings.isEmpty {
                    loggingService.info(message: "Feature Flag Warnings: \(flag.warnings)")
                }
            } else {
                // All flags is empty if this code block is executed
                loggingService.error(message: "No feature flags available.",
                                     logInfo: LogInfo(eventType: EventType.featureFlagging.rawValue, method: "getAllFeatureFlags"))
            }
            
            return allFlags
            
        } catch {
            loggingService.error(
                message: "Could not query all the feature flags for sending feature analytics events because of the following error: \(error.localizedDescription)",
                logInfo: LogInfo(eventType: EventType.featureFlagging.rawValue, method: "getAllFeatureFlags"))
            return []
        }
    }
    
}

extension FeatureFlag {
    static let POLLING_INTERVAL: Double = 10
    static let DOPPLER_CONSENT_UPDATE = "doppler-consent-update"
    static let BDSDK = "BDSDK"
    static let ID_RESOLVE = "idresolve"
    static let DOPPLER_IDENTITY_APPLOAD = "doppler-identity-appload"
    static let DOPPLER_IDENTITY_APPFOREGROUND = "doppler-identity-appforeground"
    static let DOPPLER_IDENTITY_APPBACKGROUND = "doppler-identity-appbackground"
    static let WMUKID = "WMUKID"
    static let GET_SET_CONSENT_STATE = "getSetConsentState"
    static let TELEMETRY = "telemetry"
}

extension FeatureFlagDelegate {
    public func featureDisabled(featureId: String) -> Bool {
        return self.featureFlag.featureIsDisabled(featureId: featureId)
    }
}
