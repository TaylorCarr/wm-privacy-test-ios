//
//  File.swift
//  
//
//  Created by Dan Esrey on 4/28/20.
//

import Foundation

protocol ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

enum ParameterEncoding {
    
    case urlEncoding
    
    func encode(urlRequest: inout URLRequest,
                       urlParameters: Parameters?) throws {
        do {
            switch self {
            case .urlEncoding:
                guard let urlParameters = urlParameters else { return }
                try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)
            }
        } catch {
            throw error
        }
    }
}
