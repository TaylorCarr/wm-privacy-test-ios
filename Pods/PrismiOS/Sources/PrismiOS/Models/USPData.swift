//
//  File.swift
//  
//
//  Created by Nirvan Nagar on 4/28/20.
//

import Foundation

@objc public class USPData: NSObject {
    @objc public let version: Int
    @objc public let usp: String
    
    @objc public init(version: Int, usp: String) {
        self.version = version
        self.usp = usp
    }
    
    static func ==(lhs: USPData, rhs: USPData) -> Bool {
        return lhs.version == rhs.version && lhs.usp == rhs.usp
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? USPData else {
            return false
        }
        
        return (version == rhs.version) && (usp == rhs.usp)
    }
}
