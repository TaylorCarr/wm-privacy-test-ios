//
//  ProxyAPI.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 9/2/20.
//  Copyright © 2020 T Carr. All rights reserved.
//

import Foundation

func proxyGrantConsent(firstParty: Bool, newsletter: Bool, productUpdates: Bool, promotions: Bool) {
    do {
        // Assign variables
        let wmukid = UUID().uuidString // prism.getWMUKID() ?? UUID().uuidString
        let apiKey = "9c24f76348be05a2e740789470ae5a0d"
        let firstPartyDataSharingID = "5ff26fe3-6128-4e17-b292-2b3cce9fdc70"
        let ellenInsiderID = "3f11c10e-aa84-4327-9f29-748e5a937a5b"
        let customPreferencesID = "b0150530-7feb-4ef2-8f81-584288ce5c0c"
        let tailoredAdsID = "2fe62df9-86ff-45fe-bcdf-dbd3d59583ea"
        let shareInfoID = "77422300-81dd-46b7-8c25-16cf99ba1ed4"
        let email = "Taylor.Carr@wbconsultant.com"
        let name = "Taylor Carr"
        let apiToken = getAPIToken()
        var json: [String: Any] = [:]

        // Switch to handle what purposes and custom preferences the user consented to
        switch (firstParty, newsletter, productUpdates, promotions) {
        case (true, true, true, true):
            json = [
                "identifier": wmukid,
                "test": true,
                "requestInformation": apiToken,
                "purposes": [["Id": firstPartyDataSharingID],
                             ["Id": ellenInsiderID,
                              "CustomPreferences": [
                                  ["Id": customPreferencesID,
                                   "Options": [tailoredAdsID,
                                               shareInfoID]]]],
                ],
                "dsDataElements": [
                    "Name": name,
                    "Email": email,
                ],
            ]
        case (true, true, true, false):
            json = [
                "identifier": wmukid,
                "test": true,
                "requestInformation": apiToken,
                "purposes": [["Id": firstPartyDataSharingID],
                             ["Id": ellenInsiderID,
                              "CustomPreferences": [
                                  ["Id": customPreferencesID,
                                   "Options": [tailoredAdsID]]]],
                ],
                "dsDataElements": [
                    "Name": name,
                    "Email": email,
                ],
            ]
        case (true, true, false, true):
            json = [
                "identifier": wmukid,
                "test": true,
                "requestInformation": apiToken,
                "purposes": [["Id": firstPartyDataSharingID],
                             ["Id": ellenInsiderID,
                              "CustomPreferences": [
                                  ["Id": customPreferencesID,
                                   "Options": [shareInfoID]]]],
                ],
                "dsDataElements": [
                    "Name": name,
                    "Email": email,
                ],
            ]
        case (true, true, false, false):
            json = [
                "identifier": wmukid,
                "test": true,
                "requestInformation": apiToken,
                "purposes": [["Id": firstPartyDataSharingID],
                             ["Id": ellenInsiderID,
                              "CustomPreferences": [
                                  ["Id": customPreferencesID,
                                   "Options": []]]],
                ],
                "dsDataElements": [
                    "Name": name,
                    "Email": email,
                ],
            ]
        case (true, false, false, false),
             (true, false, true, false),
             (true, false, false, true):
            json = [
                "identifier": wmukid,
                "test": true,
                "requestInformation": apiToken,
                "purposes": [["Id": firstPartyDataSharingID],
                ],
                "dsDataElements": [
                    "Name": name,
                    "Email": email,
                ],
            ]
        case (false, true, true, true):
            json = [
                "identifier": wmukid,
                "test": true,
                "requestInformation": apiToken,
                "purposes": [["Id": ellenInsiderID,
                              "CustomPreferences": [
                                  ["Id": customPreferencesID,
                                   "Options": [tailoredAdsID,
                                               shareInfoID]]],
                             ],
                ],
                "dsDataElements": [
                    "Name": name,
                    "Email": email,
                ],
            ]
        case (false, true, true, false):
            json = [
                "identifier": wmukid,
                "test": true,
                "requestInformation": apiToken,
                "purposes": [["Id": ellenInsiderID,
                              "CustomPreferences": [
                                  ["Id": customPreferencesID,
                                   "Options": [tailoredAdsID]]],
                             ],
                ],
                "dsDataElements": [
                    "Name": name,
                    "Email": email,
                ],
            ]
        case (false, true, false, true):
            json = [
                "identifier": wmukid,
                "test": true,
                "requestInformation": apiToken,
                "purposes": [["Id": ellenInsiderID,
                              "CustomPreferences": [
                                  ["Id": customPreferencesID,
                                   "Options": [shareInfoID]]],
                             ],
                ],
                "dsDataElements": [
                    "Name": name,
                    "Email": email,
                ],
            ]
        case (false, true, false, false):
            json = [
                "identifier": wmukid,
                "test": true,
                "requestInformation": apiToken,
                "purposes": [["Id": ellenInsiderID,
                              "CustomPreferences": [
                                  ["Id": customPreferencesID,
                                   "Options": []]],
                             ],
                ],
                "dsDataElements": [
                    "Name": name,
                    "Email": email,
                ],
            ]
        default:
            return
        }

        // Setup the HTTP request and submit it to OneTrust
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        let url = URL(string: "https://privacyportaluat.onetrust.com/request/v1/consentreceipts")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        consoleLog(log: "req: \(String(data: jsonData, encoding: .utf8)!)")
        let task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, _, _ in
            consoleLog(log: "OneTrust Consent Response: \(String(data: data!, encoding: .utf8)!)")
        }
        task.resume()

        linkDataSubjects(apiKey: apiKey, wmukid: wmukid, email: email, name: name)
    } catch {
        consoleLog(log: "JSON Serialization Error: \(error)")
    }
}
