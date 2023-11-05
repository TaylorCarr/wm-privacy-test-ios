//
//  RemoteConfig.swift
//  psm-ios
//
//  Created by Nirvan Nagar on 4/9/20.
//  Copyright © 2020 WarnerMedia. All rights reserved.
//

import Foundation

/*
 * Making most of the fields nullable and vars for now until this model is finalized.
 */
struct RemoteConfig: Codable, Equatable {
    let appId: String
    let platform: String
    let property: String
    let environment: String
    let privacyRules: [PrivacyRules]
    
    static func ==(lhs: RemoteConfig, rhs: RemoteConfig) -> Bool {
        return (lhs.appId == rhs.appId)
            && (lhs.platform == rhs.platform)
            && (lhs.property == rhs.property)
            && (lhs.environment == rhs.environment)
    }
}

struct PrivacyRules: Codable {
    let rules: [String: PrivacyRule]
}

struct PrivacyRule: Codable, Equatable {
    let USP: USP
}

struct USP: Codable, Equatable {
    let spec: String
    let opportunity: String
    let optOut: String
    let LSPA: String
}
