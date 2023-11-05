//
//  Geolocator.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 4/17/20.
//  Copyright © 2020 T Carr. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: Geolocation

struct geoLocation: Codable {
    var `as`: String
    var city: String
    var country: String
    var countryCode: String
    var isp: String
    var lat: Float
    var lon: Float
    var org: String
    var query: String
    var region: String
    var regionName: String
    var status: String
    var timezone: String
    var zip: String
}

struct geoLocation2: Codable {
    var continentName: String
    var lon: String
    var country: String
    var country_alpha3: String
    var country_alpha2: String
    var continent: String
    var states: [states]
    var proxy: String?
    var lat: String
    var ip_address: String
//    var org:String
//    var query:String
//    var region:String
//    var regionName:String
//    var status:String
//    var timezone:String
//    var zip:String
}

struct states: Codable {
    var state: String
    var cities: [String]
    var counties: [String]
    var zipcodes: [String]
}

// Makes a call to a 3rd party API that read's the user's IP address and returns a JSON of their information
func getIpLocation(completion: @escaping (geoLocation2?, Error?) -> Void) {
    var url: URL?
//        url = URL(string: "http://ip-api.com/json/")! // Default
    url = URL(string: "https://geo.ngtv.io/locate")! // Turner GeoLocation API
//        url = URL(string: "http://ip-api.com/json/81.169.181.179")! // GDPR
//        url = URL(string: "http://ip-api.com/json/66.146.235.122")! // Dallas
    var request = URLRequest(url: url!)
    request.httpMethod = "GET"
    let decoder = JSONDecoder()

    URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, _, error in
        if let content = data {
            do {
                let response = try decoder.decode(geoLocation2.self, from: content)
                consoleLog(log: "JSON response: \(response)")
                completion(response, error)
            } catch {
                consoleLog(log: "Geolocation JSON response error: \(error)")
                completion(nil, nil)
            }
        } else {
            consoleLog(log: "Get IP Else Error: \(String(describing: error))")
            completion(nil, error)
        }
    }).resume()
}

func sdkInit() -> String {
    let EEACountries: [String] = ["Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czechia", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", "Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Poland", "Portugal", "Romania", "Slovakia", "Slovenia", "Spain", "Sweden", "United Kingdom"]

    let EEACountryAbbreviations: [String] = ["AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT", "RO", "SK", "SI", "ES", "SE", "GB"]

    let EEACountryMap: [String: String] = ["AT": "Austria", "BE": "Belgium", "BG": "Bulgaria", "HR": "Croatia", "CY": "Cyprus", "CZ": "Czechia", "DK": "Denmark", "EE": "Estonia", "FI": "Finland", "FR": "France", "DE": "Germany", "GR": "Greece", "HU": "Hungary", "IE": "Ireland", "IT": "Italy", "LV": "Latvia", "LT": "Lithuania", "LU": "Luxembourg", "MT": "Malta", "NL": "Netherlands", "PL": "Poland", "PT": "Portugal", "RO": "Romania", "SK": "Slovakia", "SI": "Slovenia", "ES": "Spain", "SE": "Sweden", "GB": "United Kingdom"]

    var returnInt = 2
    let group = DispatchGroup()
    group.enter()

    DispatchQueue.global().async {
        getIpLocation(completion: { output, _ in
            print("getIpLocation() response below")
            print(output?.states)
            print("Country: \(output?.country)")
//            if (output?.states[0].state == "CA") {
            if output?.country == "US" {
                locationCache.setObject("United States", forKey: "location")
                returnInt = 0
                group.leave()
            }
//            else if (EEACountries.contains(output?.country ?? "")){
            else if EEACountryMap[output?.country ?? "Undefined"] != nil {
                locationCache.setObject(NSString(string: EEACountryMap[output?.country ?? "Unavailable"] ?? "Unavailable"), forKey: "location")
                locationCache.setObject(NSString(string: "EEA"), forKey: "region")
                returnInt = 1
                group.leave()
            } else {
                locationCache.setObject(NSString(string: output?.country ?? "Unavailable"), forKey: "location")
                returnInt = 2
                group.leave()
            }
        })
    }

    group.wait()
    if returnInt == 0 {
        consoleLog(log: "Returned CA")
        return "CA"
    } else if returnInt == 1 {
        return "EEA"
    } else {
        return "default"
    }
}

// var output: geoLocation?
var output: geoLocation2?

// Based on the user's location, settings will either show CCPA, GDPR or Default options
func findAppropriateSettings(returnInt: Int) -> AnyView {
    let EEACountries: [String] = ["Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czechia", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", "Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Poland", "Portugal", "Romania", "Slovakia", "Slovenia", "Spain", "Sweden", "United Kingdom"]

    let EEACountryAbbreviations: [String] = ["AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT", "RO", "SK", "SI", "ES", "SE", "GB"]

    let EEACountryMap: [String: String] = ["AT": "Austria", "BE": "Belgium", "BG": "Bulgaria", "HR": "Croatia", "CY": "Cyprus", "CZ": "Czechia", "DK": "Denmark", "EE": "Estonia", "FI": "Finland", "FR": "France", "DE": "Germany", "GR": "Greece", "HU": "Hungary", "IE": "Ireland", "IT": "Italy", "LV": "Latvia", "LT": "Lithuania", "LU": "Luxembourg", "MT": "Malta", "NL": "Netherlands", "PL": "Poland", "PT": "Portugal", "RO": "Romania", "SK": "Slovakia", "SI": "Slovenia", "ES": "Spain", "SE": "Sweden", "GB": "United Kingdom"]

    var returnInt = returnInt
    let group = DispatchGroup()
    group.enter()

//    DispatchQueue.global().async {
//        getIpLocation(completion : { (output,_) in
//            if (output?.region == "CA") {
//                returnInt = 0
//                group.leave()
//            }
//            else if (EEACountries.contains(output?.country ?? "")){
//                returnInt = 1
//                group.leave()
//             }
//             else {
//                returnInt = 2
//                group.leave()
//             }
//        })
//    }

    DispatchQueue.global().async {
        getIpLocation(completion: { output, _ in
            if output?.states[0].state == "CA" {
                returnInt = 0
                group.leave()
            } else if EEACountries.contains(output?.country ?? "") {
                returnInt = 1
                group.leave()
            } else {
                returnInt = 2
                group.leave()
            }
        })
    }

    group.wait()
    if returnInt == 0 {
        if settings.object(forKey: "donotSell") == nil {
            settings.set(false, forKey: "donotSell")
        }
        return AnyView(CCPASettings(observedHelper: Helper(otStatus: false)))
    } else if returnInt == 1 {
        if settings.object(forKey: "donotSell") == nil {
            settings.set(true, forKey: "donotSell")
        }
        return AnyView(GDPRSettings())
    } else {
        return AnyView(defaultSettings(showView: true, showUserForm: true, userFormValuesInstance: userFormValues(), observedHelper: Helper(otStatus: false)))
    }
}

func viewReturner(viewInt: Int) -> AnyView {
    if viewInt == 0 {
        return AnyView(CCPASettings(observedHelper: Helper(otStatus: false)))
    } else if viewInt == 1 {
        return AnyView(GDPRSettings())
    } else {
        return AnyView(defaultSettings(showView: true, showUserForm: true, userFormValuesInstance: userFormValues(), observedHelper: Helper(otStatus: false)))
    }
}
