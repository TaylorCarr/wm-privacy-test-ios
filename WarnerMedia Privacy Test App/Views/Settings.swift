//
//  Settings.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 4/17/20.
//  Copyright © 2020 T Carr. All rights reserved.
//

// import PrismiOS
import Combine
// import OTPublishersSDK
import OTPublishersHeadlessSDK
import SwiftUI

// MARK: CCPA Toggle

struct CCPAToggle: View {
    @ObservedObject var DNS: DNSDelegate

    var body: some View {
        Toggle(isOn: self.$DNS.DNS.toggle) {
            Text("Do Not Sell My Personal Information")
        }.alert(isPresented: $DNS.DNS.showAlert, content: { DNS.DNS.confirmationAlert })
    }
}

class userFormValues: ObservableObject {
    @Published var oneTrustAppID: String = defaults.string(forKey: "oneTrustAppID") ?? "712b900c-0d11-4172-b2b6-b22da559e2b5-test"
    @Published var appAssetId: String = defaults.string(forKey: "appAssetId") ?? "WBMOBI000001012"
    @Published var appName: String = defaults.string(forKey: "appName") ?? "Boomerang"
    @Published var buildVersion: String = defaults.string(forKey: "buildVersion") ?? "2.12"
    @Published var platform: String = defaults.string(forKey: "platform") ?? "iOS"
    @Published var firstName: String = defaults.string(forKey: "firstName") ?? ""
    @Published var lastName: String = defaults.string(forKey: "lastName") ?? ""
    @Published var email: String = defaults.string(forKey: "email") ?? "test@warnermedia.com"
//    var platforms: [String] = ["iOS", "Android", "Web"]
    @Published var previewIndex = defaults.integer(forKey: "platformIndex")
    @Published var privacyCenterDomain = defaults.string(forKey: "privacyCenterDomain") ?? "qa.privacycenter.wb.com"
    @Published var bearerToken = defaults.string(forKey: "bearerToken") ?? "vVZidbBIpOpfO80HjF0MC6pEGIMOhz"
    @Published var alternateIdType = defaults.string(forKey: "alternateIdType") ?? ""
    @Published var alternateId = defaults.string(forKey: "alternateId") ?? ""
    @Published var context = defaults.string(forKey: "context") ?? ""
}

// MARK: CCPA Settings View

struct CCPASettings: View {
    @State var showSettings = false
    @State var showPrivacyCenter = false
    @State var showPrivacyPolicy = false
    @State var showThirdParties = false
    @ObservedObject var DNSToggleOG = DNSDelegate()
    @ObservedObject var observedHelper: Helper
    @StateObject var userFormValuesInstance = userFormValues()

    var body: some View {
        VStack {
            Group {
                Text("Do Not Sell My Personal Information").font(.headline).padding(.vertical).frame(width: screenWidth * 0.9, alignment: .leading)
                Text("For California residents only, pursuant to the California Consumer Privacy Act (CCPA)").padding(.vertical).frame(width: screenWidth * 0.9, alignment: .leading)
                Text("This option stops the sharing of personal information with third parties for only this app on this device. To learn more about how your data is shared and for more options, including ways to opt-out across other Warner Bros. properties,").padding(.top)
                HStack(spacing: 0) {
                    Text("please visit the ")
                    Button(action: {
                        self.showPrivacyCenter.toggle()
                    }) {
                        Text("Privacy Center").padding(0).foregroundColor(.blue)
                    }
                    Text(".")
                }
            }.frame(width: screenWidth * 0.9, alignment: .leading)

            CCPAToggle(DNS: DNSToggleOG).frame(width: screenWidth * 0.9, alignment: .leading).padding(.vertical)
            Divider()
            Spacer()
        }.navigationBarTitle("CCPA Settings", displayMode: .inline)
            .sheet(isPresented: $showPrivacyCenter, content: {
                privacyCenter(userFormValuesInstance: userFormValuesInstance, observedHelper: observedHelper)
            })
    }
}

// MARK: Console Box

struct consoleBox: View {
    var body: some View {
        VStack {
            Text(verbatim: "\(logPrivacyDNSCurrentState())")
        }
    }
}

// MARK: GDPR Settings View

struct GDPRSettings: View {
    @State var showPrivacyCenter = false
    @State var showPrivacyPolicy = false
    @State var DNS = settings.bool(forKey: "donnotSell")
    @ObservedObject var DNSToggleOG = DNSDelegate()
    let stringURL = "https://www.yahoo.com"

    var body: some View {
        VStack {
            Toggle(isOn: self.$DNSToggleOG.DNS.toggle) {
                Text("Do Not Sell")
            }.padding()
            Button(action: {
                self.showPrivacyPolicy.toggle()
            }) {
                Text("EEA Privacy Policy")
            }.sheet(isPresented: self.$showPrivacyPolicy, content: {
                Text("EEA Privacy Policy")
            })
            Spacer().frame(height: screenHeight * 0.05)
            Button(action: {
                self.showPrivacyCenter.toggle()
            }) {
                Text("EEA Privacy Center")
            }.sheet(isPresented: self.$showPrivacyCenter, content: {
                Text("GDPR Privacy Center")
            })
            Spacer()
        }.navigationBarTitle("GDPR Settings", displayMode: .inline)
    }
}

// MARK: Default Settings View

struct defaultSettings: View {
    @State var showView = false
    @State var showUserForm = true
    @ObservedObject var userFormValuesInstance: userFormValues

//    @State var purposeStates: [Bool] = []
    @State var systemLanguage = languageCache.object(forKey: NSString(stringLiteral: "systemLanguage")) ?? "English"
//    @State var languages:[Language] = [Language(id: 0, language: "English", isFavorite: true), Language(id: 1, language: "Spanish", isFavorite: false)]
    @State var dnsToggle = false
    @State var isNavigationBarHidden: Bool = true
    @ObservedObject var observedHelper: Helper

