//
//  File.swift
//  
//
//  Created by Dan Esrey on 4/21/20.
//

import Foundation


@objc public class ClientConfiguration: NSObject {
    @objc public var userId: String?
    @objc public var configUrl: String
    @objc public var targetingProperties: [String: String] = [:]
    @objc public var configPollingEnabled = true
    @objc public var configPollingInterval: Double = 60
    
    @objc public init(userId: String?,
                configUrl: String,
                targetingProperties: [String: String] = [:],
                configPollingEnabled: Bool = true,
                configPollingInterval: Double = 60) {
        self.userId = userId
        self.configUrl = configUrl
        self.targetingProperties = targetingProperties
        self.configPollingEnabled = configPollingEnabled
        self.configPollingInterval = configPollingInterval
    }
}
