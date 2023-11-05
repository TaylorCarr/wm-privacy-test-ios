//
//  Network.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 4/17/20.
//  Copyright © 2020 T Carr. All rights reserved.
//

import AdSupport
import Foundation
import Segment
import Segment_Firebase // Segment - Firebase
import SwiftUI
import UIKit
import WebKit
// import PrismiOS
// import OTPublishersSDK

// MARK: WebView Struct

// WebView used to load and present any webpages to the user
// params: URL String and URLRequest
struct webView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    var url: String
    let request: URLRequest
    var cookieStorage = WKWebsiteDataStore.default()

    func makeCoordinator() -> webView.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<webView>) -> WKWebView {
        let preferences = WKPreferences()
//                preferences.javaScriptEnabled = true
        //        preferences.plugInsEnabled = false

        // Create a configuration for the preferences
        // let configuration = WKWebViewConfiguration()
        // configuration.preferences = preferences

        //        let cookieStorage = WKWebsiteDataStore.default()
        cookieStorage.httpCookieStore.getAllCookies { cookiesArray in
            for i in 0 ..< cookiesArray.count {
                print("Cookies: cookie number \(i)")
                print(cookiesArray[i])
                HTTPCookieStorage.shared.setCookie(cookiesArray[i])
            }
        }

        let temp = HTTPCookieStorage.shared.cookies ?? []

        print("temp cookies: \(temp)")

        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.websiteDataStore = cookieStorage
        webViewConfiguration.processPool = WKProcessPool()
        webViewConfiguration.preferences = preferences

        let wkwebview = WKWebView(frame: .zero, configuration: webViewConfiguration)
        wkwebview.autoresizingMask = .flexibleWidth
        wkwebview.autoresizingMask = .flexibleHeight
        wkwebview.navigationDelegate = context.coordinator

        print("custom configuration below")
        print(wkwebview.configuration)

        return wkwebview
    }

    func updateUIView(_ uiView: WKWebView, context _: UIViewRepresentableContext<webView>) {
        uiView.load(request)
    }

    //    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
    //        var copy = self
    //        copy.loadStatusChanged = perform
    //        return copy
    //    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: webView
        let sharedStorage: WKWebsiteDataStore

        init(_ parent: webView) {
            self.parent = parent
            sharedStorage = parent.cookieStorage
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            print(navigationAction)

            if navigationAction.navigationType == WKNavigationType.linkActivated {
                print("link")

                sharedStorage.httpCookieStore.getAllCookies { cookiesArray in
                    for i in 0 ..< cookiesArray.count {
                        print("Cookies: cookie number \(i)")
                        print(cookiesArray[i])
                        HTTPCookieStorage.shared.setCookie(cookiesArray[i])
                    }
                    print(webView.configuration.processPool)
                }
                decisionHandler(WKNavigationActionPolicy.allow)
                return
            }
            print("no link")
            sharedStorage.httpCookieStore.getAllCookies { cookiesArray in
                for i in 0 ..< cookiesArray.count {
                    print("Cookies: cookie number \(i)")
                    print(cookiesArray[i])
                    HTTPCookieStorage.shared.setCookie(cookiesArray[i])
                }
                print(webView.configuration.processPool)
            }
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
}

// MARK: UIWebView

// struct uiview: UIViewRepresentable {
//
//    typealias UIViewType = UIWebView
//
//    let url = NSURL (string: "https://policies.warnerbros.com/terms/en-us/")
//
//    func makeUIView(context: UIViewRepresentableContext<uiview>) -> uiview.UIViewType {
//        let request = URLRequest(url: url as! URL)
//        let webView = UIWebView()
////        webView.loadRequest(request)
//        webView.loadHTMLString("https://policies.warnerbros.com/terms/en-us/", baseURL: url as URL?)
//
//        return webView
//    }
//
//    func updateUIView(_ uiView: UIWebView, context: UIViewRepresentableContext<uiview>) {
//        let request = URLRequest(url: url as! URL)
//        uiView.loadRequest(request)
//    }
// }

