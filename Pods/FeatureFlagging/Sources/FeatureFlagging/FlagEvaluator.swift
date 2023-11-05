//
//  File.swift
//
//
//  Created by Dan Esrey on 5/13/20.
//

import Foundation

struct FlagEvaluator {
    static let shared = FlagEvaluator()

    func matchingFlagInConfiguration(featureId: String,
                                     configuration: FlagConfiguration,
                                     warnings: inout [Warning]) -> Flag?
    {
        if let flag = configuration.flags.first(where: { $0.id.lowercased() == featureId.lowercased() }) {
            if flag.type.lowercased() == .boolean {
                return flag
            } else {
                warnings.append(Warning.FLAG_TYPE_NOT_SUPPORTED)
            }
        }
        return nil
    }

    /**
     Determine which cohort configuration from the feature config file to use

     -  Parameters:
     -   context: The ClientConfiguration (i.e., userObject)
     -   cohortConfigs: cohort configuration objects from the feature config file

     -  Returns:    Cohort object
     */
    func getCohortConfig(context: ClientConfiguration,
                         cohortConfigs: [Cohort]) -> Cohort?
    {
        guard !cohortConfigs.isEmpty else {
            return nil
        }
        // sort by 'cohortPriority' property
        let cohortConfigsSorted = cohortConfigs.sorted(by: { $0.cohortPriority < $1.cohortPriority })

        // identify cohort config to use by validating all 'cohortCriteria' fields
        let match = cohortConfigsSorted.first(where: { self.isMatch(between: context, and: $0) })
        return match
    }

    func isMatch(between context: ClientConfiguration, and cohortConfig: Cohort) -> Bool {
        guard hasSupportedStickinessProperty(cohort: cohortConfig, context: context) else {
            return false
        }
        // ensure cohort's cohortCriteria property is not nil and not an empty array
        guard let cohortCriteria = cohortConfig.cohortCriteria,
              !cohortCriteria.isEmpty
        else {
            return true
        }
        // determine whether context object includes key equal to any cohortCriteria object's fieldName
        return foundSharedValues(in: context, and: cohortCriteria)
    }

    func hasSupportedStickinessProperty(cohort: Cohort, context: ClientConfiguration) -> Bool {
        if cohort.stickinessProperty == .appUserId, context.userId != nil {
            return true
        } else if cohort.stickinessProperty == .ffUserId {
            return true
        }
        return false
    }

    func foundSharedValues(in context: ClientConfiguration, and cohortCriteria: [CohortCriteria]) -> Bool {
        // for EVERY cohortCriteria element, we must have at least one required field match
        return cohortCriteria.allSatisfy { criteriaMatch(in: context, and: $0) }
    }

    func criteriaMatch(in context: ClientConfiguration, and criteria: CohortCriteria) -> Bool {
        let fieldName = criteria.requiredFieldName.lowercased()
        let fieldValues = criteria.requiredFieldValues.map { $0.lowercased() }
        let newContext = context

        for key in newContext.targetingProperties.keys {
            newContext.targetingProperties[key.lowercased()] = newContext.targetingProperties.removeValue(forKey: key)
        }

        let contextFieldValue = newContext.targetingProperties[fieldName]
        if contextFieldValue == nil, fieldValues.contains("") {
            return true
        }
        if let value = contextFieldValue,
           fieldValues.contains(value.lowercased())
        {
            return true
        }
        return false
    }
}
