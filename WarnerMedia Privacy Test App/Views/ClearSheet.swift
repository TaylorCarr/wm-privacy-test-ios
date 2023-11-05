//
//  ClearSheet.swift
//  WarnerMedia Privacy Test App
//
//  Created by T Carr on 4/14/21.
//  Copyright © 2021 T Carr. All rights reserved.
//

import SwiftUI

struct ClearSheet: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct BackgroundClearView: UIViewRepresentable {
    typealias UIViewType = UIView

    func makeUIView(context _: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_: UIView, context _: Context) {}
}

struct ClearSheet_Previews: PreviewProvider {
    static var previews: some View {
        ClearSheet()
    }
}
