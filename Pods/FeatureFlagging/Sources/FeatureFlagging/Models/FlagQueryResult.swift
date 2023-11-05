//
//  File.swift
//  
//
//  Created by Dan Esrey on 4/1/20.
//

import Foundation

public struct FlagQueryResult: Codable {
    public let flagId: String
    public let flagName: String?
    public let enabled: Bool
    public var warnings: [Warning]
    public let userId: String?
    public let userIdType: String?
}

