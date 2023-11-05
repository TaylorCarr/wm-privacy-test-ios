//
//  File.swift
//  
//
//  Created by Nirvan Nagar on 4/24/20.
//

import Foundation

@objc public class Location: NSObject, Codable {
    @objc public let country: String
    
    @objc public init(country: String) {
        self.country = country
    }
    
    @objc public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Location else {
            return false
        }
        
        return country == rhs.country
    }
}
