//
//  ReceiveLocation.swift
//  
//
//  Created by Ungureanu Lucian on 29/04/2021.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

struct ReceiveLocation: Codable, Equatable {
    let city: String?
    let state: String?
    let country: String?
    let zip: String?
    let timezone: String?
    let locale: String?
    let language: String?
}
