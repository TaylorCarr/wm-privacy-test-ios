//
//  OneTrustViewController.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 4/27/20.
//  Copyright © 2020 T Carr. All rights reserved.
//

import Foundation
import OTPublishersHeadlessSDK
import SwiftUI
import UIKit

class OneTrustVC: UIViewController {
    override func viewDidLoad() {
        let ccpaTextLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 30, height: 10))
        ccpaTextLabel.text = "CCPA String"

        let ccpaStringLabel = UITextView(frame: CGRect(x: 10, y: 10, width: 30, height: 10))
        ccpaStringLabel.text = UserDefaults.standard.string(forKey: "IABUSPrivacy_String")

        let gdprTextLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 30, height: 10))
        gdprTextLabel.text = "GDPR String"

        let gdprStringLabel = UITextView(frame: CGRect(x: 10, y: 10, width: 30, height: 10))
        gdprStringLabel.text = UserDefaults.standard.string(forKey: "IABTCF_TCString")

        view.addSubview(ccpaTextLabel)
        view.addSubview(ccpaStringLabel)
        view.addSubview(gdprTextLabel)
        view.addSubview(gdprStringLabel)
    }

    override func viewWillDisappear(_: Bool) {
//        consoleLog(log: "Banner is... \(OTPublishersSDK.shared.isBannerShown())")
    }

    @objc func actionConsent_SoPD(_ notification: Notification) {
        let consentValue = notification.object as? String
        NSLog("SoPD Consent Value = \(consentValue ?? "false")")
    }
}

class OneTrustNativeVC: UIViewController {
    var mode: String = ""

    override func viewDidLoad() {
        print("OTHeadlessSDK OneTrustNativeVC view loaded.Mode == \(mode)")
        if regionCache.object(forKey: "region") == "EEA" {
            OTPublishersHeadlessSDK.shared.setupUI(self)
            if OTPublishersHeadlessSDK.shared.isBannerShown() != -1 {
                if mode == "banner" {
                    OTPublishersHeadlessSDK.shared.showBannerUI()
                } else {
                    OTPublishersHeadlessSDK.shared.showPreferenceCenterUI()
                }
                OTPublishersHeadlessSDK.shared.addEventListener(self)
            } else {
                print("OTHeadlessSDK data is unavailable")
            }
        }

        OTPublishersHeadlessSDK.shared.setupUI(self)
        print("OTHeadlessSDK common data == \(OTPublishersHeadlessSDK.shared.getCommonData())")
        if OTPublishersHeadlessSDK.shared.getCommonData() != nil {
            if mode == "banner" {
                OTPublishersHeadlessSDK.shared.showBannerUI()
            } else {
                OTPublishersHeadlessSDK.shared.showPreferenceCenterUI()
            }
            OTPublishersHeadlessSDK.shared.addEventListener(self)
        } else {
            print("OTHeadlessSDK data is unavailable")
        }
        if OTPublishersHeadlessSDK.shared.isBannerShown() != -1 {
            if mode == "banner" {
                OTPublishersHeadlessSDK.shared.showBannerUI()
            } else {
                OTPublishersHeadlessSDK.shared.showPreferenceCenterUI()
            }
            OTPublishersHeadlessSDK.shared.addEventListener(self)
        } else {
            print("OTHeadlessSDK data is unavailable")
        }
    }

    override func viewWillAppear(_: Bool) {
        view.backgroundColor = UIColor.clear
//        if (regionCache.object(forKey: "region") == "EEA") {
//            OTPublishersHeadlessSDK.shared.setupUI(self)
//
//            if (mode == "banner") {
//                _ = OTPublishersHeadlessSDK.shared.getBannerData()
//            } else {
//                _ = OTPublishersHeadlessSDK.shared.getPreferenceCenterData()
//            }
//
//            let tempArray: [String: Any]? = OTPublishersHeadlessSDK.shared.getPreferenceCenterData()
//            print("preference center: \(tempArray!["Groups"])")
//        }

        if OTPublishersHeadlessSDK.shared.getCommonData() != nil {
            OTPublishersHeadlessSDK.shared.setupUI(self)

            if mode == "banner" {
                _ = OTPublishersHeadlessSDK.shared.getBannerData()
            } else {
                _ = OTPublishersHeadlessSDK.shared.getPreferenceCenterData()
            }

//            let tempArray: [String: Any]? = OTPublishersHeadlessSDK.shared.getPreferenceCenterData()
//            print("preference center: \(tempArray!["Groups"])")
        }

//        OTPublishersHeadlessSDK.shared.setupUI(self)

//        if (mode == "banner") {
//            _ = OTPublishersHeadlessSDK.shared.getBannerData()
//        } else {
//            _ = OTPublishersHeadlessSDK.shared.getPreferenceCenterData()
//        }
    }
}

extension OneTrustNativeVC: OTEventListener {
    func allSDKViewsDismissed(interactionType: ConsentInteractionType) {
        print("OTHeadlessSDK: interactionType = \(interactionType.hashValue)")
        print("OTHeadlessSDK: interactionType = \(interactionType.description)")
        print(interactionType)
        NotificationCenter.default.post(name: NSNotification.Name("generic"), object: nil)
    }

    func onHideBanner() {
        NotificationCenter.default.post(name: NSNotification.Name("generic"), object: nil)
    }

    func onHidePreferenceCenter() {
        NotificationCenter.default.post(name: NSNotification.Name("generic"), object: nil)
    }

    func onBannerClickedRejectAll() {
        NotificationCenter.default.post(name: NSNotification.Name("generic"), object: nil)
    }

    func onBannerClickedAcceptAll() {
        NotificationCenter.default.post(name: NSNotification.Name("generic"), object: nil)
    }

    func onPreferenceCenterRejectAll() {
        NotificationCenter.default.post(name: NSNotification.Name("generic"), object: nil)
    }

    func onPreferenceCenterAcceptAll() {
        NotificationCenter.default.post(name: NSNotification.Name("generic"), object: nil)
    }

    func onPreferenceCenterConfirmChoices() {
        NotificationCenter.default.post(name: NSNotification.Name("generic"), object: nil)
    }
}
