//
//  OnboardingCoordinator.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI
import UIKit

class OnboardingCoordinator: RootCoordinator {
    typealias Router = OnboardingRouter
    typealias Body = AnyView
    
    unowned var parent: any Coordinator {
        return self
    }
    var children: [any Coordinator] = []
    var deferredDismissalActionStore: [OnboardingRoutes : (() -> Void)?] = [:]
    
    // MARK: - Published
    @Published var router: OnboardingRouter!
    @Published var navigationPath: [OnboardingRoutes] = []
    @Published var sheetItem: OnboardingRoutes?
    @Published var fullCoverItem: OnboardingRoutes?
    @Published var rootView: AnyView!
    @Published var statusBarHidden: Bool = true
    @Published var rootRoute: OnboardingRoutes! = RootCoordinatorDelegate.shared.onboardingRootRoute
    
    // MARK: - Observed
    @ObservedObject var rootCoordinatorDelegate: RootCoordinatorDelegate
    
    init (rootCoordinatorDelegate: RootCoordinatorDelegate = .init()) {
        self.rootCoordinatorDelegate = rootCoordinatorDelegate
        self.router = OnboardingRouter(coordinator: self)
        self.rootView = router.view(for: rootRoute)
        
        UINavigationBar.changeAppearance(clear: true)
    }
    
    func coordinatorView() -> AnyView {
        return AnyView(OnboardingCoordinatorView(coordinator: self))
    }
    
    func coordinatedView() -> any CoordinatedView {
        return OnboardingCoordinatorView(coordinator: self)
    }
}
