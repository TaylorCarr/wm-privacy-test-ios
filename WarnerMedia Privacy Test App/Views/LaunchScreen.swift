//
//  LaunchScreen.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 5/11/20.
//  Copyright © 2020 T Carr. All rights reserved.
//

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        VStack {
            Image("WBlogo")
                .resizable()
                .frame(width: screenWidth * 0.5, height: (screenWidth * 0.5) * 0.77, alignment: .center)
                .foregroundColor(Color(wbblue))
//                ActivityIndicator(isAnimating: true)
        }.frame(width: screenWidth, height: screenHeight, alignment: .top)
    }
}

class launchScreenHost: UIHostingController<LaunchScreen> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: LaunchScreen())
    }

//    override func viewDidLoad() {
//
//    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
