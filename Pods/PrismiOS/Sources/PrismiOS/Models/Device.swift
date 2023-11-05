//
//  Device.swift
//  
//
//  Created by Nirvan Nagar on 5/22/20.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import Foundation

struct Device: Codable, Equatable {
    let type: String
    let name: String
    let model: String
    let osName: String
    let osVersion: String
}
