//
//  File.swift
//  
//
//  Created by Dan Esrey on 4/21/20.
//

import Foundation

enum NetworkResponse: String {
    case success
    case badRequest = "Bad request"
    case noData = "Response returned with no data"
    case notFound = "Requested resource not found"
    case failed = "Network request failed"
}

enum Result<String> {
    case success
    case failure(String)
}
