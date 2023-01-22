//
//  HomeTabCoordinator.swift
//  Sauron
//
//  Created by Justin Cook on 1/22/23.
//

import SwiftUI

class HomeTabCoordinator: Coordinator {
    typealias Router = HomeTabRouter
    typealias Body = AnyView
    
    unowned let parent: any Coordinator
    var children: [any Coordinator] = []
    var rootRoute: HomeRoutes! = .main
    var rootView: AnyView!
    var deferredDismissalActionStore: [HomeRoutes : (() -> Void)?] = [:]
    
    // MARK: - Published
    @Published var navigationPath: [HomeRoutes] = []
    @Published var sheetItem: HomeRoutes?
    @Published var fullCoverItem: HomeRoutes?
    
    // MARK: - Published
    @Published var router: HomeTabRouter!
    @Published var statusBarHidden: Bool = false
    
    init (parent: any Coordinator) {
        self.parent = parent
        self.router = HomeTabRouter(coordinator: self)
        self.rootView = view(for: rootRoute)
    }
}

