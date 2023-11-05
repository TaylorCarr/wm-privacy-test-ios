//
//  NetworkHelper.swift
//  psm-ios
//
//  Created by Brock Davis on 4/8/20.
//  Copyright © 2020 WarnerMedia. All rights reserved.
//

import Foundation

typealias NetworkHelperCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()

class NetworkHelper {
    
    static let shared = NetworkHelper()
    
    init() { }
    
    private var task: URLSessionTask?
    
    func get(_ urlString: String, completion: @escaping (_ data: Data?, _ error: String?) -> ()) {
        guard let url = URL(string: urlString) else {
            completion(nil, "URL malformed")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        send(request, completion: completion)
    }
    
    func post(_ urlString: String, body: Data, completion: @escaping (_ data: Data?, _ error: String?) -> ()) {
        guard let url = URL(string: urlString) else {
            completion(nil, "URL malformed")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        send(request, completion: completion)
    }
    
    private func send(_ request: URLRequest, completion: @escaping (_ data: Data?, _ error: String?) -> ()) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error.debugDescription)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                
                switch result {
                    case .success:
                        completion(data, nil)
                    case .failure(let networkFailure):
                        completion(nil, networkFailure)
                }
            }
        }
        
        task.resume()
    }
    
    private func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        
        switch response.statusCode {
            case 200...299:
                return .success
            case 404:
                return .failure(NetworkResponse.notFound.rawValue)
            case 501...599:
                return .failure(NetworkResponse.badRequest.rawValue)
            default:
                return .failure(NetworkResponse.failed.rawValue)
        }
    }
}

