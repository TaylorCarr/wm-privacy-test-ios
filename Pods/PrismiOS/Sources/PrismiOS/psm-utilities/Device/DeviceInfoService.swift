//
//  DeviceInfoService.swift
//  
//
//  Created by Nirvan Nagar on 5/16/20.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import Foundation
#if !os(macOS)
import UIKit
#endif

class DeviceInfoService {
    
    static let shared = DeviceInfoService()
    
    // Getting the OS and device information is done differently for mac and non-mac devices.
    // Also, the non-mac libraries can only be pulled in conditionally on the condition
    // that the device is not a mac. Thus, we are adding the #if #else check.
    func getDeviceInfo() -> Device {
        #if os(macOS)
        let deviceType = DeviceInfoConstants.COMPUTER
            let name = DeviceInfoConstants.MAC
            let model = DeviceInfoConstants.UNKNOWN
            let osName = DeviceInfoConstants.MACOS
            let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
            
            return Device(type: deviceType, name: name, model: model, osName: osName, osVersion: osVersion)
        #else
            let deviceType = getDeviceType(idiom: UIDevice.current.userInterfaceIdiom)
            let name = UIDevice.current.name
            let model = UIDevice.current.model
            let osName = UIDevice.current.systemName
            let osVersion = UIDevice.current.systemVersion
            
            return Device(type: deviceType, name: name, model: model, osName: osName, osVersion: osVersion)
        #endif
    }

    // UIInterfaceIdiom is only for non-macOS operating systems so we need to add
    // this check to make sure the current device is not a mac.
#if !os(macOS)
    private func getDeviceType(idiom: UIUserInterfaceIdiom) -> String {
        switch idiom {
        case .carPlay:
            return DeviceInfoConstants.CAR
        case .pad:
            return DeviceInfoConstants.TABLET
        case .phone:
            return DeviceInfoConstants.PHONE
        case .tv:
            return DeviceInfoConstants.TV
        default:
            return DeviceInfoConstants.UNKNOWN
        }
    }
#endif
    
    public func getIdentifierForVendor() -> String {
    #if !os(macOS)
        return UIDevice.current.identifierForVendor?.uuidString ?? (DeviceInfoConstants.UNKNOWN + UIDevice.current.systemName)
    #else
        return DeviceInfoConstants.UNKNOWN + DeviceInfoConstants.MACOS
    #endif
    }

}
