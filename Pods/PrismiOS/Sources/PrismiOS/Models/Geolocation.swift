//
//  Geolocation.swift
//  psm-ios
//
//  Created by Brock Davis on 4/8/20.
//  Copyright © 2020 WarnerMedia. All rights reserved.
//

import Foundation

struct Geolocation: Codable {
    let continent: String
    let continentName: String
    let country: String
    let countryAlpha2: String
    let countryAlpha3: String
    let states: [State]
    let longitude: String
    let latitude: String
    let ipAddress: String
    let asn: ASN
    
    enum CodingKeys: String, CodingKey {
        case continent
        case continentName
        case country
        case countryAlpha2 = "country_alpha2"
        case countryAlpha3 = "country_alpha3"
        case states
        case longitude = "lon"
        case latitude = "lat"
        case ipAddress = "ip_address"
        case asn
    }
}

struct State: Codable {
    let state: String
    let cities: [String]
    let zipcodes: [String]
    let counties: [String]
}

struct ASN: Codable {
    let id: String
    let name: String
}
