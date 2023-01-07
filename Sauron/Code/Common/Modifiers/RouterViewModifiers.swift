//
//  RouterViewModifiers.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI

struct RouterStatusBarVisibilityModifier: ViewModifier {
    var visible: Bool
    var coordinator: any Coordinator
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                coordinator.statusBarHidden = visible
            }
    }
}

extension View {
    func routerStatusBarVisibilityModifier(visible: Bool,
                                           coordinator: any Coordinator) -> some View {
        modifier(RouterStatusBarVisibilityModifier(visible: visible,
                                                   coordinator: coordinator))
    }
}
