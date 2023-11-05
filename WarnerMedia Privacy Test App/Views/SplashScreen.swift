//
//  SplashScreen.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 5/5/20.
//  Copyright © 2020 T Carr. All rights reserved.
//

import OTPublishersHeadlessSDK
import SwiftUI

class SplashScreenController: UIHostingController<AnyView> {
    override func viewDidLoad() {}
}

struct SplashScreenDelegate: View {
    @State var finishedFetch = false
//    @State var asheet: ActiveSheet? = .none

    var body: some View {
        ZStack {
            if finishedFetch == true {
                ContentView()
            } else {
                SplashScreen().onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if loadUniversalConsentDetails() == true {
                            self.finishedFetch.toggle()
                        } else {
                            print("error loading universal consent details")
                        }
                    }
                }
            }
        }.onAppear {
            if OTPublishersHeadlessSDK.shared.shouldShowBanner() {
                helper.showOneTrust = true
            } else {
                helper.showOneTrust = false
            }
            helper.showOneTrust = true
        }
    }
}

struct SplashScreen: View {
    @State var finishedFetch = false

    var body: some View {
        NavigationView {
            VStack {
                Image("WBlogo")
                    .resizable()
                    .frame(width: screenWidth * 0.5, height: (screenWidth * 0.5) * 0.77, alignment: .center)
                    .foregroundColor(Color(wbblue))
                ActivityIndicator(isAnimating: true)
            } // .navigationBarTitle("")
            .navigationBarHidden(true)
        }.frame(width: screenWidth, height: screenHeight, alignment: .top)
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
