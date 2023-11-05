//
//  PsmHouseholdIdResolution.swift
//  
//
//  Created by Ungureanu Lucian on 19/04/2021.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import Foundation

// Adding the @objc attribute and NSObject dependency because clients
// might need to interop swift with objective-c.
public class PsmHouseholdIdResolution: NSObject, FeatureFlagDelegate {
    
    private let userDefaults: UserDefaultsManager
    private let analyticsService: AnalyticsService
    internal var featureFlag: FeatureFlag
    private let loggingService: LoggingService
    
    private let minimumHours = 24 // the minimum number of hours between two sendHouseholdIdEvent calls
    
    private var savedWMUkId: String? {
        userDefaults.getStringValue(forKey: .WMUKID)
    }
    private var savedWMDate: Any? {
        userDefaults.getObjectValue(forKey: .WMDate)
    }

    init(userDefaults: UserDefaultsManager, analyticsService: AnalyticsService, featureFlag: FeatureFlag, loggingService: LoggingService) {
        self.userDefaults = userDefaults
        self.analyticsService = analyticsService
        self.featureFlag = featureFlag
        self.loggingService = loggingService
        
        super.init()
        
        analyticsService.delegate = self
        featureFlag.analyticsService.delegate = self
    }
    
    func verifyIdsFromToday() -> Bool? {
        guard !featureFlag.featureIsDisabled(featureId: FeatureFlag.ID_RESOLVE) else {
            loggingService.debug(message: "FeatureFlag ID_RESOLVE is disabled")
            return nil
        }
        return areHouseholdIdsSavedRecently()
    }
    
    func updateHouseholdIds(_ completion: ((_ areHouseholdIdsSaved: Bool) -> ())? = nil) {
        guard savedWMUkId != nil else {
            loggingService.debug(message: "WMUKID is NA, cannot make the HHID call")
            completion?(false)
            return
        }
        
        analyticsService.sendHouseholdIdEvent { [weak self] (data) in
            guard let validData = data else {
                self?.loggingService.debug(message: "HouseholdId Event Data is NA")
                completion?(false)
                return
            }
            let areHouseholdIdsSaved = self?.saveHouseholdIdData(validData) ?? false
            completion?(areHouseholdIdsSaved)
        }
    }
    
    private func areHouseholdIdsSavedRecently() -> Bool {
        guard let lastWMDate = savedWMDate as? TimeInterval,
              let hoursDifference = numberOfHours(fromTime: lastWMDate) else {
            loggingService.debug(message: "Household Ids Date is NA")
            return false
        }
        if hoursDifference >= minimumHours {
            loggingService.debug(message: "Household Ids were saved in a distant past")
            return false
        }
        return true
    }
    
    private func numberOfHours(fromTime: TimeInterval) -> Int? {
        let fromDate = Date.init(timeIntervalSince1970: fromTime)
        let diffComponents = Calendar.current.dateComponents([.hour], from: fromDate, to: Date())
        return diffComponents.hour
    }
    
    private func saveHouseholdIdData(_ data: Data) -> Bool {
        do {
            let householdIds = try JSONDecoder().decode(HouseholdIds.self, from: data)
            saveHouseholdIds(householdIds)
            return true
        } catch {
            loggingService.error(message: "Unable to decode the HouseholdIds data due to the following error: \(error.localizedDescription)",
                                 logInfo: LogInfo(eventType: EventType.householdId.rawValue, method: "saveHouseholdIdData"))
            return false
        }
    }
    
    private func saveHouseholdIds(_ householdIds: HouseholdIds) {
        if let wmhhid = householdIds.wmhhid {
            userDefaults.setValue(wmhhid, forKey: .WMHHID)
        } else { // if null is received, remove the previous cached value for WMHHID
            userDefaults.removeValue(forKey: .WMHHID)
        }
        
        if let wminid = householdIds.wminid {
            userDefaults.setValue(wminid, forKey: .WMINID)
        } else {  // if null is received, remove the previous cached value for WMINID
            userDefaults.removeValue(forKey: .WMINID)
        }
        
        // save the time, even if both ids could be nil
        userDefaults.setValue(Date().timeIntervalSince1970, forKey: .WMDate)
        loggingService.info(message: "Household Ids were saved")
    }

}
