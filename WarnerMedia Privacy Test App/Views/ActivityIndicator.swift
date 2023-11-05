//
//  ActivityIndicator.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 5/11/20.
//  Copyright © 2020 T Carr. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    typealias UIView = UIActivityIndicatorView
    var isAnimating: Bool
    var configuration = { (_: UIView) in }

    func makeUIView(context _: UIViewRepresentableContext<Self>) -> UIView { UIView() }
    func updateUIView(_ uiView: UIView, context _: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        configuration(uiView)
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator(isAnimating: true)
    }
}
