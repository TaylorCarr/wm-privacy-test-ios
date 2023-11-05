//
//  File.swift
//  
//
//  Created by Dan Esrey on 5/12/20.
//

import Foundation

struct LoadedConfiguraton: Codable {
    var source: FlagConfigurationSource
    var config: FlagConfiguration
}

enum FlagConfigurationSource: String, Codable {
    case fallback
    case cached
    case remote
}
