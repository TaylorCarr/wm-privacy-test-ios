//
//  HomeTab.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 4/17/20.
//  Copyright © 2020 T Carr. All rights reserved.
//

import AppLovinSDK
import Foundation
import GoogleMobileAds
import MoPubSDK
import OTPublishersHeadlessSDK
import SwiftUI
// import PrismiOS

// MARK: View 1

struct view1: View {
    var body: some View {
        Group {
            VStack {
                stories
            }.background(Color(UIColor.systemGray5))
        }
    }

    var stories: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(0 ... 10, id: \.self) { indx in
                    timeline(number: indx)
                }
            }
        }
    }
}

// MARK: Timeline

struct timeline: View {
    var number: Int

    let paragraphs: [String] = ["\tLorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent eget feugiat est. Integer aliquam fringilla risus eu tempor. Pellentesque ut lorem tempor, egestas nulla et, feugiat nulla. Aenean malesuada velit mauris, ut blandit massa sagittis eget. Phasellus a euismod eros. Aenean at diam lacinia, efficitur turpis non, consequat dui. Morbi eget nisi id erat placerat aliquet nec at tortor. Nullam ut hendrerit odio. Cras ut consequat orci, sed tincidunt ex. Suspendisse potenti. Praesent quis urna blandit, vestibulum turpis eu, dapibus dui. In malesuada convallis lectus at ultrices. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.", "\tAenean egestas augue eget libero sodales, ut laoreet est condimentum. Phasellus euismod, ipsum quis tempor dignissim, nisi magna maximus urna, egestas ornare augue justo eget erat. Vivamus risus lacus, rutrum eget magna vel, accumsan accumsan lorem. Nullam non ultrices turpis. Nullam sagittis nisi sit amet scelerisque efficitur. Suspendisse nisl ipsum, elementum eu nisi id, mollis feugiat leo. Aenean feugiat mauris quis est euismod, ac hendrerit nisi ultrices.", "\tPhasellus magna massa, scelerisque ut neque eget, efficitur sodales ante. Duis sed lacus orci. Aliquam erat volutpat. Vestibulum aliquet, nunc sit amet suscipit sollicitudin, est odio consectetur est, vitae sodales mi dolor vel erat. Nullam dui ex, tempor in egestas in, rhoncus eu arcu. Aliquam quis lorem vel ex egestas faucibus a quis arcu. Sed eget viverra velit. Nulla vitae ultrices nunc. Sed nec felis a ex vehicula ullamcorper et sed justo. Nam a urna scelerisque, tristique ante at, gravida quam. Nullam eu augue porttitor, dignissim lorem dignissim, ultricies purus. Aenean dignissim turpis sit amet auctor cursus. Donec eu leo quis dui volutpat ornare.", "\tMorbi malesuada in sem vitae semper. Duis elementum porttitor varius. Nunc tincidunt augue in augue bibendum posuere. Vestibulum ac tempus quam. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nullam sed ex tincidunt sem iaculis ultrices ut ut elit. Donec id facilisis dolor, sit amet convallis elit. Nulla convallis elementum tortor id gravida. In aliquam accumsan ex, non pharetra ligula scelerisque nec. Quisque non nibh non libero interdum facilisis id eu dui. Fusce sollicitudin dignissim velit, eget tempor massa condimentum vitae.", "\tCurabitur vel nunc sed diam congue lacinia. In tortor tortor, imperdiet ut felis id, porttitor tempus justo. Praesent vehicula enim a nulla tempor, eget condimentum dolor pulvinar. Nullam quis enim varius, rutrum velit non, auctor sapien. Mauris sit amet tincidunt ipsum. Phasellus dictum id nisi sed consequat. In hac habitasse platea dictumst. Suspendisse sem orci, fringilla dignissim pellentesque sed, pretium sit amet risus. Donec porta purus at erat porta, eu consequat nibh sodales. Vestibulum at nisl sed sapien dignissim dignissim. Etiam et auctor ante. Vestibulum at eleifend erat, sit amet suscipit leo. Praesent sit amet est maximus, viverra ipsum et, bibendum massa. Vestibulum convallis vel odio non vestibulum. Nunc tincidunt, tortor sed consectetur bibendum, risus sapien hendrerit turpis, non faucibus quam dui non nibh.", "\tIn in sagittis nisi. Sed posuere, dolor sit amet porttitor ornare, ex est ornare erat, imperdiet malesuada diam tortor nec ipsum. Donec mattis tristique justo, et posuere quam ultricies sed. Aliquam vitae hendrerit magna, pretium hendrerit tellus. Praesent nec aliquet nulla, in imperdiet elit. Nulla tincidunt, erat id fringilla eleifend, massa nibh condimentum lacus, nec sodales odio mi sed justo. Donec sed leo sed orci rhoncus pretium nec vel quam. Vestibulum dictum condimentum libero, eget eleifend ligula tempus vel."]

