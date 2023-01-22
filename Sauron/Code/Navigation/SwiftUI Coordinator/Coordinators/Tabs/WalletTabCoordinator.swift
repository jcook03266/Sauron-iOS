//
//  WalletTabCoordinator.swift
//  Sauron
//
//  Created by Justin Cook on 1/22/23.
//

import SwiftUI

class WalletTabCoordinator: Coordinator {
    typealias Router = WalletTabRouter
    typealias Body = AnyView
    
    unowned let parent: any Coordinator
    var children: [any Coordinator] = []
    var rootRoute: WalletRoutes! = .main
    var rootView: AnyView!
    var deferredDismissalActionStore: [WalletRoutes : (() -> Void)?] = [:]
    
    // MARK: - Published
    @Published var navigationPath: [WalletRoutes] = []
    @Published var sheetItem: WalletRoutes?
    @Published var fullCoverItem: WalletRoutes?
    
    // MARK: - Published
    @Published var router: WalletTabRouter!
    @Published var statusBarHidden: Bool = false
    
    init (parent: any Coordinator) {
        self.parent = parent
        self.router = WalletTabRouter(coordinator: self)
        self.rootView = view(for: rootRoute)
    }
}