    var body: some View {
        GeometryReader { _ in
            VStack {
                Group {
                    List {
                        Section(header: Text("General")) {
                            NavigationLink("Help", destination: helpView())
                            NavigationLink("Language: \(systemLanguage)", destination: languageView(observedHelper: observedHelper)).padding(0)
                            Text("Location: \(locationCache.object(forKey: NSString(stringLiteral: "location")) ?? "Unavailable")")
//                            NavigationLink("User Form", destination: userForm(userFormValuesInstance: userFormValuesInstance, showView: self.$showView), isActive: self.$showView)
                        }.padding(.vertical)
                        Section(header: Text("Privacy")) {
                            NavigationLink("Privacy Info", destination: privacySettings())
//                            Button(action: {
//                                self.dnsToggle.toggle()
//                            }) {
//                                VStack {
//                                    Toggle(isOn: self.$dnsToggle, label: {
//                                        Text("Do Not Sell My Info")
//                                    }).frame(width: screenWidth * 0.8)
//                                    Text("For California residents only, pursuant to the California Consumer Privacy Act (CCPA)").padding(.vertical).frame(width: screenWidth * 0.8, alignment: .leading)
//                                    Text("This option stops the sharing of personal information with third parties for only this app on this device. To learn more about how your data is shared and for more options, including ways to opt-out across other Warner Bros. properties, please visit the Privacy Center").padding(.top).frame(width: screenWidth * 0.8)
//                                }
//                            }
                            NavigationLink("Privacy Center", destination: privacyCenter(userFormValuesInstance: userFormValuesInstance, observedHelper: observedHelper)).padding(0)
                        }.padding(.vertical)
                    }
                }
            }
            .navigationBarHidden(true)
            .foregroundColor(Color("textColor"))
            .onAppear {
                systemLanguage = languageCache.object(forKey: NSString(stringLiteral: "systemLanguage")) ?? "English"
                self.isNavigationBarHidden = true
            }
        }
    }
}

// MARK: Settings Tab US

// Settings view that loads when the gear icon is selected
struct settingsTabUS: View {
    @StateObject var helper = Helper(otStatus: false)
//    @State var returnInt = 2
    //    @State var sdkInteractionBroadcastKey = OTConstants.OTNotification.sdkInteractedWith
//    @State var showPrivacyCenter = false
//    @State var showActivityIndicator = false
//    @State var showPreferenceCenter = false
//    @State var showOneTrustNative = false
    @State var showView = false
    @State var showUserForm = true
    @ObservedObject var userFormValuesInstance: userFormValues
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

//    @State var purposeStates: [Bool] = []
    @State var systemLanguage = languageCache.object(forKey: NSString(stringLiteral: "systemLanguage")) ?? "English"
//    @State var languages:[Language] = [Language(id: 0, language: "English", isFavorite: true), Language(id: 1, language: "Spanish", isFavorite: false)]
    @State var dnsToggle = false
    @State var isNavigationBarHidden: Bool = true
    @ObservedObject var observedHelper: Helper

