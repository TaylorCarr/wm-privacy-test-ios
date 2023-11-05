//
//  AppDelegate.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 3/4/20.
//  Copyright © 2020 T Carr. All rights reserved.
//
import AdSupport
import AppLovinSDK
import Combine
import FBSDKCoreKit
import Foundation
import MoPubSDK
import OTPublishersHeadlessSDK
import PrismiOS
import Segment
import Segment_Firebase
import SwiftUI
import UIKit

// Global
let prism = try! PsmSdk(psmApp: PsmApp(appId: "5ee26f4a0e63d6a6a80db296", brand: "WarnerMedia Privacy", productName: "WM Privacy Test App", environment: .DEV, location: nil, subBrand: ""))
let cache = NSCache<NSString, NSArray>()
let defaults = UserDefaults.standard
let dnsCache = NSCache<NSString, NSNumber>()
let languageCache = NSCache<NSString, NSString>()
let locationCache = NSCache<NSString, NSString>()
let regionCache = NSCache<NSString, NSString>()
var systemLanguage = defaults.string(forKey: "systemLanguage") ?? "English"
var oneTrustAppId = defaults.string(forKey: "oneTrustAppID") ?? "a77f8b92-9293-4335-8677-f4b9ea36e8ae-test"
// WB-Prod "712b900c-0d11-4172-b2b6-b22da559e2b5-test"
// ENS-Prod "a77f8b92-9293-4335-8677-f4b9ea36e8ae-test"
let helper = Helper(otStatus: false)
let appLovinID = "08842d4c4e8c8e95"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var vungleAppID = "5e504fc94b46da00176e1ec3"

    func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        languageCache.setObject(systemLanguage as NSString, forKey: NSString(stringLiteral: "systemLanguage"))

        // SDK Privacy Handling
        let region = sdkInit()

        switch region {
        case "CA":
            regionCache.setObject("CA", forKey: "region")
            print("Region: CA")
            if UserDefaults.standard.string(forKey: "IABUSPrivacy_String") == "1YYN" { // user opted-out
//                VungleSDK.shared().update(VungleConsentStatus.denied, consentMessageVersion: "6.3.2")
            } else { // default / user opted-in
//                VungleSDK.shared().update(VungleConsentStatus.accepted, consentMessageVersion: "6.3.2")
            }
        case "EEA":
            regionCache.setObject("EEA", forKey: "region")
            print("Region: EEA")
//            if(OTPublishersSDK.shared.getConsentStatusForGroupId("SDK02") == 1) {
//                VungleSDK.shared().update(VungleConsentStatus.accepted, consentMessageVersion: "6.3.2")
//            }
//            else {
//                VungleSDK.shared().update(VungleConsentStatus.denied, consentMessageVersion: "6.3.2")
//            }
//            if(OTPublishersSDK.shared.getConsentStatusForGroupId("SDK03") == 1) {
//
//            }
//            else {
//
//            }
//            if(OTPublishersSDK.shared.getConsentStatusForGroupId("SDK04") == 1) {
//
//            }
//            else {
//
//            }
//            if(OTPublishersSDK.shared.getConsentStatusForGroupId("SDK05") == 1) {
//
//            }
//            else {
//
//            }
        default:
            // all non-restricted regions
            regionCache.setObject("DEFAULT", forKey: "region")
            print("Region: default")
        }

        // OneTrust
        if regionCache.object(forKey: "region") == "EEA" {
            let dg = DispatchGroup()
            dg.enter()
            initOneTrustSDK(systemLanguage: systemLanguage)
            dg.leave()
        }

        initOneTrustSDK(systemLanguage: systemLanguage)

        // Vungle Ads
//        let sdk:VungleSDK = VungleSDK.shared()
//        do {
//            try sdk.start(withAppId: vungleAppID)
//        }
//        catch let error as NSError {
//            consoleLog(log: "Error while starting VungleSDK : \(error.domain)")
//        }

        // Check for updated privacy policy
        if UserDefaults.standard.object(forKey: "newPrivacyPolicy") == nil {
            UserDefaults.standard.set(true, forKey: "newPrivacyPolicy")
        }

