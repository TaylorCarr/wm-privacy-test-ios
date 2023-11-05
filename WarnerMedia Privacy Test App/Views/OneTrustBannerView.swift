//
//  OneTrustBannerView.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 4/6/21.
//  Copyright © 2021 T Carr. All rights reserved.
//

import Foundation
import OTPublishersHeadlessSDK
import UIKit

class OneTrustNativeBanner: UIViewController {
    override func viewDidLoad() {
//        OTPublishersHeadlessSDK.shared.setupUI(self, UIType: .banner)
        OTPublishersHeadlessSDK.shared.setupUI(self)
        OTPublishersHeadlessSDK.shared.showBannerUI()
    }

    override func viewWillAppear(_: Bool) {
        view.backgroundColor = UIColor.clear

//        OTPublishersHeadlessSDK.shared.setupUI(self, UIType: .banner)
        OTPublishersHeadlessSDK.shared.setupUI(self)
        let bannerData = OTPublishersHeadlessSDK.shared.getBannerData()

        print("banner data: \(bannerData)")
    }
}
