//
//  AlertsTabCoordinator.swift
//  Sauron
//
//  Created by Justin Cook on 1/22/23.
//

import SwiftUI

class AlertsTabCoordinator: Coordinator {
    typealias Router = AlertsTabRouter
    typealias Body = AnyView
    
    unowned let parent: any Coordinator
    var children: [any Coordinator] = []
    var rootRoute: AlertsRoutes! = .main
    var rootView: AnyView!
    var deferredDismissalActionStore: [AlertsRoutes : (() -> Void)?] = [:]
    
    // MARK: - Published
    @Published var navigationPath: [AlertsRoutes] = []
    @Published var sheetItem: AlertsRoutes?
    @Published var fullCoverItem: AlertsRoutes?
    
    // MARK: - Published
    @Published var router: AlertsTabRouter!
    @Published var statusBarHidden: Bool = false
    
    init (parent: any Coordinator) {
        self.parent = parent
        self.router = AlertsTabRouter(coordinator: self)
        self.rootView = view(for: rootRoute)
    }
}


