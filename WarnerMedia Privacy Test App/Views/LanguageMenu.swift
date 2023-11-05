//
//  LanguageMenu.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 3/31/21.
//  Copyright © 2021 T Carr. All rights reserved.
//

import OTPublishersHeadlessSDK
import SwiftUI

// let defaults = UserDefaults.standard

// struct Language: Hashable, Codable, Identifiable {
//    var id: Int
//    var language: String
//    var isFavorite: Bool
// }

// MARK: Language Choice

struct languageView: View {
//    @State var languages:[Language] = [Language(id: 0, language: "English", isFavorite: true), Language(id: 1, language: "Spanish", isFavorite: false)]
//    @Binding var languages: [Language]
//    @StateObject var helper = Helper

    @ObservedObject var observedHelper: Helper

    var body: some View {
        GeometryReader { _ in
            VStack {
                Group {
                    List {
                        ForEach(Array(observedHelper.languagesMap.keys).sorted(by: <), id: \.self) { languageIndex in
                            Button(action: {
                                if !observedHelper.languagesMap[languageIndex]!.isFavorite {
                                    let temp = languageCache.object(forKey: NSString(stringLiteral: "systemLanguage"))! as String
                                    print(observedHelper.languagesMap[temp]!)
                                    observedHelper.languagesMap[languageCache.object(forKey: NSString(stringLiteral: "systemLanguage")) as String? ?? "English"]?.isFavorite = false
                                    languageCache.setObject(NSString(string: languageIndex), forKey: NSString(stringLiteral: "systemLanguage"))
                                    defaults.set(languageIndex, forKey: "systemLanguage")
//                                    defaults.set(observedHelper.languagesMap, forKey: "languagesMap")

                                    OTPublishersHeadlessSDK.shared.clearOTSDKData()
                                    let sdkParams = OTSdkParams(countryCode: nil, regionCode: nil)
                                    sdkParams.setShouldCreateProfile("true")

                                    let domainUrl = "cdn.cookielaw.org",
                                        domainId = oneTrustAppId,
                                        language = observedHelper.languagesMap[languageIndex]!.code

                                    OTPublishersHeadlessSDK.shared.startSDK(storageLocation: domainUrl, domainIdentifier: domainId, languageCode: language, params: sdkParams) { response in
                                        print("OTT Data fetch result \(response.responseString != nil) and error \(String(describing: response.error?.localizedDescription))")
                                    }
                                    observedHelper.languagesMap[languageIndex]!.isFavorite = true
                                }
                            }) {
                                HStack {
                                    Text(languageIndex)
                                    if observedHelper.languagesMap[languageIndex]!.isFavorite {
                                        Image(systemName: "heart").foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
            }.navigationBarTitle("Languages", displayMode: .large)
                .foregroundColor(Color("textColor"))
                .onAppear {}
        }
    }
}

struct LanguageMenu_Previews: PreviewProvider {
    static var previews: some View {
//        languageView(languages: .constant([Language(id: 0, language: "English", isFavorite: true)]))
        VStack {}
    }
}
