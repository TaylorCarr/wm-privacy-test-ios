//
//  File.swift
//  
//
//  Created by Dan Esrey on 4/1/20.
//

import Foundation

public struct Flag: Codable {
    let name: String
    let id: String
    let type: String
    let enabled: Bool
    let cohorts: [Cohort]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case id
        case type
        case enabled = "defaultValue"
        case cohorts
    }
}
