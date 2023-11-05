//
//  File.swift
//  
//
//  Created by Nirvan Nagar on 6/11/20.
//

import Foundation

struct RetryEvent<T: AnalyticsEvent>: Codable {
    let event: T
    let endpoint: String
}
