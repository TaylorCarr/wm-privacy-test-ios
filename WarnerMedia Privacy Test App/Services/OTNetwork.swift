//
//  OTNetwork.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 5/1/20.
//  Copyright © 2020 T Carr. All rights reserved.
//

import Foundation
// import OTPublishersHeadlessSDK
import SwiftUI

class OTManager {
    public static let shared = OTManager()
    private init() {}
    @State var showView = true
    func returnSettings() -> AnyView {
        let location = "" // OTPublishersHeadlessSDK.shared.getUserLocation()
//        consoleLog(log: "Geolocation: \(String(describing: location))")

        let EEACountries: [String] = ["Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czechia", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", "Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Poland", "Portugal", "Romania", "Slovakia", "Slovenia", "Spain", "Sweden", "United Kingdom"]

//        if(location?.state == "CA") {
//            return AnyView(CCPASettings())
//        }
        if location == "CA" {
            return AnyView(CCPASettings(observedHelper: Helper(otStatus: false)))
        } else if EEACountries.contains(output?.country ?? "") {
            return AnyView(GDPRSettings())
        } else {
            return AnyView(defaultSettings(showView: true, showUserForm: true, userFormValuesInstance: userFormValues(), observedHelper: Helper(otStatus: false)))
        }
    }
}
