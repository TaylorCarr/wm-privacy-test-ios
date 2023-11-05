//
//  EventProperties.swift
//  
//
//  Created by Ungureanu Lucian on 29/04/2021.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import FeatureFlagging

class EventProperties: AnalyticsEvent {
    let doNotSell: Bool
    let featureFlagValues: [FlagQueryResult]
    
    init(doNotSell: Bool, featureFlagValues: [FlagQueryResult]) {
        self.doNotSell = doNotSell
        self.featureFlagValues = featureFlagValues
        
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        doNotSell = try container.decode(Bool.self, forKey: .doNotSell)
        featureFlagValues = try container.decode([FlagQueryResult].self, forKey: .featureFlagValues)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(doNotSell, forKey: .doNotSell)
        try container.encode(featureFlagValues, forKey: .featureFlagValues)
    }
    
    enum CodingKeys: String, CodingKey {
        case doNotSell
        case featureFlagValues
    }
}

extension EventProperties: CustomStringConvertible {
    var description: String {
        return "FeautureAnalyticsEvent(doNotSell: \(doNotSell), featureFlagValues: \(featureFlagValues))"
    }
}

