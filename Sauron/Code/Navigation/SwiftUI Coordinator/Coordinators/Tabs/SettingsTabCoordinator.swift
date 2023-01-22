//
//  SettingsTabCoordinator.swift
//  Sauron
//
//  Created by Justin Cook on 1/22/23.
//

import SwiftUI

class SettingsTabCoordinator: Coordinator {
    typealias Router = SettingsTabRouter
    typealias Body = AnyView
    
    unowned let parent: any Coordinator
    var children: [any Coordinator] = []
    var rootRoute: SettingsRoutes! = .main
    var rootView: AnyView!
    var deferredDismissalActionStore: [SettingsRoutes : (() -> Void)?] = [:]
    
    // MARK: - Published
    @Published var navigationPath: [SettingsRoutes] = []
    @Published var sheetItem: SettingsRoutes?
    @Published var fullCoverItem: SettingsRoutes?
    
    // MARK: - Published
    @Published var router: SettingsTabRouter!
    @Published var statusBarHidden: Bool = false
    
    init (parent: any Coordinator) {
        self.parent = parent
        self.router = SettingsTabRouter(coordinator: self)
        self.rootView = view(for: rootRoute)
    }
}


