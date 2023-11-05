//
//  ParameterEncoder.swift
//  psm-ios
//
//  Created by Brock Davis on 4/8/20.
//  Copyright © 2020 WarnerMedia. All rights reserved.
//

import Foundation

protocol ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: [String: Any]) throws
}

struct JSONParameterEncoder: ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: [String: Any]) throws {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.httpBody = jsonData
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw NetworkError.encodingFailed
        }
    }
}

enum NetworkError: String, Error {
    case encodingFailed = "\nParameter encoding failed."
}
