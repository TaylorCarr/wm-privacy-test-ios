//
//  File.swift
//
//
//  Created by Dan Esrey on 5/5/20.
//

import Foundation

struct FeatureIndexProvider {
    init() {}

    static let shared = FeatureIndexProvider()

    func processHash(hash: String) throws -> String {
        let firstTen = String(hash.prefix(10))
        let parsedInt = Int(firstTen, radix: 16)
        if let intForString = parsedInt {
            let stringFromParsedInt = String(intForString)
            return String(stringFromParsedInt.suffix(2))
        } else {
            throw FeatureFlagClient.FFClientError.failedHashProcessing
        }
    }

    func create256Hash(from userId: String, with featureId: String) -> String {
        let combined = userId + featureId
        return combined.sha256()
    }

    func getUserFeatureIndex(from userId: String, with featureId: String) throws -> String {
        let hash = create256Hash(from: userId, with: featureId)
        return try processHash(hash: hash)
    }
}