// MARK: Log DNS

// Function to log user data when they toggle DNS. This will be replaced by Prism Privacy SDK functionality
func logPrivacyDNSCurrentState() -> [String: Any] {
    let IDFV = UIDevice.current.identifierForVendor!.uuidString
    let appName: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    let appVersion: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    let platform = "iOS"
    let DNSStatus = (UserDefaults.standard.bool(forKey: "donotSell") ? "1" : "0")
    //    let DNSStatus = OTPublishersSDK.shared.getConsentStatusForGroupId("BG1")
    let privacyStore = UserDefaults.standard
    var requestObject = [String: Any]()

    // Get date and time
    let currentDateTime = Date()
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .long
    let formattedTime = formatter.string(from: currentDateTime)

    enum toggleAnalytics: String {
        case brand
        case doNotSell
        case email
        case environment = "env"
        case eventName
        case maid
        case timestamp = "timeStamp"
        case platform
        case wmukid // IDFV

        // Added values
        //        case usps = "usps" // IAB CCPA string
        case IABCCPA = "IAB US"
        case IABGDPR = "IAB TCF"
        case appName
        case appVersion = "version"
    }

    requestObject[toggleAnalytics.brand.rawValue] = privacyStore.string(forKey: "Brand_Id")
    requestObject[toggleAnalytics.doNotSell.rawValue] = DNSStatus
    requestObject[toggleAnalytics.environment.rawValue] = privacyStore.string(forKey: "Prism_Env")
    requestObject[toggleAnalytics.wmukid.rawValue] = IDFV
    requestObject[toggleAnalytics.maid.rawValue] = ASIdentifierManager.shared().advertisingIdentifier.uuidString
    requestObject[toggleAnalytics.email.rawValue] = ""
    // Added values
    requestObject[toggleAnalytics.IABGDPR.rawValue] = privacyStore.string(forKey: "IABTCF_TCString")
    //    requestObject[toggleAnalytics.usps.rawValue] = PrismSdk.shared.privacy.getUSPString()
    requestObject[toggleAnalytics.IABCCPA.rawValue] = privacyStore.string(forKey: "IABUSPrivacy_String")
    requestObject[toggleAnalytics.timestamp.rawValue] = formattedTime
    requestObject[toggleAnalytics.platform.rawValue] = platform
    requestObject[toggleAnalytics.appName.rawValue] = appName
    requestObject[toggleAnalytics.appVersion.rawValue] = appVersion

    if UserDefaults.standard.object(forKey: "donotSell") != nil {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestObject, options: .prettyPrinted)
            // let url = URL(string: "https://jyt7s1j9r1.execute-api.us-east-1.amazonaws.com/Production/v1")!
            let url = URL(string: "https://webhook.site/4c713b57-c64e-426b-97c5-3f953ebc7721")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            // request.httpBody = jsonData
            let task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, _, _ in
                consoleLog(log: String(data: data!, encoding: .utf8)!)
            }
            task.resume()
        } catch {
            consoleLog(log: "JSON Error")
        }

        // Google Analytics
        //        Analytics.logEvent("DNS_CurrentState", parameters: ["IDFV":IDFV, "DNSStatus":DNSStatus, "appName":appName!, "appVersion":appVersion!, "platform":platform])

        // Segment
        Analytics.shared().track("DNS", properties: ["IDFV": IDFV, "DNSStatus": DNSStatus, "appName": appName!, "appVersion": appVersion!, "platform": platform])

        //        // Adobe Analytics
        //        ACPCore.trackAction("DNS_CurrentState", data: ["IDFV":IDFV, "DNSStatus": DNSStatus, "appName":appName!, "appVersion":appVersion!, "platform":platform ])
        //
        //        // Adjust
        //        let DNS_CurrentState = ADJEvent(eventToken: "DNS_CurrentState")
        //        DNS_CurrentState?.addCallbackParameter("IDFV", value: IDFV)
        //        DNS_CurrentState?.addCallbackParameter("DNSStatus", value: DNSStatus)
        //        DNS_CurrentState?.addCallbackParameter("appName", value: appName!)
        //        DNS_CurrentState?.addCallbackParameter("appVersion", value: appVersion!)
        //        DNS_CurrentState?.addCallbackParameter("platform", value: platform)
        //        Adjust.trackEvent(DNS_CurrentState);
    }
    return requestObject
}

