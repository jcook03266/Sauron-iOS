//
//  MainCoordinator.swift
//  Sauron
//
//  Created by Justin Cook on 1/14/23.
//

import SwiftUI
import Combine
import UIKit

class MainCoordinator: TabbarCoordinator {
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
    @Published var currentTab: MainRoutes = SRNTabbarViewModel.defaultTab
    
    // MARK: - Observed
    @ObservedObject var rootCoordinatorDelegate: RootCoordinatorDelegate
    
    // MARK: - Subscriptions
    private var cancellables: Set<AnyCancellable> = []
    private let scheduler: DispatchQueue = DispatchQueue.main
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        lazy var authService: SRNUserAuthenticator = MainCoordinator.Dependencies.inject()
        lazy var userManager: UserManager = MainCoordinator.Dependencies.inject()
        lazy var featureFlagService: FeatureFlagService = MainCoordinator.Dependencies.inject()
    }
    var dependencies = Dependencies()
    
    init(rootCoordinatorDelegate: RootCoordinatorDelegate = .shared) {
        self.rootCoordinatorDelegate = rootCoordinatorDelegate
        self.router = MainRouter(coordinator: self)
        self.rootRoute = rootCoordinatorDelegate.mainRootRoute
        self.rootView = router.view(for: rootRoute)
        
        UINavigationBar.changeAppearance(clear: true)
        
        addSubscribers()
        
        // Add the tabbar tab coordinators as children of this root
        populateChildren()
        
        // Ensure the amount of children equals the amount of tabs currently enumerated
        assert(children.count == MainRoutes.allCases.count)
        
        shouldGrantAccess()
        presentRootTab()
    }
    
    // MARK: - Publisher Subscriptions
    private func addSubscribers() {
        let userManager = dependencies.userManager
        
        // Listen for changes to the user's auth status
        // If a token is invalidated the user must re-authenticate themselves
        userManager
            .$isUserAuthenticated
        // Wait for 3+ seconds for the UI to catch up and then try to present any auth UI
            .debounce(for: 3,
                      scheduler: scheduler)
            .receive(on: scheduler)
            .sink { [weak self] isAuthenticated in
                guard let self = self
                else { return }
                
                if !isAuthenticated { self.presentAuthUI()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - User Authentication
    /// Only grant unlimited token default access to non-auth users
    private func shouldGrantAccess() {
        guard !router
            .authScreenViewModel
            .isAuthenticated,
        dependencies
            .userManager
            .getUserAuthPreference() == .none
        else { return }
        
        router
            .authScreenViewModel
            .grantAccessToNonAuthUser()
    }
    
    /// Make the user authenticate themselves to gain access to the main app content
    private func presentAuthUI() {
        guard dependencies
            .featureFlagService
            .isAuthScreenEnabled,
              dependencies
            .userManager
            .canAuthenticate()
        else { return }
        
        self.presentFullScreenCover(with: .authScreen)
    }
    
    // MARK: - Startup
    /// Present the target first tab, this is the first tab the user will see when they enter the app, (mutable)
    func presentRootTab() {
        navigateTo(tab: rootRoute)
    }
    
    // MARK: - Tabbar Navigation
    func navigateTo(tab: MainRoutes){
        currentTab = tab
        
        let child = getTabCoordinatorFor(route: tab)
        present(coordinator: child)
    }
    
    // MARK: - Root Coordinated View Builders
    func coordinatorView() -> AnyView {
        AnyView(MainCoordinatorView(coordinator: self,
                                    tabbarModel: self.router.tabbarModel))
    }
    
    func coordinatedView() -> any CoordinatedView {
        return MainCoordinatorView(coordinator: self,
                                   tabbarModel: self.router.tabbarModel)
    }
}

