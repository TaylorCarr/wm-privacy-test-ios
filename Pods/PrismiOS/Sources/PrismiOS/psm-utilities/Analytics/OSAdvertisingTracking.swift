//
//  OSAdvertisingTracking.swift
//  
//
//  Created by Ungureanu Lucian on 14/05/2021.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import Foundation
import AppTrackingTransparency
import AdSupport

class OSAdvertisingTracking {
    static let AUTHORIZED = "authorized"
    static let DENIED = "denied"
    static let RESTRICTED = "restricted"
    static let NOT_DETERMINED = "notDetermined"
    
    static func getTrackingStatus() -> String {
        if #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
                case .restricted:   return self.RESTRICTED
                case .denied:       return self.DENIED
                case .authorized:   return self.AUTHORIZED
                default:            return self.NOT_DETERMINED
            }
        } else {
            return (ASIdentifierManager.shared().isAdvertisingTrackingEnabled) ? AUTHORIZED : DENIED
        }
    }
}
