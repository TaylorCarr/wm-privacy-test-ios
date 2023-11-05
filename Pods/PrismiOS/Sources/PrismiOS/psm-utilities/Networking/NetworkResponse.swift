//
//  NetworkResponse.swift
//  psm-ios
//
//  Created by Brock Davis on 4/8/20.
//  Copyright © 2020 WarnerMedia. All rights reserved.
//

import Foundation

enum NetworkResponse: String {
    case success
    case badRequest = "Bad request"
    case noData = "Response returned with no data"
    case notFound = "Requested resource not found"
    case failed = "Network request failed"
    
}

public enum Result<String> {
    case success
    case failure(String)
}