// MARK: Universal Consent Management

struct options {
    var customPrefIds: [String]
}

struct customPref {
    var Id: String
    var Options: options?
}

struct purpose {
    var Id: String
    var pref: customPref?
}

func logUniversalConsent(firstParty: Bool, newsletter: Bool, productUpdates: Bool, promotions: Bool) {
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

func linkDataSubjects(apiKey: String, wmukid: String, email: String, name _: String) {
    let json: [String: Any] = ["identifiers": [wmukid, email],
                               "primaryIdentifier": wmukid]

    do {
        // Setup the HTTP request and submit it to OneTrust
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        consoleLog(log: "OneTrust Linked Identifiers json \(String(decoding: jsonData, as: UTF8.self))")
        let url = URL(string: "https://uat.onetrust.com/api/consentmanager/v2/linkedidentitygroups")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, _, _ in
            consoleLog(log: "OneTrust Linked Identifiers Response: \(String(data: data!, encoding: .utf8)!)")
        }
        task.resume()
    } catch {
        consoleLog(log: "OneTrust Linked Identifiers Error: \(error)")
    }
}

func getAPIToken() -> String {
    // collection poind id: f9686bed-3dc9-4137-8994-04f8bf37706d
    //    let url = URL(string: "https://uat.onetrust.com/api/consentmanager/v1/collectionpoints/f9686bed-3dc9-4137-8994-04f8bf37706d/token")!
    //    let apiKey = "9c24f76348be05a2e740789470ae5a0d"
    //    var request = URLRequest(url: url)
    //    request.httpMethod = "GET"
    //    request.setValue(apiKey, forHTTPHeaderField: "apikey")
    //
    return "eyJhbGciOiJSUzUxMiJ9.eyJvdEp3dFZlcnNpb24iOjEsInByb2Nlc3NJZCI6ImY5Njg2YmVkLTNkYzktNDEzNy04OTk0LTA0ZjhiZjM3NzA2ZCIsInByb2Nlc3NWZXJzaW9uIjoxMSwiaWF0IjoiMjAyMC0wNy0wNlQyMToxODoyMi44NSIsIm1vYyI6IkFQSSIsInN1YiI6IndtdWtpZCIsImlzcyI6bnVsbCwidGVuYW50SWQiOiI0NWEwYzNkYS05ZGE2LTQzNTctYmIxNy1kNGM0OTA5MTE1YTEiLCJkZXNjcmlwdGlvbiI6Ik1vYmlsZSBhcHBsaWNhdGlvbiBmb3IgRWxsZW50dWJlIC0gY3JlYXRlZCBhcyBhIGNvbGxlY3Rpb24gcG9pbnQiLCJjb25zZW50VHlwZSI6IkNPTkRJVElPTkFMVFJJR0dFUiIsImRvdWJsZU9wdEluIjpmYWxzZSwiYXV0aGVudGljYXRpb25SZXF1aXJlZCI6ZmFsc2UsInBvbGljeV91cmkiOm51bGwsImFsbG93Tm90R2l2ZW5Db25zZW50cyI6ZmFsc2UsInB1cnBvc2VzIjpbeyJpZCI6IjVmZjI2ZmUzLTYxMjgtNGUxNy1iMjkyLTJiM2NjZTlmZGM3MCIsInZlcnNpb24iOjYsInRvcGljcyI6W10sImN1c3RvbVByZWZlcmVuY2VzIjpbXX0seyJpZCI6ImM5MWE3MDA2LWRlM2EtNDY5My1hMjY0LTc0ODQxZWE3ODgyOSIsInZlcnNpb24iOjIsInRvcGljcyI6W10sImN1c3RvbVByZWZlcmVuY2VzIjpbeyJpZCI6ImYxYTUzMTE1LWIxYjktNGM0NC05MzNmLWQxYzUzNWIzYjgzMyIsImlzUmVxdWlyZWQiOmZhbHNlLCJvcHRpb25zIjpbImQ2NDA1MGFiLTVhZWEtNGYzZS1iMWY0LTdkMWZkZDdlODMzOCIsImVlNDNiMjZjLWUxMDItNDYyYS05ZmNjLTRiNTEwOWQyMWIzMSJdfV19LHsiaWQiOiIzZjExYzEwZS1hYTg0LTQzMjctOWYyOS03NDhlNWE5MzdhNWIiLCJ2ZXJzaW9uIjoyLCJ0b3BpY3MiOltdLCJjdXN0b21QcmVmZXJlbmNlcyI6W3siaWQiOiJiMDE1MDUzMC03ZmViLTRlZjItOGY4MS01ODQyODhjZTVjMGMiLCJpc1JlcXVpcmVkIjpmYWxzZSwib3B0aW9ucyI6WyIyZmU2MmRmOS04NmZmLTQ1ZmUtYmNkZi1kYmQzZDU5NTgzZWEiLCI3NzQyMjMwMC04MWRkLTQ2YjctOGMyNS0xNmNmOTliYTFlZDQiXX1dfV0sIm5vdGljZXMiOltdLCJkc0RhdGFFbGVtZW50cyI6WyJOYW1lIiwiRW1haWwiLCJQcml2YWN5IFBvbGljeSBEZXRhaWxzIl19.dZtiMeR8iEBLxPN7_7Nrf-FoJWu2Jwildz42O6YF1-3pRUi31erlRJ9bFR6gfoxESQ5uITAPmvDVBdeemxmXp1B43BLqW6JCFPZXZSzJYIWTQpfZy07FJlyeklohTIxBm9WJzBPD8Uuxagk43Njz2StPzFWLSOIaUxmpBpCzq5yjy14X1Zch7YMF_I_aVL3BF1RmafXJre67RMOkOu2rNgSK-SldEA6iWQBANYiyiYnsfOVsXW5st-IJTAcB6uI1vh8_Qa6WTwYb7MMkWr9z5YbKTV2fIEHDMuKKd4K13jPk-P9YCeAQlOJ8hXoiJi6ebqd5x89Id4gip9K1Vc0_spRm4s6_FYvv-7jZNmjBkmRk2d9yg5_vgF747WiNqjkgvEmSAQM-gWAn9ah97Noc1AaabQAO8OH03Nxf6yiYphb1bKqDIa50M7mZ4AGovvkQHbyNm8HkEWEQLQqVJ2NZNXBrlRBD6OD-cgDjsgnmlfm1xtHNjXIiN-xPwkO2QDJghAKkh97oY6z4e2UUAAVteQPiRGjrFIu_TWKPH5wxP80VMfrL0VdYHniWZUhinaFPKqxkZv9HVsRBPEgMZXT-8osVAWVI3qW_WGwGhoiswGoPGakacd6qVMGksrYTt766n9v0zkJ90ePW01VWfv4u2PxZm69IB0cYPFXywW9sHd0"
}

