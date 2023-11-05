//
//  HouseholdIdEvent.swift
//  
//
//  Created by Ungureanu Lucian on 19/04/2021.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import Foundation

class HouseholdIdEvent: AnalyticsEvent {
    let wmukid: String
    let ids: HouseholdIds

    init(wmukid: String, ids: HouseholdIds) {
        self.wmukid = wmukid
        self.ids = ids
        
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        wmukid = try container.decode(String.self, forKey: .wmukid)
        ids = try container.decode(HouseholdIds.self, forKey: .ids)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(wmukid, forKey: .wmukid)
        try container.encode(ids, forKey: .ids)
    }
    
    enum CodingKeys: String, CodingKey {
        case wmukid
        case ids
    }
}

extension HouseholdIdEvent: CustomStringConvertible {
    var description: String {
        return "HouseholdIdEvent(WMUKID: \(wmukid)), householdIds: \(ids))"
    }
}