    var body: some View {
        if (number % 3) == 1 {
//            return AnyView(AppLovinAd)
            return AnyView(GAD)
        }
//        else if ((number % 5) == 2) {
//            return AnyView(MoPubAd)
//        }
//        else if ((number % 4) == 3) {
//            return AnyView(GAD)
//        }
        else {
            return AnyView(textBlock)
        }
    }

    var GAD: some View {
        HStack {
            Spacer()
            GADBannerViewController()
                .frame(width: GADAdSizeBanner.size.width, height: GADAdSizeBanner.size.height)
            Spacer()
        }
    }

    var MoPubAd: some View {
        HStack {
            Spacer()
            MoPubBannerViewController().frame(minWidth: kMPPresetMaxAdSize50Height.width, idealWidth: kMPPresetMaxAdSize50Height.width, maxWidth: kMPPresetMaxAdSize50Height.width, minHeight: MAAdFormat.banner.adaptiveSize.height, idealHeight: MAAdFormat.banner.adaptiveSize.height, maxHeight: MAAdFormat.banner.adaptiveSize.height)

            Spacer()
        }
    }

    var AppLovinAd: some View {
        HStack {
            Spacer()
            AppLovinBannerViewController().frame(width: MAAdFormat.banner.size.width, height: MAAdFormat.banner.size.height, alignment: .center)
            Spacer()
        }
    }

//    var AmazonAd: some View {
//        HStack {
//            Spacer()
//            AmazonAdViewController()
//                .frame(width: 320, height: 50)
//            Spacer()
//        }
//    }

    var textBlock: some View {
        Text(self.paragraphs[Int.random(in: 0 ... 5)])
            .padding()
            .foregroundColor(.black)
            .frame(width: screenWidth * 0.9, height: screenHeight * 0.25, alignment: .center)
            .background(Color.white)
            .shadow(radius: 5)
    }
}

// MARK: Google Ads

// AdMob View Controller for banner ads
struct GADBannerViewController: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> UIViewController {
        let view = GADBannerView(adSize: GADAdSizeBanner)
        let viewController = UIViewController()
        // Test ad load
        // view.adUnitID = "ca-app-pub-3940256099942544/2934735716" // test ad id

        // Test Prod Ads
        view.adUnitID = "ca-app-pub-7888296544691661/5982345762" // prod ad id
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["ffe38b512838bb863b9d808df63fc1dd"]

        view.rootViewController = viewController
        view.delegate = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: GADAdSizeBanner.size)
        view.load(GADRequest())

        print("viewController1 parent frame rect: \(viewController.view.frame(forAlignmentRect: CGRect(x: 0.0, y: 0.0, width: GADAdSizeBanner.size.width, height: GADAdSizeBanner.size.height)))")
        print("viewController1 alignment rect: \(viewController.view.alignmentRect(forFrame: CGRect(x: 0, y: 0, width: GADAdSizeBanner.size.width, height: GADAdSizeBanner.size.height)))")
        return viewController
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}

extension UIViewController: GADBannerViewDelegate {
    public func adViewDidReceiveAd(_: GADBannerView) {
        consoleLog(log: "AdMob loaded")
    }

    public func adView(_: GADBannerView, didFailToReceiveAdWithError error: NSError) {
        consoleLog(log: "AdMob Failed. Error: \(error)")
    }
}

// MARK: MoPub Banner Ads

