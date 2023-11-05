//
//  File.swift
//  
//
//  Created by Nirvan Nagar on 4/28/20.
//

import Foundation

@objc public class USPObject: NSObject, Codable {
    @objc public let usp: String
    @objc public let comScore: Int
    
    @objc public init(usp: String, comScore: Int) {
        self.usp = usp
        self.comScore = comScore
    }
    
    static func ==(lhs: USPObject, rhs: USPObject) -> Bool {
        return lhs.usp == rhs.usp && lhs.comScore == rhs.comScore
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? USPObject else {
            return false
        }
        
        return (usp == rhs.usp) && (comScore == rhs.comScore)
    }
}
