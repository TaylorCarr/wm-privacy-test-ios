//
//  UserDefaultsManager.swift
//  psm-ios
//
//  Created by Brock Davis on 4/8/20.
//  Copyright © 2020 WarnerMedia. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    let privacySettings = UserDefaults.standard
    
    func setValue(_ value: Any, forKey key: PsmUserDefaultsKeys) {
        privacySettings.set(value, forKey: key.rawValue)
    }
    
    func removeValue(forKey key: PsmUserDefaultsKeys) {
        privacySettings.removeObject(forKey: key.rawValue)
    }
    
    func getStringValue(forKey key: PsmUserDefaultsKeys) -> String? {
        return privacySettings.string(forKey: key.rawValue)
    }
 
    func getIntValue(forKey key: PsmUserDefaultsKeys) -> Int {
        return privacySettings.integer(forKey: key.rawValue)
    }
    
    func getBoolValue(forKey key: PsmUserDefaultsKeys) -> Bool {
        return privacySettings.bool(forKey: key.rawValue)
    }
    
    func getObjectValue(forKey key: PsmUserDefaultsKeys) -> Any? {
        return privacySettings.object(forKey: key.rawValue)
    }
    
}
