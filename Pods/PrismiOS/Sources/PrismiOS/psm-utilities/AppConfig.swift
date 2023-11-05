//
//  AppConfig.swift
//  
//
//  Created by Nirvan Nagar on 4/21/20.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import Foundation
import FeatureFlagging

struct AppConfig {
    
    let psmApp: PsmApp
    
    init(psmApp: PsmApp) {
        self.psmApp = psmApp
    }
    
    var environment: PsmEnvironment {
        get {
            return psmApp.environment
        }
    }
    
    var remoteConfigEndpoint: String {
        get {
            return "https://prismconfig.wmcdp.io"
        }
    }
    
    var featureFlagConfigEndpoint: String {
        get {
            switch environment {
            case .DEV:
                return "https://wmff.warnermediacdn.com/psm_dev_full.json"
            case .TEST:
                return "https://wmff.warnermediacdn.com/psm_qa_full.json"
            case .PROD:
                return "https://wmff.warnermediacdn.com/psm_prod_full.json"
            }
        }
    }
    
    var receiveEndpoint: String {
        get {
            switch environment {
            case .DEV:
                return "https://dev.receive.wmcdp.io/v1/reg"
            case .TEST:
                return "https://test.receive.wmcdp.io/v1/reg"
            case .PROD:
                return "https://receive.wmcdp.io/v1/reg"
            }
        }
    }
    
    var errorLoggingEndpoint: String {
        get {
            switch environment {
            case .DEV:
                return "https://dev.logs.psm.wmcdp.io"
            case .TEST:
                return "https://dev.logs.psm.wmcdp.io"
            case .PROD:
                return "https://logs.psm.wmcdp.io"
            }
        }
    }
    
    var householdIdEndpoint: String {
        get {
            switch environment {
            case .DEV:
                return "https://dev.psm.wmcdp.io/v1/resolve"
            case .TEST:
                return "https://test.psm.wmcdp.io/v1/resolve"
            case .PROD:
                return "https://receive.psm.io/v1/resolve"
            }
        }
    }
    
    func getFeatureFlagFallbackConfig() throws -> FlagConfiguration {
        var data: Data?
        
        switch environment {
        case .DEV:
            data = DevFeatureFlagFallbackConfig.value.data(using: .utf8)
        case .TEST:
            data = TestFeatureFlagFallbackConfig.value.data(using: .utf8)
        case .PROD:
            data = ProdFeatureFlagFallbackConfig.value.data(using: .utf8)
        }
        
        guard let fallbackConfigData = data else {
            throw PsmError(message: "Could not convert the json string for the feature flag fallback config to a `Data` type.")
        }
        
        do {
            return try JSONDecoder().decode(FlagConfiguration.self, from: fallbackConfigData)
        } catch {
            throw PsmError(message: "The feaure flag fallback config file could not be decoded. Error: \(error.localizedDescription)")
        }
    }
}

