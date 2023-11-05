//
//  BdsdkConstants.swift
//  
//
//  Created by SS079m on 3/11/21.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import Foundation

struct BdsdkConstants {
    //Time Interval to collect data periodically
    static let timeInterval = 120.0
}

struct BdsdkReasons: OptionSet {
    let rawValue: Int

    static let NOT_RUNNING_LOCATION_PERMISSION_DENIED = BdsdkReasons(rawValue: 1 << 0)
    static let NOT_RUNNING_FF_DISABLED = BdsdkReasons(rawValue: 1 << 1)
    static let NOT_RUNNING_DATA_SALE_DENIED = BdsdkReasons(rawValue: 1 << 2)
    static let NOT_RUNNING_OUTSIDE_US = BdsdkReasons(rawValue: 1 << 3)
    static let NOT_RUNNING_BDSDK_INTERNAL_ERROR = BdsdkReasons(rawValue: 1 << 4)
    static let NOT_RUNNING_BDSDK_VERSION_ERROR = BdsdkReasons(rawValue: 1 << 5)
    static let NOT_INITIALIZED = BdsdkReasons(rawValue: 1 << 6)
    static let STOPPED_FROM_API = BdsdkReasons(rawValue: 1 << 7)
}

