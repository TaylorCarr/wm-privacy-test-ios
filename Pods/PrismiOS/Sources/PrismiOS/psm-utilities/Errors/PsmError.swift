//
//  File.swift
//  
//
//  Created by Nirvan Nagar on 5/4/20.
//

import Foundation

@objc public class PsmError: NSObject, Error {
    @objc public let message: String
    
    init(message: String) {
        self.message = message
    }
}
