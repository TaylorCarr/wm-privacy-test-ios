//
//  ContentView.swift
//  PrismSDK
//
//  Created by T Carr on 2/13/20.
//  Copyright © 2020 T Carr. All rights reserved.
//

import Combine
import Foundation
import OTPublishersHeadlessSDK
import Segment_Firebase // Segment - Firebase
import SwiftUI

// import CoreLocation

// let testLocation = LocationViewModel()

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height
let settings = UserDefaults.standard
var wbblue = #colorLiteral(red: 0, green: 0.262745098, blue: 0.6823529412, alpha: 1)

// MARK: Header

// Header for the main view
struct modalHeader: View {
    var headerText: String

    var body: some View {
        HStack {
            Image("headerLogo").resizable().frame(width: UIScreen.main.bounds.width * 0.4, alignment: .leading)
            Text(headerText).frame(width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.height * 0.1, alignment: .center).font(.headline)
        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.1, alignment: .center).background(Color(wbblue)).foregroundColor(.white)
    }
}

enum ActiveSheet: Identifiable {
    case first, second

    var id: Int {
        hashValue
    }
}

// MARK: Main Content View

// Main view that you see upon launching the application
struct ContentView: View {
    @State var showSettings = false
    @State var showPrivacyCenter = false
    @State var showPrivacyPolicy = false
    @State var DNS = settings.bool(forKey: "donnotSell")
    @State var newPolicy = settings.bool(forKey: "newPrivacyPolicy")
    @State var showBanner = defaults.bool(forKey: "showBanner")
    @StateObject var observedHelper = Helper(otStatus: false)
    @StateObject var userFormValuesInstance = userFormValues()
    @State var bannerToggled = false
//    let stringURL = "https://dev.privacycenter.wb.com/index.php/wp-json/appdata/"
    var settingsResponse = 2
//    @State var activeSheet: ActiveSheet? = .none
    let bannerNotif1 = NotificationCenter.default
        .publisher(for: NSNotification.Name("fc"))
    let bannerNotif2 = NotificationCenter.default
        .publisher(for: NSNotification.Name("pc"))
    let bannerNotif3 = NotificationCenter.default
        .publisher(for: NSNotification.Name("tc"))
    let bannerNotif4 = NotificationCenter.default
        .publisher(for: NSNotification.Name("sc"))
    let bannerNotif5 = NotificationCenter.default
        .publisher(for: NSNotification.Name("BG34"))
    let bannerNotif6 = NotificationCenter.default
        .publisher(for: NSNotification.Name("generic"))
    //    @State var Reasons: [String] = ["onHideBanner()", "onBannerClickedAcceptAll()", "onBannerClickedRejectAll()"]
    //    let catchAll: AnyPublisher<Reasons, Never>

    @State var isShowingPopover = false

