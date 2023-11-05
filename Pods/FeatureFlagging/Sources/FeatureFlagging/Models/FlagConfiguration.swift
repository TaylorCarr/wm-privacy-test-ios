//
//  File.swift
//  
//
//  Created by Dan Esrey on 4/8/20.
//

import Foundation

public struct FlagConfiguration: Codable {
    public var featureFlagLibraryVersion: String?
    public var flags: [Flag]

}
