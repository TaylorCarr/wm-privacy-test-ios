//
//  File.swift
//  
//
//  Created by Dan Esrey on 4/8/20.
//

import Foundation

struct CohortCriteria: Codable {
    let cohortCriteriaId: Int
    let requiredFieldName: String
    var requiredFieldValues: [String]
}