struct customPreferences {}

struct languages {
    var description: String
    var language: String
    var name: String
}

struct purposeDetails {
    var customPreferences: [customPreferences]
    var description: String
    var label: String
    var languages: [languages]
}

func getPurposeDetails1() {
    let url = URL(string: "https://uat.onetrust.com/api/consentmanager/v2/purposes/5ff26fe3-6128-4e17-b292-2b3cce9fdc70")!
    let apiKey = "9c24f76348be05a2e740789470ae5a0d"
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(apiKey, forHTTPHeaderField: "apikey")
    var responseArray: [String] = []

    let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, _: URLResponse?, _: Error?) in

        if let json = try? JSONSerialization.jsonObject(with: data!, options: [.mutableContainers]) as? [String: Any] {
            responseArray.append(json["label"]! as! String)
            responseArray.append("\(json["description"]!)")

            cache.setObject(responseArray as NSArray, forKey: NSString(string: "purposeDetails1"))
        }
    })
    task.resume()
}

func getPurposeDetails2() {
    let url = URL(string: "https://uat.onetrust.com/api/consentmanager/v2/purposes/3f11c10e-aa84-4327-9f29-748e5a937a5b")!
    let apiKey = "9c24f76348be05a2e740789470ae5a0d"
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(apiKey, forHTTPHeaderField: "apikey")
    var responseArray: [String] = []

    let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, _: URLResponse?, _: Error?) in

        if let json = try? JSONSerialization.jsonObject(with: data!, options: [.mutableContainers]) as? [String: Any] {
            consoleLog(log: "purpose details 2 \(json)")
            responseArray.append(json["label"]! as! String)
            responseArray.append("\(json["description"]!)")
            let temp = json["customPreferences"] as! [Any]
            //            consoleLog(log: "Temp: \(temp[0])")
            let temp2 = temp[0] as! NSDictionary
            let temp3 = temp2.object(forKey: "customPreferenceOptions") as! [Any]
            let temp4 = temp3[0] as! NSDictionary
            //            consoleLog(log: "CustomPref Options \(temp4.object(forKey: "label"))")
            responseArray.append("\(temp4.object(forKey: "label")!)")
            let temp5 = temp3[1] as! NSDictionary
            responseArray.append("\(temp5.object(forKey: "label")!)")
            cache.setObject(responseArray as NSArray, forKey: NSString(string: "purposeDetails2"))
        }
    })
    task.resume()
}

