//
//  File.swift
//
//
//  Created by Dan Esrey on 4/21/20.
//

import Foundation

struct ConfigurationProvider {
    init() {}

    static let shared = ConfigurationProvider()

    func checkForRemoteConfig(at url: String, version: Int, completion: @escaping (String?, FlagConfiguration?) -> Void) {
        let helper = NetworkHelper.shared
        try? helper.get(url, version: version, completion: { data, err in
            guard let data = data else {
                completion(err, nil)
                return
            }

            do {
                let fConfig = try JSONDecoder().decode(FlagConfiguration.self, from: data)
                FeatureFlagStorage.shared.saveFlagConfigDataToDefaults(data)
                completion(nil, fConfig)
            } catch {
                completion(error.localizedDescription, nil)
            }
        })
    }
}
