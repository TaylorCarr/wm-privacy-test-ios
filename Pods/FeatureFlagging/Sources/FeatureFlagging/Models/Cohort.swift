//
//  File.swift
//  
//
//  Created by Dan Esrey on 4/8/20.
//

import Foundation

struct Cohort: Codable {
    let cohortId: Int
    let cohortPriority: Int
    let rolloutValue: Int
    var stickinessProperty: String?
    var cohortCriteria: [CohortCriteria]?
}