//        Analytics.init(configuration: AnalyticsConfiguration(writeKey: ""))
//        Analytics.shared().disable()

        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Segment
        let segmentConfig = AnalyticsConfiguration(writeKey: "jlqMIlmaJr1WGPSp6woVY51sPV6wucqp")
        segmentConfig.trackApplicationLifecycleEvents = true
        segmentConfig.use(SEGFirebaseIntegrationFactory.instance())
        Analytics.setup(with: segmentConfig)

        // Facebook Analytics
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
//        AppEvents.initialize()
        AppEvents.shared.activateApp()
//        AppEvents.initialize()
        AppEvents.logEvent(AppEvents.Name(rawValue: "Launch Event"))

        // MoPub
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: "0c84919d83da4a4a803c222af6f3338f")
        sdkConfig.loggingLevel = .info
        MoPub.sharedInstance().initializeSdk(with: sdkConfig, completion: nil)

        // AppLovin
//        ALSdk.initializeSdk()
        ALSdk.shared()!.mediationProvider = "max"
        ALSdk.shared()!.userIdentifier = appLovinID
        ALSdk.shared()!.initializeSdk { (_: ALSdkConfiguration) in
            // Start loading ads
            ALSdk.shared()!.settings.testDeviceAdvertisingIdentifiers = ["\(ASIdentifierManager.shared().advertisingIdentifier)"]
            let adView = MAAdView(adUnitIdentifier: appLovinID)
            adView.loadAd()
        }

        // Prism
        let userDefaultsManager = UserDefaults.standard
