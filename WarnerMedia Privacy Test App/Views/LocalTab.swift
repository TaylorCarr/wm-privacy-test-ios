//
//  LocalTab.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 4/17/20.
//  Copyright © 2020 T Carr. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: View 2

struct view2: View {
//    var sdk = VungleSDK.shared()
    @State var showVungleAd = false

    var body: some View {
        Group {
            VStack {
                Text(verbatim: "\tNullam varius mauris vel dolor condimentum, quis porttitor nibh dapibus. Maecenas posuere posuere nisi, ut egestas nunc ultrices in. Curabitur ornare, mi quis sodales molestie, justo lectus varius urna, quis gravida nisl massa nec nunc. Nullam ut feugiat lorem. Etiam a justo elit. Pellentesque fringilla gravida arcu. Pellentesque malesuada odio vel accumsan tempor. Phasellus feugiat mi orci, sit amet consectetur magna facilisis quis. Suspendisse consectetur augue et malesuada suscipit. Vivamus fringilla, sapien nec sodales tristique, nunc nunc auctor urna, scelerisque tincidunt enim orci in massa. Nunc porta non urna eget pulvinar.\n\n\tIn est purus, dictum pellentesque ultricies quis, blandit quis elit. Nunc tincidunt congue pellentesque. In quis orci id tellus mattis venenatis et quis mauris. Duis fringilla pellentesque urna id rhoncus. In hac habitasse platea dictumst. Curabitur faucibus nunc eu hendrerit viverra. Ut vitae tempor diam.").padding()

                Button(action: {
                    self.showVungleAd.toggle()
                }) {
                    Text("Continue Reading...")
                }.sheet(isPresented: $showVungleAd, content: {
                    ZStack {
//                        VungleBannerViewController()
                        VStack {
                            Text(verbatim: "\tEtiam fermentum vehicula tellus, non posuere eros hendrerit vel. In elementum ipsum erat, nec blandit velit pharetra sit amet. Integer vel mi eu sem dictum tempus a in sem. Vivamus et nibh diam. Nullam in erat eget neque lobortis pellentesque. Donec nec elit vitae magna pulvinar suscipit in ac ex. Vestibulum id gravida justo. Maecenas sollicitudin risus mauris, ac pretium sapien dapibus in. In tellus sem, mattis quis imperdiet vitae, fermentum molestie nisl. Mauris rutrum libero nec arcu fermentum, eu placerat tellus consequat. Maecenas malesuada mollis mi a pretium. Morbi ullamcorper tortor eleifend sapien sollicitudin dignissim. Sed elementum tristique ornare. Nulla nibh nisl, venenatis non dui eu, faucibus pulvinar mauris. Quisque ut feugiat leo, eu cursus nisi.").padding()
                            Spacer()
                        }
                    }
                })
                Spacer()
            }.frame(width: screenWidth * 0.95, alignment: .center).background(Color.white).shadow(radius: 5)
        }.onAppear {
            self.cacheAd()
        }.background(Color(UIColor.systemGray5))
    }

    func cacheAd() {
//        let vunglePlacementID = "FSV-7761739"
//        let sdk:VungleSDK = VungleSDK.shared()
        do {
//            try sdk.loadPlacement(withID: vunglePlacementID)
        } catch let error as NSError {
            consoleLog(log: "Unable to load placement with reference ID :5e504fc94b46da00176e1ec3, Error: \(error)")
        }
    }
}

// MARK: Vungle Ad

// Vungle View Controller for full screen ads
// final class VungleBannerViewController: UIViewControllerRepresentable  {
//    let vunglePlacementID = "FSV-7761739"
//    let vungleAppID = "5e504fc94b46da00176e1ec3"
//
//    func makeUIViewController(context: Context) -> UIViewController {
////        let sdk:VungleSDK = VungleSDK.shared()
//        let viewController = UIViewController()
//        do {
////            sdk.update(VungleConsentStatus, consentMessageVersion: <#String#>)
////            try sdk.loadPlacement(withID: vunglePlacementID)
////            if (sdk.isAdCached(forPlacementID: vunglePlacementID)) {
////                try sdk.playAd(viewController, options: nil, placementID: vunglePlacementID)
//            }
//            else {
//                consoleLog(log: "Ad not cached")
//            }
//        }
//        catch let error as NSError {
//            consoleLog(log: "Unable to load placement with reference ID :\(vungleAppID), Error: \(error)")
//        }
//
//        return viewController
//    }
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
// }
