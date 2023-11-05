//
//  PsmApp.swift
//  
//
//  Created by Nirvan Nagar on 5/15/20.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import Foundation

@objc public class PsmApp: NSObject, Codable {
    @objc public let appId: String
    @objc public let brand: String
    @objc public let productName: String
    @objc public let environment: PsmEnvironment
    @objc public let location: String?
    @objc public let subBrand: String
    
    @objc public init(appId: String, brand: String, productName: String, environment: PsmEnvironment, location: String?, subBrand: String) {
        self.appId = appId
        self.brand = brand
        self.productName = productName
        self.environment = environment
        self.location = location
        self.subBrand = subBrand
    }
}