    var body: some View {
        GeometryReader { _ in
            VStack {
                Group {
                    List {
                        Section(header: Text("General")) {
                            NavigationLink("Help", destination: helpView())
                            NavigationLink("Language: \(systemLanguage)", destination: languageView(observedHelper: observedHelper)).padding(0)
                            Text("Location: \(locationCache.object(forKey: "location") ?? "Unavailable")")
                            NavigationLink("User Form", destination: userForm(userFormValuesInstance: userFormValuesInstance, showView: self.$showView), isActive: self.$showView)
                        }.padding(.vertical)
                        Section(header: Text("Privacy")) {
                            NavigationLink("Privacy Info", destination: privacySettings())
                            Button(action: {
                                helper.showOneTrust.toggle()
                            }) {
                                Text("Privacy Settings")
                            }
                            Button(action: {
//                                self.dnsToggle.toggle()
//                                observedHelper.dns.toggle()
                                print("dns toggled")
//                                dnsCache.setObject(NSNumber(booleanLiteral: observedHelper.dns), forKey: NSString(stringLiteral: "donotSell"))
//                                defaults.set(observedHelper.dns, forKey: "donotSell")
//                                print("dns button onTap: \(observedHelper.dns)")
                                ////                                        print("dns toggle onTap: \(defaults.object(forKey: "donotSell"))")
//                                print("dns button cache onTap \(dnsCache.object(forKey: NSString(stringLiteral: "donotSell")))")
                            }) {
                                VStack {
                                    Toggle(isOn: $observedHelper.dns, label: {
//                                    Toggle(isOn: self.$dnsToggle, label: {
                                        Text("Do Not Sell My Info")
                                    }).frame(width: screenWidth * 0.8)
                                        .onTapGesture {
//                                        defaults.set(observedHelper.dns, forKey: "donotSell")
                                            dnsCache.setObject(NSNumber(booleanLiteral: !observedHelper.dns), forKey: NSString(stringLiteral: "donotSell"))
                                            defaults.set(!observedHelper.dns, forKey: "donotSell")
                                        }
                                    Text("For California residents only, pursuant to the California Consumer Privacy Act (CCPA)").padding(.vertical).frame(width: screenWidth * 0.8, alignment: .leading)
                                    Text("This option stops the sharing of personal information with third parties for only this app on this device. To learn more about how your data is shared and for more options, including ways to opt-out across other Warner Bros. properties, please visit the Privacy Center").padding(.top).frame(width: screenWidth * 0.8)
                                }
                            }.onAppear {}
                                .disabled(false)
                            NavigationLink("Privacy Center", destination: privacyCenter(userFormValuesInstance: userFormValuesInstance, observedHelper: observedHelper)).padding(0)
                        }.padding(.vertical)
                    }
                }
            }
            .navigationBarHidden(true)
            .foregroundColor(Color("textColor"))
            .onAppear {
                systemLanguage = languageCache.object(forKey: NSString(stringLiteral: "systemLanguage")) ?? "English"
                self.isNavigationBarHidden = true
            }
            .sheet(isPresented: $helper.showOneTrust, content: {
                oneTrustNativeView().background(BackgroundClearView())
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
        }
    }
}

// MARK: Settings Tab

// Settings view that loads when the gear icon is selected
struct settingsTab: View {
    @StateObject var helper = Helper(otStatus: false)
    @ObservedObject var userFormValuesInstance: userFormValues
    @ObservedObject var observedHelper: Helper
//    @State var returnInt = 2
    //    @State var sdkInteractionBroadcastKey = OTConstants.OTNotification.sdkInteractedWith
//    @State var showPrivacyCenter = false
    @State var showActivityIndicator = false
    @State var showPreferenceCenter = false
//    @State var showOneTrustNative = false
    @State var showView = false
//    @State var showUserForm = true

//    @State var purposeStates: [Bool] = []
    @State var systemLanguage = languageCache.object(forKey: NSString(stringLiteral: "systemLanguage")) ?? "English"
//    @State var languages:[Language] = [Language(id: 0, language: "English", isFavorite: true), Language(id: 1, language: "Spanish", isFavorite: false)]
//    @State var dnsToggle = false
    @State var isNavigationBarHidden: Bool = true
//    @StateObject var userFormValuesInstance = userFormValues()

    let pub1 = NotificationCenter.default
        .publisher(for: NSNotification.Name("fc"))
    let pub2 = NotificationCenter.default
        .publisher(for: NSNotification.Name("pc"))
    let pub3 = NotificationCenter.default
        .publisher(for: NSNotification.Name("sc"))
    let pub4 = NotificationCenter.default
        .publisher(for: NSNotification.Name("smc"))
    let pub5 = NotificationCenter.default
        .publisher(for: NSNotification.Name("tc"))
    let pub6 = NotificationCenter.default
        .publisher(for: NSNotification.Name("tpv"))
    let pub7 = NotificationCenter.default
        .publisher(for: NSNotification.Name("moi"))
    let pub8 = NotificationCenter.default
        .publisher(for: NSNotification.Name("apc"))
    let pub9 = NotificationCenter.default
        .publisher(for: NSNotification.Name("BG34"))
    let pub10 = NotificationCenter.default
        .publisher(for: NSNotification.Name("generic"))

    var body: some View {
        GeometryReader { _ in
            VStack {
                Group {
                    List {
                        Section(header: Text("General")) {
                            NavigationLink("Help", destination: helpView())
                            NavigationLink("Language: \(systemLanguage)", destination: languageView(observedHelper: observedHelper)).padding(0)
                            Text("Location: \(locationCache.object(forKey: "location") ?? "Unavailable")")
                            NavigationLink("User Form", destination: userForm(userFormValuesInstance: userFormValuesInstance, showView: self.$showView), isActive: self.$showView)
                        }.padding(.vertical)
                        Section(header: Text("Privacy")) {
                            NavigationLink("Privacy Info", destination: privacySettings())
                            NavigationLink("Privacy Center", destination: privacyCenter(userFormValuesInstance: userFormValuesInstance, observedHelper: observedHelper)).padding(0)
                            Button(action: {
                                helper.showOneTrust.toggle()
                            }) {
                                Text("Privacy Settings")
                            }
                        }.padding(.vertical)
                    }
                }
            }
            .navigationBarHidden(true)
            .foregroundColor(Color("textColor"))
//            .sheet(isPresented: self.$showPrivacyCenter, content: {
//                privacyCenter()
//            })
            .sheet(isPresented: $helper.showOneTrust, content: {
                oneTrustNativeView().background(BackgroundClearView())
            })
            .onAppear {
                systemLanguage = languageCache.object(forKey: NSString(stringLiteral: "systemLanguage")) ?? "English"
                self.isNavigationBarHidden = true
            }
            .onReceive(pub1, perform: { _ in
                if helper.showOneTrust == true {
                    helper.showOneTrust.toggle()
                }
            })
            .onReceive(pub2, perform: { _ in
                if helper.showOneTrust == true {
                    helper.showOneTrust.toggle()
                }
            })
            .onReceive(pub3, perform: { _ in
                if helper.showOneTrust == true {
                    helper.showOneTrust.toggle()
                }
            })
            .onReceive(pub4, perform: { _ in
                if helper.showOneTrust == true {
                    helper.showOneTrust.toggle()
                }
            })
            .onReceive(pub5, perform: { _ in
                if helper.showOneTrust == true {
                    helper.showOneTrust.toggle()
                }
            })
            .onReceive(pub6, perform: { _ in
                if helper.showOneTrust == true {
                    helper.showOneTrust.toggle()
                }
            })
            .onReceive(pub7, perform: { _ in
                if helper.showOneTrust == true {
                    helper.showOneTrust.toggle()
                }
            })
            .onReceive(pub8, perform: { _ in
                if helper.showOneTrust == true {
                    helper.showOneTrust.toggle()
                }
            })
            .onReceive(pub9, perform: { _ in
                if helper.showOneTrust == true {
                    helper.showOneTrust.toggle()
                }
            })
            .onReceive(pub10, perform: { _ in
                if helper.showOneTrust == true {
                    helper.showOneTrust.toggle()
                }
            })
        }
    }
}

// MARK: Settings Tab DEFAULT

// Settings view that loads when the gear icon is selected
struct settingsTabDefault: View {
//    @StateObject var helper = Helper(otStatus: false)
//    @State var returnInt = 2
    //    @State var sdkInteractionBroadcastKey = OTConstants.OTNotification.sdkInteractedWith
//    @State var showPrivacyCenter = false
//    @State var showActivityIndicator = false
//    @State var showPreferenceCenter = false
//    @State var showOneTrustNative = false
    @State var showView = false
    @State var showUserForm = true
//    @ObservedObject var userFormValuesInstance: userFormValues
    @ObservedObject var observedHelper: Helper

//    @State var purposeStates: [Bool] = []
    @State var systemLanguage = languageCache.object(forKey: NSString(stringLiteral: "systemLanguage")) ?? "English"
//    @State var languages:[Language] = [Language(id: 0, language: "English", isFavorite: true), Language(id: 1, language: "Spanish", isFavorite: false)]
    @State var dnsToggle = false
    @State var isNavigationBarHidden: Bool = true

    var body: some View {
        GeometryReader { _ in
            VStack {
                Group {
                    List {
                        Section(header: Text("General")) {
                            NavigationLink("Help", destination: helpView())
                            NavigationLink("Language: \(systemLanguage)", destination: languageView(observedHelper: observedHelper)).padding(0)
//                            NavigationLink("User Form", destination: userForm(userFormValuesInstance: userFormValuesInstance, showView: self.$showView), isActive: self.$showView)
                        }.padding(.vertical)
                        Section(header: Text("Privacy")) {
                            NavigationLink("Privacy Info", destination: privacySettings())
//                            Button(action: {
//                                self.dnsToggle.toggle()
//                            }) {
//                                VStack {
//                                    Toggle(isOn: self.$dnsToggle, label: {
//                                        Text("Do Not Sell My Info")
//                                    }).frame(width: screenWidth * 0.8)
//                                    Text("For California residents only, pursuant to the California Consumer Privacy Act (CCPA)").padding(.vertical).frame(width: screenWidth * 0.8, alignment: .leading)
//                                    Text("This option stops the sharing of personal information with third parties for only this app on this device. To learn more about how your data is shared and for more options, including ways to opt-out across other Warner Bros. properties, please visit the Privacy Center").padding(.top).frame(width: screenWidth * 0.8)
//                                }
//                            }
//                            NavigationLink("Privacy Center", destination: privacyCenter(userFormValuesInstance: userFormValuesInstance)).padding(0)
                        }.padding(.vertical)
                    }
                }
            }
            .navigationBarHidden(true)
            .foregroundColor(Color("textColor"))
            .onAppear {
                systemLanguage = languageCache.object(forKey: NSString(stringLiteral: "systemLanguage")) ?? "English"
                self.isNavigationBarHidden = true
            }
        }
    }
}

// extension OneTrustNativeVC: OTEventListener {
//    func allSDKViewsDismissed(interactionType: ConsentInteractionType) {
//        @ObservedObject var helper = Helper()
//        print("OTHeadlessSDK: interaction felt")
//        helper.showOneTrust.toggle()
//
//        if(helper.showOneTrust == true) {
//            helper.showOneTrust = false
//        }
//    }
// }

struct privacySettings: View {
    var body: some View {
        GeometryReader { _ in
            VStack {
                Group {
                    List {
                        NavigationLink("Privacy Policy", destination: privacyPolicy()).padding(.vertical)
                        NavigationLink("Terms of Use", destination: termsOfService()).padding(.vertical)
                        NavigationLink("Ad Choices", destination: adChoices()).padding(.vertical)
                    }
                }
            }.navigationBarTitle("Privacy Settings", displayMode: .large)
                .foregroundColor(Color("textColor"))
        }
    }
}

// MARK: Help View

struct helpView: View {
    var body: some View {
        VStack {
            Text("To customize the payload data sent to the privacy center, navigate to Settings -> User Form, make the desired changes, then click save in the upper right").padding()
            Spacer()
        }.navigationBarTitle("Help", displayMode: .large)
            .foregroundColor(Color("textColor"))
    }
}

// MARK: User Form

struct userForm: View {
//    @State var appAssetId: String = defaults.string(forKey: "appAssetId") ?? "WBMOBI000001012"
//    @State var appName: String = defaults.string(forKey: "appName") ?? "Boomerang"
//    @State var buildVersion: String = defaults.string(forKey: "buildVersion") ?? "2.12"
//    @State var platform: String = defaults.string(forKey: "platform") ?? "iOS"
//    @State var firstName: String = defaults.string(forKey: "firstName") ?? ""
//    @State var lastName: String = defaults.string(forKey: "lastName") ?? ""
//    @State var email: String = defaults.string(forKey: "email") ?? "test@warnermedia.com"
    var platforms: [String] = ["iOS", "Android", "Web"]
//    @State private var previewIndex = defaults.integer(forKey: "platformIndex")
//    @State var privacyCenterDomain = defaults.string(forKey: "privacyCenterDomain") ?? "qa.privacycenter.wb.com"
//    @State var bearerToken = defaults.string(forKey: "bearerToken") ?? "vVZidbBIpOpfO80HjF0MC6pEGIMOhz"
//    @State var alternateIdType = defaults.string(forKey: "alternateIdType") ?? ""
//    @State var alternateId = defaults.string(forKey: "alternateId") ?? ""
//    @State var context = defaults.string(forKey: "context") ?? ""
    @ObservedObject var userFormValuesInstance: userFormValues
    @Environment(\.presentationMode) var presentationMode
    @Binding var showView: Bool

    // (appDetails: ["appAssetId": "WBMOBI000001012", "appName" : "Boomerang", "additionalInfo" : "Build Version:2.12;AppPlatform:iOS;"], userDetails: ["firstName": nil, "lastName" : nil, "email" : "rgrier@dramafever.com", "country" : "US"], requestType: "DO_NOT_SELL", alternateIds: [["idType" : alternateIdType, "id" : alternateId, "context" : context]])

    var body: some View {
        VStack {
            Form {
                Section(header: Text("OneTrust")) {
                    HStack {
                        Text("AppID:         ")
                        TextField("Test App ID", text: $userFormValuesInstance.oneTrustAppID)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            .disableAutocorrection(true)
                            .autocapitalization(.allCharacters)
                    }
                }
                Section(header: Text("General")) {
                    HStack {
                        Text("Domain:         ")
                        TextField("Domain", text: $userFormValuesInstance.privacyCenterDomain)
                            .keyboardType(.webSearch)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                    HStack {
                        Text("Bearer Token:")
                        TextField("Bearer Token", text: $userFormValuesInstance.bearerToken)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                }
                Section(header: Text("App Details")) {
                    HStack {
                        Text("App Asset ID: ")
                        TextField("App Asset ID", text: $userFormValuesInstance.appAssetId)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                    HStack {
                        Text("App Name:     ")
                        TextField("App Name", text: $userFormValuesInstance.appName)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            .keyboardType(.default)
                            .disableAutocorrection(true)
                            .autocapitalization(.words)
                    }
                    Picker(selection: $userFormValuesInstance.previewIndex, label: Text("Platform")) {
                        ForEach(0 ..< platforms.count) {
                            Text(self.platforms[$0])
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    HStack {
                        Text("Build Version:")
                        TextField("Build Version", text: $userFormValuesInstance.buildVersion)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                    }
                }
                Section(header: Text("User Details")) {
                    HStack {
                        Text("First Name: ")
                        TextField("First Name", text: $userFormValuesInstance.firstName)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            .disableAutocorrection(true)
                            .autocapitalization(.words)
                    }
                    HStack {
                        Text("Last Name: ")
                        TextField("Last Name", text: $userFormValuesInstance.lastName)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            .disableAutocorrection(true)
                            .autocapitalization(.words)
                    }
                    HStack {
                        Text("Email:           ")
                        TextField("Email", text: $userFormValuesInstance.email)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                }
                Section(header: Text("Alternate ID")) {
                    HStack {
                        Text("Alternate ID Type:")
                        TextField("Alternate ID Type", text: $userFormValuesInstance.alternateIdType)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            .disableAutocorrection(true)
                            .autocapitalization(.allCharacters)
                    }
                    HStack {
                        Text("Alternate ID:         ")
                        TextField("Alternate ID", text: $userFormValuesInstance.alternateId)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            .disableAutocorrection(true)
                            .autocapitalization(.allCharacters)
                    }
                    HStack {
                        Text("Context:                ")
                        TextField("Context", text: $userFormValuesInstance.context)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                }
                Section {
                    Button(action: {
                        defaults.setValue(userFormValuesInstance.alternateId, forKey: "alternateId")
                        defaults.setValue(userFormValuesInstance.appName, forKey: "appName")
                        defaults.setValue(userFormValuesInstance.previewIndex, forKey: "platformIndex")
                        defaults.setValue(userFormValuesInstance.appAssetId, forKey: "appAssetId")
                        defaults.setValue(userFormValuesInstance.previewIndex, forKey: "platformIndex")

                        if userFormValuesInstance.previewIndex == 0 {
                            defaults.setValue("iOS", forKey: "platform")
                        } else if userFormValuesInstance.previewIndex == 1 {
                            defaults.setValue("Android", forKey: "platform")
                        } else {
                            defaults.setValue("Web", forKey: "platform")
                        }

                        if userFormValuesInstance.firstName == "" {
                            defaults.setValue(nil, forKey: "firstName")
                        } else {
                            defaults.setValue(userFormValuesInstance.firstName, forKey: "firstName")
                        }

                        if userFormValuesInstance.lastName == "" {
                            defaults.setValue(nil, forKey: "lastName")
                        } else {
                            defaults.setValue(userFormValuesInstance.lastName, forKey: "lastName")
                        }

                        if userFormValuesInstance.email == "" {
                            defaults.setValue(nil, forKey: "email")
                        } else {
                            defaults.setValue(userFormValuesInstance.email, forKey: "email")
                        }

                        if userFormValuesInstance.privacyCenterDomain == "" {
                            defaults.setValue("qa.privacycenter.wb.com", forKey: "privacyCenterDomain")
                        } else {
                            defaults.setValue(userFormValuesInstance.privacyCenterDomain.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "privacyCenterDomain")
                            print("saved url (string): \(defaults.string(forKey: "privacyCenterDomain"))")
                            print("saved url (object): \(defaults.object(forKey: "privacyCenterDomain"))")
                        }

                        defaults.setValue(userFormValuesInstance.alternateId, forKey: "alternateId")
                        defaults.setValue(userFormValuesInstance.alternateIdType, forKey: "alternateIdType")
                        defaults.setValue(userFormValuesInstance.context, forKey: "context")

                        if userFormValuesInstance.oneTrustAppID.trimmingCharacters(in: .whitespacesAndNewlines) != defaults.string(forKey: "oneTrustAppID"), userFormValuesInstance.oneTrustAppID.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                            defaults.setValue(userFormValuesInstance.oneTrustAppID, forKey: "oneTrustAppID")

                            if regionCache.object(forKey: "region") == "EEA" {
//                                OTPublishersHeadlessSDK.shared.clearOTSDKData()
                                let sdkParams = OTSdkParams(countryCode: nil, regionCode: nil)
                                //        sdkParams.setProfileSyncParams(profileSyncParams)
                                sdkParams.setShouldCreateProfile("true")

                                let domainUrl = "cdn.cookielaw.org",
                                    domainId = userFormValuesInstance.oneTrustAppID,
                                    language = UserDefaults.standard.string(forKey: "systemLanguage") ?? "en-US"

                                OTPublishersHeadlessSDK.shared.startSDK(storageLocation: domainUrl, domainIdentifier: domainId, languageCode: language, params: sdkParams) { response in
                                    print("OTT Data fetch result \(response.responseString != nil) and error \(String(describing: response.error?.localizedDescription))")
                                }
                            }
                        }
                        presentationMode.wrappedValue.dismiss()
//                        self.showView = false
                    }) {
                        Text("SAVE").frame(alignment: .center).foregroundColor(.blue)
                    }
                }
            }
        }.navigationBarTitle("User Form", displayMode: .large)
            .foregroundColor(Color("textColor"))
//        .navigationBarItems(trailing: Button(action: {
//            defaults.setValue(userFormValuesInstance.appAssetId, forKey: "appAssetId")
//            print("instance appAssetId: \(userFormValuesInstance.appAssetId)")
//            print("bound appAssetId: \($userFormValuesInstance.appAssetId)")
//            defaults.setValue(userFormValuesInstance.appName, forKey: "appName")
//            defaults.setValue(userFormValuesInstance.previewIndex, forKey: "platformIndex")
//            defaults.setValue(userFormValuesInstance.appAssetId, forKey: "appAssetId")
//            defaults.setValue(userFormValuesInstance.previewIndex, forKey: "platformIndex")
//
//            if(userFormValuesInstance.previewIndex == 0) {
//                defaults.setValue("iOS", forKey: "platform")
//            } else if (userFormValuesInstance.previewIndex == 1) {
//                defaults.setValue("Android", forKey: "platform")
//            } else {
//                defaults.setValue("Web", forKey: "platform")
//            }
//
//            if(userFormValuesInstance.firstName == "") {
//                defaults.setValue(nil, forKey: "firstName")
//            } else {
//                defaults.setValue(userFormValuesInstance.firstName, forKey: "firstName")
//            }
//
//            if(userFormValuesInstance.lastName == "") {
//                defaults.setValue(nil, forKey: "lastName")
//            } else {
//                defaults.setValue(userFormValuesInstance.lastName, forKey: "lastName")
//            }
//
//            if(userFormValuesInstance.email == "") {
//                defaults.setValue(nil, forKey: "email")
//            } else {
//                defaults.setValue(userFormValuesInstance.email, forKey: "email")
//            }
//
//            if(userFormValuesInstance.privacyCenterDomain == "") {
//                defaults.setValue("qa.privacycenter.wb.com", forKey: "privacyCenterDomain")
//            } else {
//                defaults.setValue(userFormValuesInstance.privacyCenterDomain, forKey: "privacyCenterDomain")
//            }
//            presentationMode.wrappedValue.dismiss()
//            self.showView = false
//
//            if(userFormValuesInstance.oneTrustAppID.trimmingCharacters(in: .whitespacesAndNewlines) != defaults.string(forKey: "oneTrustAppID") && userFormValuesInstance.oneTrustAppID.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
//                defaults.setValue(userFormValuesInstance.oneTrustAppID, forKey: "oneTrustAppID")
//            }
//        }){
//            Text("SAVE").background(Color(UIColor.clear)).foregroundColor(.clear).font(.headline)
//        })
            .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct oneTrustNativeView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> OneTrustNativeVC {
        let prefCenter = OneTrustNativeVC()
        prefCenter.mode = "preferenceCenter"
        return prefCenter
    }

    func updateUIViewController(_: OneTrustNativeVC, context _: Context) {}
}

struct oneTrustBannerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = OneTrustNativeVC

    func makeUIViewController(context _: Context) -> OneTrustNativeVC {
        let banner = OneTrustNativeVC()
        banner.mode = "banner"
        return banner
    }

    func updateUIViewController(_: OneTrustNativeVC, context _: Context) {}
}

class observer: ObservableObject {
    // Category Observer Function
    @objc func actionConsent_SDK01(_ notification: Notification) {
        consoleLog(log: "Observer Called")
        let consentValue = notification.object as? String
        NSLog("SDK01 Consent Value = \(consentValue ?? "false")")
    }

    @objc func actionConsent_SDK02(_ notification: Notification) {
        let consentValue = notification.object as? String
        NSLog("SDK02 Consent Value = \(consentValue ?? "false")")
    }

    @objc func actionConsent_SDK03(_ notification: Notification) {
        let consentValue = notification.object as? String
        NSLog("SDK03 Consent Value = \(consentValue ?? "false")")
    }

    @objc func actionConsent_SDK04(_ notification: Notification) {
        let consentValue = notification.object as? String
        NSLog("SDK04 Consent Value = \(consentValue ?? "false")")
    }

    @objc func actionConsent_SDK05(_ notification: Notification) {
        let consentValue = notification.object as? String
        NSLog("SDK05 Consent Value = \(consentValue ?? "false")")
    }

    @objc func actionConsent_SoPD(_ notification: Notification) {
        let consentValue = notification.object as? String
        NSLog("SoPD Consent Value = \(consentValue ?? "false")")

        if consentValue == "true" {
            //            OTPublishersSDK.shared.optIntoSaleOfData()
            //            PrismSdk.shared.privacy.ccpaShareData()
//            prism.ccpaShareData()
            consoleLog(log: "SET CONSENT VALUE TO TRUE")
        } else {
            //            OTPublishersSDK.shared.optOutOfSaleOfData()
            //            PrismSdk.shared.privacy.ccpaDoNotShareData()
//            prism.ccpaDoNotShareData()
            consoleLog(log: "SET CONSENT VALUE TO FALSE")
        }
    }
}

// MARK: Debug View

// View to see the status of different strings and values when DNS is toggled
struct debugConsole: View {
    var body: some View {
        VStack {
            Spacer().frame(width: screenWidth, height: screenHeight * 0.1, alignment: .top)
            //            HStack (spacing: 0){
            //                List {
            //                    Text("")
            //                    Text("GDPR String: ")
            //                    Text("CCPA String: ")
            //                    Text("Analytics SDKs: ")
            //                    Text("Functional SDKs: ")
            //                    Text("Targeting SDKs: ")
            //                    Text("Social Media SDKs: ")
            //                    Text("Console: ")
            //                }
            //                List {
            //                    Text("")
            //                    Text("\(UserDefaults.standard.string(forKey: "IABTCF_TCString") ?? "nil")")
            //                    Text("\(UserDefaults.standard.string(forKey: "IABUSPrivacy_String") ?? "nil")")
            ////                    Text("\(OTPublishersSDK.shared.getConsentStatusForGroupId("SDK02"))")
            ////                    Text("\(OTPublishersSDK.shared.getConsentStatusForGroupId( "SDK03"))")
            ////                    Text("\(OTPublishersSDK.shared.getConsentStatusForGroupId("SDK04"))")
            ////                    Text("\(OTPublishersSDK.shared.getConsentStatusForGroupId("SDK05"))")
            //                    consoleBox()
            //                }
            //            }

            Text("purposes response: \((cache.object(forKey: "purposes"))?.description ?? " ")").foregroundColor(.black)
            Text("data subject response: \((cache.object(forKey: "dataSubjectResponse"))?.description ?? " ")").foregroundColor(.black)
            Text("consent response: \((cache.object(forKey: "consentResponse"))?.description ?? " ")").foregroundColor(.black)
            //            Spacer()
        }.navigationBarTitle("Debug Console", displayMode: .inline)
            .frame(width: screenWidth, height: screenHeight, alignment: .leading)
            .padding(0)
    }
}

// MARK: Privacy Policy

struct privacyPolicy: View {
    var privacyPolicyURL = URL(string: "https://policies.warnerbros.com/privacy/")!

    var body: some View {
        VStack {
            webView(url: privacyPolicyURL.absoluteString, request: URLRequest(url: privacyPolicyURL))
        }.navigationBarTitle("Privacy Policy", displayMode: .inline)
    }
}

// MARK: Terms of Service View

// Webview to load up the TOS page
struct termsOfService: View {
    var body: some View {
        VStack {
            webView(url: "https://policies.warnerbros.com/terms/en-us/", request: URLRequest(url: URL(string: "https://policies.warnerbros.com/terms/en-us/")!))
        }.navigationBarTitle("Terms of Service", displayMode: .inline)
    }
}

// MARK: Ad Choices

// Webview to load up the TOS page
struct adChoices: View {
    var body: some View {
        VStack {
            webView(url: "https://policies.warnerbros.com/privacy/en-us/#adchoices", request: URLRequest(url: URL(string: "https://policies.warnerbros.com/privacy/en-us/#adchoices")!))
        }.navigationBarTitle("Ad Choices", displayMode: .inline)
    }
}

// MARK: Privacy Center

// Webview to load the privacy center and pass user payload
@available(iOS 14.0, *)
struct privacyCenter: View {
//    let stringURL = "https://\(defaults.string(forKey: "privacyCenterDomain") ?? "qa.privacycenter.wb.com")/index.php/wp-json/appdata"
//    let appAssetId: String = defaults.string(forKey: "appAssetId") ?? "WBMOBI000001012"
//    let appName: String = defaults.string(forKey: "appName") ?? "Boomerang"
//    let buildVersion: String = defaults.string(forKey: "buildVersion") ?? "2.12"
//    let platform: String = defaults.string(forKey: "platform") ?? "iOS"
//    let firstName: String? = defaults.string(forKey: "firstName") ?? nil
//    let lastName: String? = defaults.string(forKey: "lastName") ?? nil
//    let email: String = defaults.string(forKey: "email") ?? "test@warnermedia.com"
//    @State var alternateIdType: String = defaults.string(forKey: "alternateIdType") ?? ""
//    @State var alternateId: String = defaults.string(forKey: "alternateId") ?? ""
//    @State var context: String = defaults.string(forKey: "context") ?? ""
//    var platforms: [String] = ["iOS", "Android", "Web"]
//    let previewIndex = defaults.integer(forKey: "platformIndex")
//    let privacyCenterDomain = defaults.string(forKey: "privacyCenterDomain") ?? "qa.privacycenter.wb.com"
//    let bearerToken = defaults.string(forKey: "bearerToken") ?? "vVZidbBIpOpfO80HjF0MC6pEGIMOhz"
    @ObservedObject var userFormValuesInstance: userFormValues
    @ObservedObject var observedHelper: Helper

    var body: some View {
        VStack {
            webView(url: "https://\(userFormValuesInstance.privacyCenterDomain)/index.php/wp-json/appdata/", request: self.prepRequest(stringURL: "https://\(userFormValuesInstance.privacyCenterDomain)/index.php/wp-json/appdata/"))

//            webView(url: "https://webhook.site/7d66ca71-62d9-4690-837f-3d13f005fc3e", request: self.prepRequest(stringURL: "https://webhook.site/7d66ca71-62d9-4690-837f-3d13f005fc3e"))
        }.navigationBarTitle("Privacy Center", displayMode: .inline)
            .onAppear {
                print("privacy center url string: \(userFormValuesInstance.privacyCenterDomain)")
            }
//        .onDisappear {
//        }
    }

    func prepRequest(stringURL: String) -> URLRequest {
        var package: payload

        if userFormValuesInstance.alternateId == "" && userFormValuesInstance.alternateId == "" && userFormValuesInstance.context == "" {
            if observedHelper.dns == true {
                package = payload(appDetails: ["appAssetId": userFormValuesInstance.appAssetId, "appName": userFormValuesInstance.appName, "additionalInfo": "Build Version:\(userFormValuesInstance.buildVersion);AppPlatform:\(userFormValuesInstance.platform);"], userDetails: ["firstName": userFormValuesInstance.firstName, "lastName": userFormValuesInstance.lastName, "email": userFormValuesInstance.email, "country": "US"], requestType: "DO_NOT_SELL")
            } else {
                package = payload(appDetails: ["appAssetId": userFormValuesInstance.appAssetId, "appName": userFormValuesInstance.appName, "additionalInfo": "Build Version:\(userFormValuesInstance.buildVersion);AppPlatform:\(userFormValuesInstance.platform);"], userDetails: ["firstName": userFormValuesInstance.firstName, "lastName": userFormValuesInstance.lastName, "email": userFormValuesInstance.email, "country": "US"])
            }

        } else {
            if observedHelper.dns == true {
                package = payload(appDetails: ["appAssetId": userFormValuesInstance.appAssetId, "appName": userFormValuesInstance.appName, "additionalInfo": "Build Version:\(userFormValuesInstance.buildVersion);AppPlatform:\(userFormValuesInstance.platform);"], userDetails: ["firstName": userFormValuesInstance.firstName, "lastName": userFormValuesInstance.lastName, "email": userFormValuesInstance.email, "country": "US"], alternateIds: [["idType": userFormValuesInstance.alternateIdType, "id": userFormValuesInstance.alternateId, "context": userFormValuesInstance.context]], requestType: "DO_NOT_SELL")
            } else {
                package = payload(appDetails: ["appAssetId": userFormValuesInstance.appAssetId, "appName": userFormValuesInstance.appName, "additionalInfo": "Build Version:\(userFormValuesInstance.buildVersion);AppPlatform:\(userFormValuesInstance.platform);"], userDetails: ["firstName": userFormValuesInstance.firstName, "lastName": userFormValuesInstance.lastName, "email": userFormValuesInstance.email, "country": "US"], alternateIds: [["idType": userFormValuesInstance.alternateIdType, "id": userFormValuesInstance.alternateId, "context": userFormValuesInstance.context]])
            }
        }

        let encoder = JSONEncoder()

        var req = URLRequest(url: URL(string: stringURL)!)

        req.httpMethod = "POST"
        req.httpBody = try! encoder.encode(package)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(userFormValuesInstance.bearerToken)", forHTTPHeaderField: "Authorization") // dev authorization
        //        req.setValue("Bearer rnUXeHa4MwCbgouARZTp8N9wz5YZ2m", forHTTPHeaderField: "Authorization") // prod authorization
//        req.setValue("DO_NOT_SELL", forHTTPHeaderField: "requestType")
        req.httpShouldHandleCookies = true
//        let decoder: JSONDecoder = JSONDecoder()
        consoleLog(log: "Header: \(req.allHTTPHeaderFields!)")
        consoleLog(log: "Body: \(String(data: req.httpBody!, encoding: .utf8)!)")
        return req
    }

    struct payload: Codable {
        var appDetails: [String: String]?
        var userDetails: [String: String?]
        var alternateIds: [[String: String?]?]?
        var requestType: String?
    }
}

// MARK: Universal Preference Center

struct universalPreferenceCenter: View {
    var purposes = cache.object(forKey: NSString(string: "purposes")) as? [purposeObject]
    @Binding var showView: Bool
    @State var purposeStates: [Bool] // = [] // fillArray(purposes: purposes)

    var body: some View {
        ScrollView {
            VStack {
                //                Spacer().frame(width: screenWidth, height: screenHeight * 0.025, alignment: .top)
                Text(verbatim: "This service is brought to you by Warner Bros. Entertainment inc.").foregroundColor(.black).frame(width: screenWidth * 0.93, height: screenHeight * 0.07, alignment: .leading)
                ForEach(0 ..< purposes!.count, id: \.self) { index in
                    Toggle(isOn: self.$purposeStates[index]) {
                        VStack(alignment: .leading) {
                            Text(purposes![index].label!).foregroundColor(.black)
                            Text(purposes![index].description ?? "").foregroundColor(.black).fontWeight(.ultraLight)
                        }
                    }.frame(height: screenHeight * 0.17).padding()
                    Divider()
                }
            }
            .navigationBarTitle("Consent Preferences")
            .navigationBarItems(trailing: Button(action: {
                self.showView = false
                print("saving settings")
                print(purposeStates)
                for i in 0 ..< purposes!.count {
                    settings.setValue(purposeStates[i], forKey: purposes![i].label!)
                }
                recordConsent()
            }) {
                Text("SAVE").background(Color(UIColor.clear)).foregroundColor(.white).font(.headline)
            })
            .onAppear {
                //                purposes?.forEach { index in
                //                    @State var temp = settings.bool(forKey: index.label ?? "")
                //                    purposeStates.append(temp)
                //                }
                purposeStates = fillArray(purposes: purposes!)
                print("Purposes count: \(purposes!.count)")
            }
        }
    }
}

func fillArray(purposes: [purposeObject]) -> [Bool] {
    var purposeStates: [Bool] = []
    //    var temp = false

    purposes.forEach { index in
        purposeStates.append(settings.bool(forKey: index.label!))
        print(purposeStates.count)
        print(purposeStates)
    }

    return purposeStates
}

// MARK: Preference Center

struct preferenceCenter: View {
    @State var firstPartyConsent = settings.bool(forKey: "firstPartyConsent")
    @State var newsletterConsent = settings.bool(forKey: "newsletterConsent")
    @State var productUpdatesChecked: Bool = settings.bool(forKey: "productUpdates")
    @State var promotionsChecked: Bool = settings.bool(forKey: "promotions")
    @Binding var showView: Bool

    @State var showSettings = false
    @State var showPrivacyCenter = false
    @State var showPrivacyPolicy = false
    @State var showThirdParties = false
    @ObservedObject var DNSToggleOG = DNSDelegate()

    let stringURL = "https://privacyportaltrial.onetrust.com/ui/#/preferences/multipage/login/535e1cbe-286c-4644-95e2-c3eeab895bfd"

    func toggleProductUpdated() {
        if newsletterConsent == true {
            productUpdatesChecked = !productUpdatesChecked
        }
    }

    func togglePromotionsChecked() {
        if newsletterConsent == true {
            promotionsChecked = !promotionsChecked
        }
    }

    var body: some View {
        ScrollView {
            VStack {
                Group {
                    Spacer().frame(width: screenWidth, height: screenHeight * 0.025, alignment: .top)
                    Text("This app is brought to you by Ellen Digital Ventures and its parent company Warner Bros. Entertainment Inc. (together \"Warner Bros.\").").padding(10)

                    Toggle(isOn: self.$firstPartyConsent) {
                        VStack(alignment: .leading) {
                            Text(cache.object(forKey: NSString(string: "purposeDetails1"))![0] as! String)
                            Text(cache.object(forKey: NSString(string: "purposeDetails1"))![1] as! String).fontWeight(.ultraLight) // .frame(height: screenHeight * 0.01)
                        }
                    }.frame(height: screenHeight * 0.07).padding()

                    Toggle(isOn: self.$newsletterConsent) {
                        VStack(alignment: .leading) {
                            Text(cache.object(forKey: NSString(string: "purposeDetails2"))![0] as! String)
                            Text(cache.object(forKey: NSString(string: "purposeDetails2"))![1] as! String).fontWeight(.ultraLight)
                        }
                    }.frame(height: screenHeight * 0.07).padding(.horizontal)

                    Button(action: {
                        self.toggleProductUpdated()
                    }) {
                        HStack {
                            Image(systemName: productUpdatesChecked ? "checkmark.square" : "square")
                            Text(cache.object(forKey: NSString(string: "purposeDetails2"))![2] as! String)
                        }.frame(width: screenWidth * 0.85, alignment: .leading).foregroundColor(self.newsletterConsent ? .black : Color(UIColor.systemGray2)).disabled(!self.newsletterConsent)
                    }.disabled(!self.newsletterConsent)

                    Button(action: {
                        self.togglePromotionsChecked()
                    }) {
                        HStack {
                            Image(systemName: promotionsChecked ? "checkmark.square" : "square")
                            Text(cache.object(forKey: NSString(string: "purposeDetails2"))![3] as! String)
                        }.frame(width: screenWidth * 0.85, alignment: .leading).foregroundColor(self.newsletterConsent ? .black : Color(UIColor.systemGray2))
                    }.disabled(!self.newsletterConsent)
                }
                Group {
                    Spacer().frame(height: screenHeight * 0.05)
                    Text("Opt out at any time by sending an email to privacy@wb.com, by mail to \"Privacy Group, Warner Bros., 4000 Warner Blvd, Burbank, CA 91522,\" or by unsubscribing via a link in an email.").frame(width: screenWidth * 0.9, alignment: .leading)
                    CCPAToggle(DNS: DNSToggleOG).frame(width: screenWidth * 0.9, alignment: .leading).padding(.vertical)
                    Text("This option stops the sharing of personal information with third parties for only this app on this device. To learn more about how your data is shared and for more options, including ways to opt-out across other Warner Bros. properties,").foregroundColor(Color(UIColor.systemGray2))
                    HStack(spacing: 0) {
                        Text("please visit the ").foregroundColor(Color(UIColor.systemGray2))
                        Button(action: {
                            self.showPrivacyCenter.toggle()
                        }) {
                            Text("Privacy Center").padding(0).foregroundColor(.blue)
                        }
                    }
                }.frame(width: screenWidth * 0.9, alignment: .leading)
            }
            Spacer()
                .navigationBarTitle("Consent Preferences")
                .navigationBarItems(trailing: Button(action: {
                    if self.firstPartyConsent == true {
                        settings.set(true, forKey: "firstPartyConsent")
                    } else if self.firstPartyConsent == false {
                        withdrawFirstPartyConsent()
                        settings.set(false, forKey: "firstPartyConsent")
                    }
                    if self.newsletterConsent == false {
                        withdrawNewsletterConsent()
                        settings.set(false, forKey: "newsletterConsent")
                    } else if self.newsletterConsent == true {
                        settings.set(true, forKey: "newsletterConsent")
                    }
                    settings.set(self.productUpdatesChecked, forKey: "productUpdates")
                    settings.set(self.promotionsChecked, forKey: "promotions")

                    logUniversalConsent(firstParty: self.firstPartyConsent, newsletter: self.newsletterConsent, productUpdates: self.productUpdatesChecked, promotions: self.promotionsChecked)
                    self.showView = false
                }) {
                    Text("SAVE").background(Color(UIColor.clear)).foregroundColor(.white).font(.headline)
                })
        }.frame(width: screenWidth, height: screenHeight * 0.8, alignment: .top)
        //         .onAppear{loadUniversalConsentDetails()}
    }
}

// Delegate for the CCPA DNS toggle
class DNSDelegate: ObservableObject {
    @Published var DNS: ListSection = .init()
}

// Struct to handle the CCPA toggle and consent alert message
struct ListSection {
    var MAID: String?
    var showAlert = false
    var instance = stateAndLog()
    var confirmationAlert: Alert { Alert(title: Text("Opt-In Confirmation"), message: Text("Are you sure you want to opt back in?"), primaryButton: Alert.Button.cancel(Text("Yes")) {
        settings.set(false, forKey: "donotSell")
        settings.set(false, forKey: "gad_rdp")
//        prism.ccpaShareData()
//        consoleLog(log: "DNS toggle == \(String(describing: prism.getUSPString()))")
        settings.synchronize()
        self.instance.state = false
        self.instance.status = "\(logPrivacyDNSCurrentState())"
    }, secondaryButton: Alert.Button.default(Text("No")) {
        settings.set(true, forKey: "donotSell")
        settings.set(true, forKey: "gad_rdp")
//        prism.ccpaDoNotShareData()
//        consoleLog(log: "DNS toggle == \(String(describing: prism.getUSPString()))")
        settings.synchronize()
    })
    }

    var toggle: Bool = settings.bool(forKey: "donotSell") {
        willSet {
            if newValue == false {
                showAlert.toggle()
                settings.set(false, forKey: "donotSell")
            } else {
                settings.set(true, forKey: "donotSell")
                settings.set(true, forKey: "gad_rdp")
//                prism.ccpaDoNotShareData()
//                consoleLog(log: "DNS toggle == \(String(describing: prism.getUSPString()))")
                settings.synchronize()
                instance.state = true
                instance.status = "\(logPrivacyDNSCurrentState())"
            }
        }
    }

    class stateAndLog: ObservableObject {
        @Published var state = settings.bool(forKey: "donotSell")
        @Published var status = ""
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        settingsTab(userFormValuesInstance: userFormValues(), observedHelper: Helper(otStatus: false))
    }
}
