//
//  File.swift
//  
//
//  Created by Nirvan Nagar on 5/16/20.
//

import Foundation

struct LogInfo {
    let eventType: String
    let method: String
    let flagName: String?
    let flagEnabled: Bool?
    
    init(eventType: String, method: String, flagName: String?, flagEnabled: Bool?) {
        self.eventType = eventType
        self.method = method
        self.flagName = flagName
        self.flagEnabled = flagEnabled
    }
    
    init(eventType: String, method: String) {
        self.init(eventType: eventType, method: method, flagName: nil, flagEnabled: nil)
    }
}
