//
//  File.swift
//
//
//  Created by Dan Esrey on 4/9/20.
//

import Foundation

struct FeatureFlagStorage {
    static let shared = FeatureFlagStorage()

    init() {}

    func set(key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }

    func get(key: String) -> String? {
        if let string = UserDefaults.standard.string(forKey: key) {
            return string
        }
        return nil
    }

    func delete(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    func createUserId() -> String {
        let ffUserId = UUID().uuidString
        set(key: .ffUserId, value: ffUserId)
        return ffUserId
    }

    func loadLocalConfig() -> FlagConfiguration? {
        // check for locally stored config
        if let config = getFlagConfigObjectFromDefaults() {
            return config
        } else {
            // TODO: implement formalized logging solution to replace print statements
            print("\n\nERROR LOADING LOCAL CONFIG: \(FeatureFlagClient.FFClientError.noCachedConfig)")
            let config = getFlagConfigFromFile()
            return config
        }
    }

    func getFlagConfigFromFile() -> FlagConfiguration? {
        print("\n\nCHECKING FOR FLAG CONFIGURATION FILE")
        guard let jsonData = readJSONDataFromFile(fileName: FlagStorageKeys.flagConfiguration.rawValue) else {
            print("\n\nUNABLE TO READ DATA FROM FLAG CONFIGURATION FILE")
            return nil
        }
        let decoder = JSONDecoder()
        do {
            let config = try decoder.decode(FlagConfiguration.self, from: jsonData)
            saveFlagConfigDataToDefaults(jsonData)
            print("\n\nSUCCESSFULLY LOADED FLAG CONFIGURATION FROM FILE-\nCONFIG:\n\(config)")
            return config
        } catch {
            print("\n\nUNABLE TO DECODE FLAG CONFIGURATION FROM FILE DATA")
        }
        return nil
    }

    func getFlagConfigObjectFromDefaults() -> FlagConfiguration? {
        guard let data = UserDefaults.standard.object(forKey: FlagStorageKeys.flagConfiguration.rawValue) as? Data else {
            print("\n\nUNABLE TO FIND FLAG CONFIGURATION IN USER DEFAULTS")
            return nil
        }
        let decoder = JSONDecoder()
        do {
            let config = try decoder.decode(FlagConfiguration.self, from: data)
            return config
        } catch {
            print("\n\nUNABLE TO DECODE FLAG CONFIGURATION FROM USER DEFAULTS DATA")
            return nil
        }
    }

    func saveConfigToStorage(_ config: FlagConfiguration) {
        if let data = try? JSONEncoder().encode(config) {
            saveFlagConfigDataToDefaults(data)
        }
    }

    func saveFlagConfigDataToDefaults(_ data: Data) {
        print("\n\nSAVING FLAG CONFIGURATION DATA TO USER DEFAULTS")
        UserDefaults.standard.setValue(data, forKey: FlagStorageKeys.flagConfiguration.rawValue)
    }

    func readJSONDataFromFile(fileName: String) -> Data? {
        do {
            if let file = Bundle.main.url(forResource: fileName, withExtension: "json") {
                let data = try Data(contentsOf: file)
                return data
            } else {
                print("\nno file")
                return nil
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    enum FlagStorageKeys: String {
        case userId
        case flagConfiguration = "FeatureFlagConfiguration"
    }
}