final class MoPubBannerViewController: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> UIViewController {
        let view2 = MPAdView(adUnitId: "0c84919d83da4a4a803c222af6f3338f") // MPAdView(adUnitId: "0c84919d83da4a4a803c222af6f3338f", size: kMPPresetMaxAdSize50Height)
        view2?.maxAdSize = kMPPresetMaxAdSizeMatchFrame

        let viewController2 = UIViewController()

        view2!.delegate = viewController2
        // Ensure the adView's parent has a size set in order to use kMPPresetMaxAdSizeMatchFrame. Otherwise, give your adView's frame a specific size (e.g. 320 x 50)
        viewController2.view.addSubview(view2!)
        viewController2.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.10)
        print("viewController2 parent frame rect: \(viewController2.view.frame(forAlignmentRect: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: kMPPresetMaxAdSize90Height.height)))")
        print("viewController2 alignment rect: \(viewController2.view.alignmentRect(forFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: kMPPresetMaxAdSize90Height.height)))")

        print("kMP width: \(kMPPresetMaxAdSize50Height.width)")
        print("kMP width: \(kMPPresetMaxAdSize90Height.width)")
        print("kMP width: \(kMPPresetMaxAdSize250Height.width)")
        print("kMP width: \(kMPPresetMaxAdSize280Height.width)")
        print("kMP width: \(kMPPresetMaxAdSizeMatchFrame.width)")

        // You can pass in specific width and height to be requested
        view2?.loadAd(withMaxAdSize: kMPPresetMaxAdSize90Height)

        return viewController2
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}

extension UIViewController: MPAdViewDelegate {
    public func adViewDidLoadAd(_ view: MPAdView!, adSize: CGSize) {
        print("MoPubAd loaded with width: " + adSize.width.description)
        view.startAutomaticallyRefreshingContents()
    }

    public func adView(_: MPAdView!, didFailToLoadAdWithError error: Error!) {
        print("MoPubAd load failed: " + error.debugDescription)
    }

    public func viewControllerForPresentingModalView() -> UIViewController? {
        return self
    }
}

// MARK: AppLovin Banner Ads

final class AppLovinBannerViewController: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> UIViewController {
        let viewController3 = UIViewController()

        // Get the adaptive banner height.
        let _: CGFloat = MAAdFormat.banner.adaptiveSize.height

        // Stretch to the width of the screen for banners to be fully functional
        let _: CGFloat = MAAdFormat.banner.adaptiveSize.width

        let adView = MAAdView(adUnitIdentifier: appLovinID)
        adView.delegate = viewController3
//        adView.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.9, height: height)
        adView.frame = CGRect(origin: .zero, size: CGSize(width: MAAdFormat.banner.adaptiveSize.width, height: MAAdFormat.banner.adaptiveSize.height))
        adView.setExtraParameterForKey("adaptive_banner", value: "true")
//        adView.loadAd()
        viewController3.view.addSubview(adView)
        viewController3.view.frame = CGRect(x: 0, y: 0, width: MAAdFormat.banner.adaptiveSize.width, height: MAAdFormat.banner.adaptiveSize.height)
        adView.backgroundColor = .clear

        print("viewController3 parent frame rect: \(viewController3.view.frame(forAlignmentRect: CGRect(x: 0.0, y: 0.0, width: 350.0, height: 90.0)))")
        print("viewController3 alignment rect: \(viewController3.view.alignmentRect(forFrame: CGRect(x: 0, y: 0, width: 350, height: 90)))")
        print("\(MAAdFormat.banner.adaptiveSize.width)")

        // Load the first ad
        adView.loadAd()

        return viewController3
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}

extension UIViewController: MAAdViewAdDelegate {
    public func didExpand(_: MAAd) {}

    public func didCollapse(_: MAAd) {}

    public func didLoad(_: MAAd) {
        print("AppLovinAd loaded with width: ")
    }

    public func didFailToLoadAd(forAdUnitIdentifier _: String, withError error: MAError) {
        print("AppLovinAd load failed: " + error.debugDescription)
    }

    public func didDisplay(_: MAAd) {}

    public func didHide(_: MAAd) {}

    public func didClick(_: MAAd) {}

    public func didFail(toDisplay _: MAAd, withError _: MAError) {}
}