func withdrawFirstPartyConsent() {
    do {
        let wmukid = UUID().uuidString // prism.getWMUKID() ?? UUID().uuidString
        let apiKey = "9c24f76348be05a2e740789470ae5a0d"
        let purposeID = "5ff26fe3-6128-4e17-b292-2b3cce9fdc70"
        let json: [String: Any] = ["identifier": purposeID]
        _ = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let url = URL(string: "https://uat.onetrust.com/api/consentmanager/v1/transactions/withdraw/purpose/\(purposeID)?identifier=\(wmukid)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(wmukid, forHTTPHeaderField: "identifier")
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            consoleLog(log: "Withdraw Consent log: \(String(data: data ?? Data(), encoding: .utf8) ?? "nil")")
            //            consoleLog(log: "WMUKID: \(wmukid)")
        }

        task.resume()
    } catch {
        consoleLog(log: "Withdraw consent error")
    }
}

func withdrawNewsletterConsent() {
    do {
        let wmukid = UUID().uuidString // prism.getWMUKID() ?? UUID().uuidString
        let apiKey = "9c24f76348be05a2e740789470ae5a0d"
        let purposeID = "3f11c10e-aa84-4327-9f29-748e5a937a5b"
        let json: [String: Any] = ["identifier": purposeID]
        _ = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let url = URL(string: "https://uat.onetrust.com/api/consentmanager/v1/transactions/withdraw/purpose/\(purposeID)?identifier=\(wmukid)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(wmukid, forHTTPHeaderField: "identifier")
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            consoleLog(log: "Withdraw Consent log: \(String(data: data ?? Data(), encoding: .utf8) ?? "nil")")
            //            consoleLog(log: "WMUKID: \(wmukid)")
        }

        task.resume()
    } catch {
        consoleLog(log: "Withdraw consent error")
    }
}

