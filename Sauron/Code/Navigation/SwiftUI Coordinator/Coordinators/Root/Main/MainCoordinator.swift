//
//  MainCoordinator.swift
//  Sauron
//
//  Created by Justin Cook on 1/14/23.
//

import SwiftUI
import UIKit

class MainCoordinator: RootCoordinator {
    typealias Router = MainRouter
    typealias Body = AnyView
    
    // MARK: - Properties
    unowned var parent: any Coordinator {
        return self
    }
    var children: [any Coordinator] = []
    var deferredDismissalActionStore: [MainRoutes : (() -> Void)?] = [:]
    var statusBarHidden: Bool = true // Important: Do not publish changes from this variable, it disrupts the presentation of sheet modifiers
    
    // MARK: - Published
    @Published var router: MainRouter!
    @Published var navigationPath: [MainRoutes] = []
    @Published var sheetItem: MainRoutes?
    @Published var fullCoverItem: MainRoutes?
    @Published var rootView: AnyView!
    @Published var rootRoute: MainRoutes!
    
    // MARK: - Observed
    @ObservedObject var rootCoordinatorDelegate: RootCoordinatorDelegate
    
    init(rootCoordinatorDelegate: RootCoordinatorDelegate = .shared) {
        self.rootCoordinatorDelegate = rootCoordinatorDelegate
        self.router = MainRouter(coordinator: self)
        self.rootRoute = rootCoordinatorDelegate.mainRootRoute
        self.rootView = router.view(for: rootRoute)
        
        UINavigationBar.changeAppearance(clear: true)
    }
    
    func coordinatorView() -> AnyView {
        AnyView(MainCoordinatorView(coordinator: self))
    }
    
    func coordinatedView() -> any CoordinatedView {
        return MainCoordinatorView(coordinator: self)
    }
}