//        _ = PrismSdk(appId: "WMPTA")
        consoleLog(log: "User WMUKID == \(prism.getWMUKID())")
        userDefaultsManager.setValue(prism.getWMUKID(), forKey: "wmukid")

        return true
    }

    /*
     let languages: [String:String] = ["Arabic": "ar", "Bulgarian":"bg", "Croatian":"hr", "Czech":"cz", "Danish":"da", "Dutch":"nl", "English":"en-US", "Finnish":"fi", "French":"fr", "German":"de", "Hungarian":"hu", "Italian":"it", "Norwegian":"no", "Polish":"pl", "Portuguese (Brazil)":"pr-BR", "Portuguese (Portugal)":"pt", "Romanian":"ro", "Russian":"ru", "Slovak":"sk", "Slovenian": "sl", "Spanish (EU)":"es", "Spanish (LatAm)":"es-MX", "Swedish":"sv", "Turkish":"tr"]

     */

    // MARK: Load OneTrust SDK

    // function to load OneTrust SDK
    func initOneTrustSDK(systemLanguage: String) {
//        var lang: String = "en-US"
//        let test = languages[systemLanguage]
//        print(test ?? "en-US")
//
//        if (systemLanguage == "Spanish") {
//            lang = "es"
//        }

        var lang: String = helper.languagesMap[systemLanguage]?.code ?? "en-US"

        helper.languagesMap.forEach { language in
            if language.value.isFavorite == true {
                lang = language.value.code

                languageCache.setObject(language.key as NSString, forKey: "systemLanguage")
            }
        }

//        let lang = languages[systemLanguage] ?? "en-US"

        let profileSyncParams = OTProfileSyncParams()
        profileSyncParams.setSyncProfile("true")
//        profileSyncParams.setSyncProfileAuth("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJoYm9tYXhfdHZvczI2QG15d2FybmVybWVkaWEuY29tIiwibmFtZSI6IkhCT01BWCBEZW1vIiwiaWF0IjoxNTE2MjM5MDIyfQ.kI3tq6uERgTW9X54MHkU3Eqh6o-cQDigcFULAmEGGTs")
//        profileSyncParams.setIdentifier("hbomax_tvos26@mywarnermedia.com")
//        profileSyncParams.setSyncProfileAuth("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjMTE4ZjRkMS1hZjZiLTQ2NGYtYjNlOS05YWRhOTJiNGRhNzkiLCJuYW1lIjoiQk9MVCIsImlhdCI6MTY2NjMzNTU3M30.WyWhf-tOpOVJrlWSw5nF6LkUeFIvNBESX04THplBNfg")
//        profileSyncParams.setIdentifier("c118f4d1-af6b-464f-b3e9-9ada92b4da79")

        let sdkParams = OTSdkParams(countryCode: nil, regionCode: nil)
//        let sdkParams = OTSdkParams(countryCode: "FR", regionCode: nil)
//        sdkParams.setBannerHeightRatio(.full)
//        sdkParams.setProfileSyncParams(profileSyncParams)
        sdkParams.setShouldCreateProfile("true")

        let domainUrl = "cdn.cookielaw.org",
            domainId = "712b900c-0d11-4172-b2b6-b22da559e2b5-test"
        // "1ef6f726-897b-467c-92ae-717730fc4e9b-test" // oneTrustAppId
        // "bf2fb79a-a45b-4afa-8713-db2ba12b6059-test"
        // Dev "02f0cc7e-484e-478e-b796-c55d62b6ab55-test"
        // Prod "712b900c-0d11-4172-b2b6-b22da559e2b5-test"
        // Staging "bf2fb79a-a45b-4afa-8713-db2ba12b6059-test",
        // "0a1d2c51-8951-4db7-a77d-3f15158ce16e-test",
        // domainId = "c90fc319-6a51-46d2-8027-481c3c11231d-test",
        // EU Prod "a77f8b92-9293-4335-8677-f4b9ea36e8ae-test",
//            language = lang
//
        if Thread.isMainThread {
//            OTPublishersHeadlessSDK.shared.clearOTSDKData()

            OTPublishersHeadlessSDK.shared.startSDK(storageLocation: domainUrl, domainIdentifier: domainId, languageCode: lang, params: sdkParams) { [weak self] response in
                print("OTT Data fetch result \(response.responseString != nil) and error \(String(describing: response.error?.localizedDescription))")

                if OTPublishersHeadlessSDK.shared.shouldShowBanner() {
                    helper.showOneTrust = true
                }
//                helper.showOneTrust = true
                OTPublishersHeadlessSDK.shared.uiConfigurator = self

                _ = OTPublishersHeadlessSDK.shared.setOTOfflineData(_:)

                guard let self = self else { return }

                if let _ = response.error {
                    self.clearLocalDataForDemoApp()
                }

                guard let _ = response.responseString else {
                    return DispatchQueue.main.async { [weak self] in
                        print("Download OT Data: Completed with error.")
                        guard self != nil else { return }

                        print("There was an error: \(response.error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        } else {
            DispatchQueue.main.sync {
                OTPublishersHeadlessSDK.shared.startSDK(storageLocation: domainUrl, domainIdentifier: domainId, languageCode: lang, params: sdkParams) { [weak self] response in
                    print("OTT Data fetch result \(response.responseString != nil) and error \(String(describing: response.error?.localizedDescription))")
                    print("bannerShown value \(defaults.bool(forKey: "bannerShown"))")

                    OTPublishersHeadlessSDK.shared.uiConfigurator = self
                    if OTPublishersHeadlessSDK.shared.shouldShowBanner() {
                        helper.showOneTrust = true
                    }

                    var currentId = OTPublishersHeadlessSDK.shared.currentActiveProfile
                    OTPublishersHeadlessSDK.shared.renameProfile(from: currentId, to: "newProfileID", completion: { renameSuccess in
                        print(renameSuccess)
                        OTPublishersHeadlessSDK.shared.saveConsent(type: .preferenceCenterConfirm)
                    })
                    _ = OTPublishersHeadlessSDK.shared.setOTOfflineData(_:)

                    guard let self = self else { return }

                    if let _ = response.error {
                        self.clearLocalDataForDemoApp()
                    }

                    guard let _ = response.responseString else {
                        return DispatchQueue.main.async { [weak self] in
                            print("Download OT Data: Completed with error.")

                            guard self != nil else { return }

                            print("There was an error: \(response.error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                }
            }
        }
        OTPublishersHeadlessSDK.shared.enableOTSDKLog(.error)
    }

    struct prefCenterParent: Codable {
        var Groups: [prefCenterChildren]
    }

    struct prefCenterChildren: Codable {
        var GroupName: String
        var Children: [String: childrenObject]
    }

    struct childrenObject: Codable {
        var GroupDescription: String
        var FirstPartyCookies: [String: String]
    }

    /// Resets the demo app constants. Clears local data from user defaults.
    func clearLocalDataForDemoApp() {
        OTPublishersHeadlessSDK.shared.clearOTSDKData()
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationWillTerminate(_: UIApplication) {
//        UserDefaults.standard.removeObject(forKey: "IABUSPrivacy_String")
    }
}

extension AppDelegate: UIConfigurator {
    func shouldUseCustomUIConfig() -> Bool {
        return true
    }

    func customUIConfigFilePath() -> String? {
        let customPath = Bundle.main.path(forResource: "OTSDK-UIConfig-iOS", ofType: "plist")
        return customPath
    }
}