func loadUniversalConsentDetails() -> Bool {
    var gp = false
    var gcs = false
    if Thread.isMainThread {
        gp = getPurposes()
        gcs = getConsentStatus()
    } else {
        DispatchQueue.main.sync {
            gp = getPurposes()
            gcs = getConsentStatus()
        }
    }
    //    let gp = getPurposes()
    //    let gcs = getConsentStatus()
    if gp, gcs {
        return true
    } else {
        return false
    }
}

struct purposesResponse: Codable {
    //    var isError: Bool?
    //    var errorMessage: String?
    var purposes: [purposeObject?]
    var dataSubjectAttributes: [String?]
}

struct purposeObject: Codable {
    var id: String
    var code: String?
    var type: String?
    var legalBasis: String?
    var regulatoryFrameworks: [String?]
    var label: String?
    var description: String?
    var version: Int?
    var status: String?
    var nestedPurposes: [nestedPurposeObject?]
}

struct nestedPurposeObject: Codable {
    var options: [String?]
    var customPrefId: String?
    var customPrefName: String?
}

func getPurposes() -> Bool {
    let appId = "WMMOBIAPP78352" // WMMOBIAPP78352
    let apiKey = "9iNSGRlinV9khiLNfATL6qA4GqZpuy24whRQ8Rkb"
    //    var responseArray: [Any] = []
    let url = URL(string: "https://dev.consent.api.warnermediaprivacy.com/v1/purposes")!
    //    url.queryItems = [
    //        URLQueryItem(name: "appId", value: appId)
    //    ]
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
    request.setValue(appId, forHTTPHeaderField: "appId")
    request.setValue("CMDB", forHTTPHeaderField: "appIdType")

    let decoder = JSONDecoder()

    URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, _, error in
        if let content = data {
            do {
                let response = try decoder.decode(purposesResponse.self, from: content)
                consoleLog(log: "JSON response: \(response)")
                //                completion(response, error)
                cache.setObject(response.purposes as NSArray, forKey: "purposes")
                //                return true
                //                let purposesResponse = ["Purposes API Response": response]
                //                cache.setObject(purposesResponse as! NSArray, forKey: "purposesResponse")
            } catch {
                consoleLog(log: "Purposes JSON response error: \(error)")
                //                completion(nil, nil)
                //                return false
            }
        } else {
            consoleLog(log: "Get purposes Else Error: \(String(describing: error))")
            //            completion(nil, error)
            //            return false
        }
    }).resume()

    //    let task = URLSession.shared.dataTask(with: request){ data, response, error in
    //        consoleLog(log: "getPurposes() log: \(String(data: data ?? Data(), encoding: .utf8) ?? "nil")")
    //
    //
    //        if let content = data {
    //            do {
    //                let response = try decoder.decode(purposesResponse.self, from: content)
    //                consoleLog(log: "JSON response: \(response)")
    //                completion(response, error)
    //            }
    //            catch {
    //                consoleLog(log: "Geolocation JSON response error: \(error)")
    //                completion(nil, nil)
    //            }
    //        }
    //        else {
    //            consoleLog(log: "Get IP Else Error: \(String(describing: error))")
    //            completion(nil, error)
    //        }
    //
    //
    //        if let json = try? JSONSerialization.jsonObject(with: data!, options: [.mutableContainers]) as? [String: Any] {
    //            print(JSONSerialization.isValidJSONObject(json))
    //            print("purposes json response below:")
    //            print(json)
    //
    //            if(json["isError"] == false && json.purposes.count > 0) {
    ////                responseArray.append(json.purposes)
    //
    //                cache.setObject(json.purposes as NSArray, forKey: "purposes")
    //                print("OBJECT CACHED!!!!!!!!!")
    //                print(cache.object(forKey: NSString(string: "purposes")) as! [purposeObject])
    //            }
    //        }
    //    }
    //    task.resume()
    //
    return true
}

struct dataSubjectResponse: Codable {
    var isError: Bool
    var errorMessage: String?
    var dataSubject: dataSubjectObject?
}

