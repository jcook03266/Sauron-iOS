//
//  LaunchScreenCoordinator.swift
//  Inspec
//
//  Created by Justin Cook on 11/22/22.
//

import SwiftUI
import UIKit

class LaunchScreenCoordinator: RootCoordinator {
    typealias Router = LaunchScreenRouter
    typealias Body = AnyView
    
    // MARK: - Properties
    unowned var parent: any Coordinator {
        return self
    }
    var children: [any Coordinator] = []
    var deferredDismissalActionStore: [LaunchScreenRoutes : (() -> Void)?] = [:]
    var statusBarHidden: Bool = true
    
    // MARK: - Published
    @Published var router: LaunchScreenRouter!
    @Published var navigationPath: [LaunchScreenRoutes] = []
    @Published var sheetItem: LaunchScreenRoutes?
    @Published var fullCoverItem: LaunchScreenRoutes?
    @Published var rootView: AnyView!
    @Published var rootRoute: LaunchScreenRoutes!
    
    // MARK: - Observed
    @ObservedObject var rootCoordinatorDelegate: RootCoordinatorDelegate
    
    init(rootCoordinatorDelegate: RootCoordinatorDelegate = .shared) {
        self.rootCoordinatorDelegate = rootCoordinatorDelegate
        self.rootRoute = rootCoordinatorDelegate.launchScreenRootRoute
        self.router = LaunchScreenRouter(coordinator: self)
        self.rootView = router.view(for: rootRoute)
        
        UINavigationBar.changeAppearance(clear: true)
    }
    
    func coordinatorView() -> AnyView {
        return AnyView(LaunchScreenCoordinatorView(coordinator: self))
    }
    
    func coordinatedView() -> any CoordinatedView {
        return LaunchScreenCoordinatorView(coordinator: self)
    }
}
