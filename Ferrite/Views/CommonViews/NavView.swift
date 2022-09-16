//
//  NavView.swift
//  Ferrite
//
//  Created by Brian Dashore on 7/4/22.
//  Contributed by Mantton
//
//  A wrapper that switches between NavigationStack and the legacy NavigationView
//

import SwiftUI

struct NavView<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack {
                content()
            }
        } else {
            NavigationView {
                content()
            }
            .navigationViewStyle(.stack)
        }
    }
}