struct dataSubjectObject: Codable {
    var dataSubjectId: String
    var dataSubjectIdType: String
    var elements: [dataElement?]
    var consents: [consentsObject]
    var createdDate: String?
    var modifiedDate: String?
    var linkedDataSubjects: [String?]
}

struct consentsObject: Codable {
    var purposeId: String
    var purposeLabel: String
    var purposeCode: String?
    var consentAction: String?
    var consentActionDate: String?
    var expiryDate: String?
}

struct dataElement: Codable {
    var name: String
    var value: String
}

func getConsentStatus() -> Bool {
    let appId = "WMMOBIAPP78352" // WMMOBIAPP78352
    let wmukid = "new-ID-345" // prism.getWMUKID() ?? UUID().uuidString
    let apiKey = "9iNSGRlinV9khiLNfATL6qA4GqZpuy24whRQ8Rkb"
    var url = URLComponents(string: "https://dev.consent.api.warnermediaprivacy.com/v1/dataSubjects")!
    url.queryItems = [
        URLQueryItem(name: "idType", value: "wmukid"),
        URLQueryItem(name: "id", value: wmukid),
    ]

    var request = URLRequest(url: url.url!)
    request.httpMethod = "GET"
    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
    request.setValue(appId, forHTTPHeaderField: "appId")
    request.setValue("CMDB", forHTTPHeaderField: "appIdType")
    print(url.url!)

    let decoder = JSONDecoder()

    URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, _, error in
        if let content = data {
            do {
                let response = try decoder.decode(dataSubjectResponse.self, from: content)
                consoleLog(log: "JSON response: \(response)")
                if response.isError == false, response.dataSubject?.dataSubjectId != "" {
                    response.dataSubject?.consents.forEach { index in
                        if index.consentAction == "ACTIVE" {
                            //                        var temp = index.purposeLabel
                            settings.set(Binding.constant(true), forKey: index.purposeLabel)
                            //                        @AppStorage(index.purposeLabel) var temp = true
                            //                            let dataSubjectResponse = ["Data Subject API Response": response]
                            cache.setObject(response.dataSubject!.consents as NSArray, forKey: "dataSubjectResponse")
                        } else {
                            settings.set(Binding.constant(false), forKey: index.purposeLabel)
                        }
                    }
                } else {
                    let purposes = cache.object(forKey: "purposes") as? [purposeObject]
                    purposes?.forEach { index in
                        settings.set(false, forKey: index.label!)
                    }
                }
            } catch {
                consoleLog(log: "Consent status JSON response error: \(error)")
                //                completion(nil, nil)
                //                return false
            }
        } else {
            consoleLog(log: "Get consent status Else Error: \(String(describing: error))")
            //            completion(nil, error)
            //            return false
        }
    }).resume()

    //    let task = URLSession.shared.dataTask(with: request){ data, response, error in
    //        consoleLog(log: "getConsentStatuses() log: \(String(data: data ?? Data(), encoding: .utf8) ?? "nil")")
    //
    //        if let json = try? JSONSerialization.jsonObject(with: data!, options: [.mutableContainers]) as? dataSubjectResponse {
    //            if(json.isError == false && json.dataSubject.dataSubjectId != "") {
    //                json.dataSubject.consents.forEach { index in
    //                    if(index.consentAction == "ACTIVE") {
    ////                        var temp = index.purposeLabel
    //                        settings.set(Binding.constant(true), forKey: index.purposeLabel)
    ////                        @AppStorage(index.purposeLabel) var temp = true
    //                    }
    //                    else {
    //                        settings.set(Binding.constant(false), forKey: index.purposeLabel)
    //                    }
    //                }
    //            }
    ////            cache.setObject(responseArray as NSArray, forKey: NSString(string: "purposes"))
    //        }
    //    }
    //    task.resume()

    return true
}

struct consentResponse: Codable {
    var isError: Bool?
    var errorMessage: String?
    var transactionStatus: String?
    var consentTransactionId: String?
}

