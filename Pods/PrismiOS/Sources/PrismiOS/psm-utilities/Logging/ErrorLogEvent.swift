//
//  File.swift
//  
//
//  Created by Nirvan Nagar on 5/16/20.
//

import Foundation

struct ErrorLogEvent: Codable {
    let message: ErrorLogEventMessage
}

struct ErrorLogEventMessage: Codable {
    let eventType: String
    let method: String
    let WMUKID: String
    let brand: String
    let platform: String
    let error: Bool
    let errorMessage: String
    let flagName: String?
    let enabled: Bool?
    let subBrand: String
}
