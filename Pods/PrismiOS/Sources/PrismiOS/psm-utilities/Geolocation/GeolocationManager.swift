//
//  GeolocationManager.swift
//  psm-ios
//
//  Created by Brock Davis on 4/8/20.
//  Copyright © 2020 WarnerMedia. All rights reserved.
//

import Foundation

typealias GeolocationClosure = (_ country: String?, _ error: String?) -> ()
protocol GeolocationProtocol {
    func getCountry(_ completion: @escaping GeolocationClosure)
}

class GeolocationManager: GeolocationProtocol {
    private let network = NetworkHelper.shared
    private let userDefaults = UserDefaultsManager.shared
    
    private let geoUrlString = "https://geo.ngtv.io/locate"
    
    func getCountry(_ completion: @escaping GeolocationClosure) {
        network.get(geoUrlString) { (data, error) in
            guard let data = data else {
                completion(nil, error?.description)
                return
            }
            
            do {
                self.userDefaults.setValue(data, forKey: .Geolocation)
                
                let geoLocation = try JSONDecoder().decode(Geolocation.self, from: data)
                let country = geoLocation.countryAlpha2.uppercased()
                completion(country, nil)
            } catch {
                completion(nil, error.localizedDescription)
            }
        }
    }
}