func recordConsent() {
    //    let dataElements: [String: Any?]
    let consentObject = buildConsentObject()

    print(consentObject)

    var payload: [String: Any] = [:]

    payload = [
        "dataSubjectId": UUID().uuidString, // prism.getWMUKID() ?? UUID().uuidString, // "user.email@test.com",
        "dataSubjectIdType": "wmukid",
        "createdDate": "2021-01-05T12:00:00Z",
        "consents": consentObject,
        "dataSubjectAttributes": [
            [
                "name": "firstName",
                "value": "Taylor",
            ],
            [
                "name": "lastName",
                "value": "Carr",
            ],
            [
                "name": "country",
                "value": "US",
            ],
            [
                "name": "state",
                "value": "CA",
            ],
        ],
        "transactionAttributes": [
            [
                "name": "platform",
                "value": "iOS",
            ],
            [
                "name": "consentMediaChannel",
                "value": "mobile",
            ],
            [
                "name": "consentGeolocationCountry",
                "value": "US",
            ],
        ],
    ]

    let url = URL(string: "https://dev.consent.api.warnermediaprivacy.com/v1/consents/recordConsent")!
    //    let url = URL(string: "https://webhook.site/afe990ae-ea2d-430b-acd7-88a95bb18a24")!
    let appId = "WMMOBIAPP78352" // WMMOBIAPP78352
    let apiKey = "9iNSGRlinV9khiLNfATL6qA4GqZpuy24whRQ8Rkb"

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
    request.setValue(appId, forHTTPHeaderField: "appId")
    request.setValue("CMDB", forHTTPHeaderField: "appIdType")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //    request.httpBody =

    let decoder = JSONDecoder()

    print(request.allHTTPHeaderFields!)
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
        let dataString = String(data: jsonData, encoding: .utf8)!
        //        print(dataString)
        //        print(JSONSerialization.isValidJSONObject(payload))
        request.httpBody = jsonData
        do {
            let task = URLSession.shared.dataTask(with: request) { data, _, _ in
                consoleLog(log: "recordConsent() uploadTask data: \(String(data: data!, encoding: .utf8)!)")

                do {
                    let response = try decoder.decode(consentResponse.self, from: data!)
                    print(response)

                    let consentResponse = ["isError: \(response.isError)",
                                           "errorMessage: \(response.errorMessage ?? "")",
                                           "transactionStatus: \(response.transactionStatus ?? "")",
                                           "consentTransactionId: \(response.consentTransactionId ?? "")"]
                    cache.setObject(consentResponse as NSArray, forKey: "consentResponse")
                } catch let responseError {
                    print("response error: \(responseError)")
                }
            }
            task.resume()

            //            consoleLog(log: "recordConsent() uploadTask task: \(task)")
        }
    } catch let jsonError {
        consoleLog(log: "recordConsent() JSON error: \(jsonError)")
    }
}

struct consentObject {
    var purposeId: String
    var consentAction: String
    var actionType: String
}

func buildConsentObject() -> [Any] {
    var returnArray: [Any] = []

    var consentArray = [String: Any]()

    enum consentEnum: String {
        case actionType
        case consentAction
        case purposeId
    }

    let purposes = cache.object(forKey: "purposes") as! [purposeObject]
    purposes.forEach { index in
        var temp = consentObject(purposeId: "", consentAction: "", actionType: "EXPLICIT")
        temp.purposeId = index.id
        consentArray[consentEnum.purposeId.rawValue] = index.id
        consentArray[consentEnum.actionType.rawValue] = "EXPLICIT"

        if settings.bool(forKey: index.label!) == true {
            temp.consentAction = "GRANTED"
            consentArray[consentEnum.consentAction.rawValue] = "GRANTED"
        } else {
            temp.consentAction = "WITHDRAWN"
            consentArray[consentEnum.consentAction.rawValue] = "WITHDRAWN"
        }
        returnArray.append(consentArray)
    }

    return returnArray
}

struct Network_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