    var body: some View {
        //        GeometryReader { gr2 in
        VStack {
            HStack {
                Button(action: {
                    //                    self.isShowingPopover.toggle()
                }) {
                    Image("user").resizable().frame(width: screenWidth * 0.05, height: screenWidth * 0.05, alignment: .bottom).foregroundColor(.white).onTapGesture {
                        self.isShowingPopover.toggle()
                    }.onLongPressGesture {
                        //                        self.isShowingPopover.toggle()
                    }
                }
                //                .popover(isPresented: $isShowingPopover) {
                //                    Text("Hi from a popover")
                //                        .padding()
                //                        .frame(width: 320, height: 100)
                //                }
                Text("WARNERMEDIA PRIVACY TEST").frame(width: screenWidth * 0.8, height: screenHeight * 0.05, alignment: .center).font(.headline)
                //                Button(action: {
                //                    activeSheet = .second
                ////                    self.showSettings.toggle()
                //                    print("settings = \(showSettings)")
                //                }) {
                //                    Image("settings").resizable().frame(width: screenWidth * 0.05, height: screenWidth * 0.05, alignment: .bottom).foregroundColor(.white)
                //                }.sheet(isPresented: self.$showSettings, content: {
                //                    settingsModal()
                //                })
            }.frame(width: screenWidth, height: screenHeight * 0.1, alignment: .bottom)
                .background(Color(wbblue))
                .foregroundColor(.white)
                .padding(.bottom, 0)

            TabView {
                view1()
                    .tabItem {
                        VStack {
                            Image("home").resizable()
                            Text("Home")
                        }
                    }
                view2()
                    .tabItem {
                        VStack {
                            Image("local").resizable().frame(width: screenWidth * 0.05, height: screenWidth * 0.05, alignment: .center)
                            Text("Local")
                        }
                    }
                NavigationView {
                    if locationCache.object(forKey: NSString(stringLiteral: "location")) == "United States" {
                        settingsTabUS(userFormValuesInstance: userFormValuesInstance, observedHelper: observedHelper)
                    } else if locationCache.object(forKey: NSString(stringLiteral: "region")) == "EEA" {
                        settingsTab(userFormValuesInstance: userFormValuesInstance, observedHelper: observedHelper)
                    } else {
                        defaultSettings(userFormValuesInstance: userFormValuesInstance, observedHelper: observedHelper)
                    }
//                    settingsTab(userFormValuesInstance: userFormValuesInstance, observedHelper: observedHelper)
                }

                .tabItem {
                    VStack {
                        Image("settings").resizable().frame(width: screenWidth * 0.05, height: screenHeight * 0.05, alignment: .center)
                        Text("Settings")
                    }
                }
            }.edgesIgnoringSafeArea(.top).padding(.top, 0)
        }.edgesIgnoringSafeArea(.top)
            .background(Color(UIColor.systemGray5))
            .onAppear {
                if OTPublishersHeadlessSDK.shared.getCommonData() != nil {
                    if OTPublishersHeadlessSDK.shared.shouldShowBanner() {
                        observedHelper.showOneTrust = true
                    }
                }
            }
            .sheet(isPresented: $observedHelper.showOneTrust, content: {
                oneTrustBannerView().background(BackgroundClearView())
            })
            .onReceive(bannerNotif1, perform: { _ in
                if observedHelper.showOneTrust == true {
                    observedHelper.showOneTrust.toggle()
                }
            })
            .onReceive(bannerNotif2, perform: { _ in
                if observedHelper.showOneTrust == true {
                    observedHelper.showOneTrust.toggle()
                }
            })
            .onReceive(bannerNotif3, perform: { _ in
                if observedHelper.showOneTrust == true {
                    observedHelper.showOneTrust.toggle()
                }
            })
            .onReceive(bannerNotif4, perform: { _ in
                if observedHelper.showOneTrust == true {
                    observedHelper.showOneTrust.toggle()
                }
            })
            .onReceive(bannerNotif5, perform: { _ in
                if observedHelper.showOneTrust == true {
                    observedHelper.showOneTrust.toggle()
                }
            })
            .onReceive(bannerNotif6, perform: { _ in
                if observedHelper.showOneTrust == true {
                    observedHelper.showOneTrust.toggle()
                }
            })
            .alert(isPresented: $newPolicy) {
                Alert(title: Text("Updated Privacy Policy"), message: Text("Our Privacy Policy has been updated. Tap View to open the updated policy."), primaryButton: .default(Text("View"), action: {
                    settings.set(false, forKey: "newPrivacyPolicy")
                    self.newPolicy.toggle()
                }), secondaryButton: .default(Text("OK"), action: {
                    settings.set(false, forKey: "newPrivacyPolicy")
                    self.newPolicy.toggle()
                }))
            }
            .alert(isPresented: $isShowingPopover) {
                Alert(title: Text("User"), message: Text(defaults.string(forKey: "email") ?? "test@warnermedia.com"), dismissButton: .default(Text("Dismiss")))
            }
    }
}

// Function to log anything to the console
// params: String to log
func consoleLog(log: String) {
    print(log)
}

// Content Preview for the Canvas
struct ContentView_Previews: PreviewProvider {
//    @State var sheet: ActiveSheet? = .first

    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
//        @State var asheet: ActiveSheet? = .first

        var body: some View {
            ContentView()
        }
    }
}

// class LocationViewModel: NSObject, ObservableObject{
//
//  @Published var userLatitude: Double = 0
//  @Published var userLongitude: Double = 0
//
//  private let locationManager = CLLocationManager()
//
//  override init() {
//    super.init()
//    self.locationManager.delegate = self
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    self.locationManager.requestWhenInUseAuthorization()
//    self.locationManager.startUpdatingLocation()
//  }
// }
//
// extension LocationViewModel: CLLocationManagerDelegate {
//
//  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//    guard let location = locations.last else { return }
//    userLatitude = location.coordinate.latitude
//    userLongitude = location.coordinate.longitude
//    print(location)
//  }
// }
