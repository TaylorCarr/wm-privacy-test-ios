//
//  Library.swift
//  
//
//  Created by Ungureanu Lucian on 29/04/2021.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

struct Library: Codable, Equatable {
    let name: String
    let version: String
    let initConfig: InitConfig
}

struct InitConfig: Codable, Equatable {
    let appId: String
    let platform: String
    let companyName: String
    let brand: String
    let subBrand: String
    let productName: String
    let countryCode: String?
    let psmEnvironment: PsmEnvironment?
}

