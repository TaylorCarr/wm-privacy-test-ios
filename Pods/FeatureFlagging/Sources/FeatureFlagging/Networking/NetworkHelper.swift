//
//  File.swift
//  
//
//  Created by Dan Esrey on 4/21/20.
//

import Foundation

class NetworkHelper {
    
    static let shared = NetworkHelper()
        
    init() { }
    
    private var task: URLSessionTask?
    
    func get(_ urlString: String, version: Int? = nil, completion: @escaping (_ data: Data?, _ error: String?) -> ()) throws {
        guard let url = URL(string: urlString) else {
            completion(nil, "URL malformed")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        if let tag = FeatureFlagStorage.shared.get(key: .etag) {
            request.addValue(tag, forHTTPHeaderField: "If-None-Match")
        }
        guard let version = version else {
            self.send(request, completion: completion)
            return
        }

        let parameters: Parameters = ["version": version]
        do {
            try configureParameters(bodyEncoding: .urlEncoding, urlParameters: parameters, request: &request)
        } catch {
            throw error
        }
        send(request, completion: completion)
    }
    
    func send(_ request: URLRequest, completion: @escaping (_ data: Data?, _ error: String?) -> ()) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error.debugDescription)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if let etag = response.allHeaderFields["Etag"] as? String {
                    FeatureFlagStorage.shared.set(key: .etag, value: etag)
                }
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
    
    func configureParameters(bodyEncoding: ParameterEncoding,
                                     urlParameters: Parameters?,
                                     request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    urlParameters: urlParameters)
        } catch {
            throw error
        }
    }
    
    func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        
        switch response.statusCode {
        case 200...299:
            return .success
        case 304:
            return .failure(NetworkResponse.noData.rawValue)
        case 404:
            return .failure(NetworkResponse.notFound.rawValue)
        case 501...599:
            return .failure(NetworkResponse.badRequest.rawValue)
        default:
            return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
