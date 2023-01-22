//
//  DeeplinkHandlers.swift
//  Sauron
//
//  Created by Justin Cook on 1/12/23.
//

import Foundation

// MARK: - Deeplink Handlers

// MARK: - Launch Screen Handler
/// Note: This handler is symbolic, it shouldn't be used outside of the debugging environment
final class LaunchScreenDeeplinkHandler: DeeplinkHandlerProtocol {
    typealias Router = LaunchScreenRouter
    typealias Route = LaunchScreenRoutes
    typealias RCoordinator = LaunchScreenCoordinator
    typealias ChildCoordinator = LaunchScreenCoordinator
    
    // MARK: - Properties
    var manager: DeepLinkManager,
        routerDirectory: RouteDirectories = .LaunchScreenRoutes,
        routes: Route.Type = Route.self
    
    var router: Router {
        return rootCoordinator.router
    }
    
    var rootCoordinator: RCoordinator {
        return manager
            .rootCoordinatorDelegate
            .dispatcher
            .launchScreenCoordinator
    }
    
    /// Not used
    var childCoordinator: (ChildCoordinator)? {
        return nil
    }
    
    init(manager: DeepLinkManager) {
        self.manager = manager
    }
    
    /// Not used
    func openURL(_ url: URL) {
        guard canOpenURL(url), AppService.isDebug else { return }
        
        let path = url.path(),
            route = path.normalizedPath.convertFromURLSafeString()
          
        manager.switchActiveRoot(to: .launchScreenCoordinator)

        guard let route = routes.init(rawValue: route),
              let root = manager.rootCoordinatorDelegate.activeRootCoordinator as? RCoordinator
        else {
            ErrorCodeDispatcher.DeeplinkingErrors.printErrorCode(for: .routeCouldNotBeInitialized(routeRawValue: route, url: url))
            
            return
        }
        
        manager.setActiveDeepLinkTarget(to: url)
        root.navigateTo(targetRoute: route)
    }
}


// MARK: - Onboarding Scene Handler
/// Test links:
/// - Get Started: sauron://onboarding/get-started
/// - Portfolio Curation Screen: sauron://onboarding/portfolio-curation
/// - Onboarding Screen: [Should fail if completed already] sauron://onboarding/
/// [Query] - Portfolio Curation Screen Search: sauron://onboarding/portfolio-curation?q=bitcoin
/// [Query] - Portfolio Curation Screen Search w/ Filter: sauron://onboarding/portfolio-curation?q=eth&pcf=true /// Sets the portfolio coin only filter to true
final class OnboardingDeeplinkHandler: DeeplinkHandlerProtocol {
    typealias Router = OnboardingRouter
    typealias Route = OnboardingRoutes
    typealias RCoordinator = OnboardingCoordinator
    typealias ChildCoordinator = OnboardingCoordinator
    
    // MARK: - Properties
    var manager: DeepLinkManager,
        routerDirectory: RouteDirectories = .OnboardingRoutes,
        routes: Route.Type = Route.self
    
    var router: Router {
        return rootCoordinator.router
    }
    
    var rootCoordinator: RCoordinator {
        return manager
            .rootCoordinatorDelegate
            .dispatcher
            .onboardingCoordinator
    }
    
    /// Not used
    var childCoordinator: (ChildCoordinator)? {
        return nil
    }
    
    init(manager: DeepLinkManager) {
        self.manager = manager
    }
    
    func openURL(_ url: URL) {
        guard canOpenURL(url) else { return }
        
        let path = url.path(),
            route = path.normalizedPath.convertFromURLSafeString(),
            queries = getQueries(from: url)
          
        manager.switchActiveRoot(to: .onboardingCoordinator)

        guard let route = routes.init(rawValue: route),
              let root = manager.rootCoordinatorDelegate.activeRootCoordinator as? RCoordinator
        else {
            ErrorCodeDispatcher.DeeplinkingErrors.printErrorCode(for: .routeCouldNotBeInitialized(routeRawValue: route, url: url))
            
            return
        }
        
        /// Send this query directly to the router corresponding to the route specified by the url
        if let query = queries[DeepLinkManager.DeepLinkConstants.queryTag] {
            switch route {
            case .main:
                break
            case .getStarted:
                break
            case .portfolioCuration:
                router.portfolioCurationSearchQuery = query
            case .web:
                break
            case .currencyPreferenceBottomSheet:
                break
            }
        }
        
        /// Filters
        if let portfolioCoinsOnlyFilter = queries[DeepLinkManager.DeepLinkConstants.portfolioCoinsOnlyFilterTag],
            let bool = Bool(portfolioCoinsOnlyFilter)
        {
            router.filterPortfolioCoinsOnly = bool
        }
        
        manager.setActiveDeepLinkTarget(to: url)
        root.navigateTo(targetRoute: route)
    }
}

// MARK: - Main Scene | Home Tab Handler
/// Test links:
/// - Home Tab: sauron://home/
final class HomeTabDeeplinkHandler: DeeplinkHandlerProtocol {
    typealias Router = HomeTabRouter
    typealias Route = HomeRoutes
    typealias RCoordinator = MainCoordinator
    typealias ChildCoordinator = HomeTabCoordinator
    
    // MARK: - Properties
    var manager: DeepLinkManager,
        routerDirectory: RouteDirectories = .HomeRoutes,
        routes: Route.Type = Route.self
    
    var router: Router {
        return childCoordinator!.router
    }
    
    var rootCoordinator: RCoordinator {
        return manager
            .rootCoordinatorDelegate
            .dispatcher
            .mainCoordinator
    }
    
    var childCoordinator: (ChildCoordinator)? {
        return rootCoordinator
            .dispatcher
            .homeTabCoordinator
    }
    
    init(manager: DeepLinkManager) {
        self.manager = manager
    }
    
    func openURL(_ url: URL) {
        // Only open URLs when the user is authenticated, an unauthorized user must not bypass the auth screen
        guard manager
            .dependencies
            .userManager
            .isUserAuthenticated
        else {
            ErrorCodeDispatcher
                .DeeplinkingErrors
                .printErrorCode(for: .unAuthorizedUser(url: url))
            return
        }
        
        guard canOpenURL(url)
        else { return }
        
        let path = url.path(),
            route = path.normalizedPath.convertFromURLSafeString(),
            queries = getQueries(from: url)
          
        manager.switchActiveRoot(to: .mainCoordinator)

        guard let route = routes.init(rawValue: route),
              let root = manager.rootCoordinatorDelegate.activeRootCoordinator as? RCoordinator,
              let child = root.getChild(for: ChildCoordinator.self)
        else {
            ErrorCodeDispatcher.DeeplinkingErrors.printErrorCode(for: .routeCouldNotBeInitialized(routeRawValue: route, url: url))
            
            return
        }
        
        /// Send this query directly to the router corresponding to the route specified by the url
        ///if let query = queries[DeepLinkManager.DeepLinkConstants.queryTag] {}
        
        /// On tabbar context switch action
        let onNavigateAction: (() -> Void) = {}
        
        manager.setActiveDeepLinkTarget(to: url)
        
        /// Switch the active tab to the following, and then from the child coordinator handle the path navigation
        root
            .router
            .navigateTo(tab: .home,
                        onNavigate: onNavigateAction)
        
        child.navigateTo(targetRoute: route)
    }
}

// MARK: - Main Scene | Wallet Tab Handler
/// Test links:
/// - Wallet Screen: sauron://wallet/
final class WalletTabDeeplinkHandler: DeeplinkHandlerProtocol {
    typealias Router = WalletTabRouter
    typealias Route = WalletRoutes
    typealias RCoordinator = MainCoordinator
    typealias ChildCoordinator = WalletTabCoordinator
    
    // MARK: - Properties
    var manager: DeepLinkManager,
        routerDirectory: RouteDirectories = .WalletRoutes,
        routes: Route.Type = Route.self
    
    var router: Router {
        return childCoordinator!.router
    }
    
    var rootCoordinator: RCoordinator {
        return manager
            .rootCoordinatorDelegate
            .dispatcher
            .mainCoordinator
    }
    
    var childCoordinator: (ChildCoordinator)? {
        return rootCoordinator
            .dispatcher
            .walletTabCoordinator
    }
    
    init(manager: DeepLinkManager) {
        self.manager = manager
    }
    
    func openURL(_ url: URL) {
        guard manager
            .dependencies
            .userManager
            .isUserAuthenticated
        else {
            ErrorCodeDispatcher
                .DeeplinkingErrors
                .printErrorCode(for: .unAuthorizedUser(url: url))
            return
        }
        
        guard canOpenURL(url)
        else { return }
        
        let path = url.path(),
            route = path.normalizedPath.convertFromURLSafeString(),
            queries = getQueries(from: url)
          
        manager.switchActiveRoot(to: .mainCoordinator)

        guard let route = routes.init(rawValue: route),
              let root = manager.rootCoordinatorDelegate.activeRootCoordinator as? RCoordinator,
              let child = root.getChild(for: ChildCoordinator.self)
        else {
            ErrorCodeDispatcher.DeeplinkingErrors.printErrorCode(for: .routeCouldNotBeInitialized(routeRawValue: route, url: url))
            
            return
        }
        
        /// Send this query directly to the router corresponding to the route specified by the url
        ///if let query = queries[DeepLinkManager.DeepLinkConstants.queryTag] {}
        
        /// On tabbar context switch action
        let onNavigateAction: (() -> Void) = {}
        
        manager.setActiveDeepLinkTarget(to: url)
        
        /// Switch the active tab to the following, and then from the child coordinator handle the path navigation
        root
            .router
            .navigateTo(tab: .wallet,
                        onNavigate: onNavigateAction)
        
        child.navigateTo(targetRoute: route)
    }
}

// MARK: - Main Scene | Settings Tab Handler
/// Test links:
/// - Settings Screen: sauron://settings/
final class SettingsTabDeeplinkHandler: DeeplinkHandlerProtocol {
    typealias Router = SettingsTabRouter
    typealias Route = SettingsRoutes
    typealias RCoordinator = MainCoordinator
    typealias ChildCoordinator = SettingsTabCoordinator
    
    // MARK: - Properties
    var manager: DeepLinkManager,
        routerDirectory: RouteDirectories = .SettingsRoutes,
        routes: Route.Type = Route.self
    
    var router: Router {
        return childCoordinator!.router
    }
    
    var rootCoordinator: RCoordinator {
        return manager
            .rootCoordinatorDelegate
            .dispatcher
            .mainCoordinator
    }
    
    var childCoordinator: (ChildCoordinator)? {
        return rootCoordinator
            .dispatcher
            .settingsTabCoordinator
    }
    
    init(manager: DeepLinkManager) {
        self.manager = manager
    }
    
    func openURL(_ url: URL) {
        guard manager
            .dependencies
            .userManager
            .isUserAuthenticated
        else {
            ErrorCodeDispatcher
                .DeeplinkingErrors
                .printErrorCode(for: .unAuthorizedUser(url: url))
            return
        }
        
        guard canOpenURL(url)
        else { return }
        
        let path = url.path(),
            route = path.normalizedPath.convertFromURLSafeString(),
            queries = getQueries(from: url)
          
        manager.switchActiveRoot(to: .mainCoordinator)

        guard let route = routes.init(rawValue: route),
              let root = manager.rootCoordinatorDelegate.activeRootCoordinator as? RCoordinator,
              let child = root.getChild(for: ChildCoordinator.self)
        else {
            ErrorCodeDispatcher.DeeplinkingErrors.printErrorCode(for: .routeCouldNotBeInitialized(routeRawValue: route, url: url))
            
            return
        }
        
        /// Send this query directly to the router corresponding to the route specified by the url
        ///if let query = queries[DeepLinkManager.DeepLinkConstants.queryTag] {}
        
        /// On tabbar context switch action
        let onNavigateAction: (() -> Void) = {}
        
        manager.setActiveDeepLinkTarget(to: url)
        
        /// Switch the active tab to the following, and then from the child coordinator handle the path navigation
        root
            .router
            .navigateTo(tab: .settings,
                        onNavigate: onNavigateAction)
        
        child.navigateTo(targetRoute: route)
    }
}

// MARK: - Main Scene | Alerts Tab Handler
/// Test links:
/// - Alerts Screen: sauron://alerts/
final class AlertsTabDeeplinkHandler: DeeplinkHandlerProtocol {
    typealias Router = AlertsTabRouter
    typealias Route = AlertsRoutes
    typealias RCoordinator = MainCoordinator
    typealias ChildCoordinator = AlertsTabCoordinator
    
    // MARK: - Properties
    var manager: DeepLinkManager,
        routerDirectory: RouteDirectories = .AlertsRoutes,
        routes: Route.Type = Route.self
    
    var router: Router {
        return childCoordinator!.router
    }
    
    var rootCoordinator: RCoordinator {
        return manager
            .rootCoordinatorDelegate
            .dispatcher
            .mainCoordinator
    }
    
    var childCoordinator: (ChildCoordinator)? {
        return rootCoordinator
            .dispatcher
            .alertsTabCoordinator
    }
    
    init(manager: DeepLinkManager) {
        self.manager = manager
    }
    
    func openURL(_ url: URL) {
        guard manager
            .dependencies
            .userManager
            .isUserAuthenticated
        else {
            ErrorCodeDispatcher
                .DeeplinkingErrors
                .printErrorCode(for: .unAuthorizedUser(url: url))
            return
        }
        
        guard canOpenURL(url)
        else { return }
        
        let path = url.path(),
            route = path.normalizedPath.convertFromURLSafeString(),
            queries = getQueries(from: url)
          
        manager.switchActiveRoot(to: .mainCoordinator)

        guard let route = routes.init(rawValue: route),
              let root = manager.rootCoordinatorDelegate.activeRootCoordinator as? RCoordinator,
              let child = root.getChild(for: ChildCoordinator.self)
        else {
            ErrorCodeDispatcher.DeeplinkingErrors.printErrorCode(for: .routeCouldNotBeInitialized(routeRawValue: route, url: url))
            
            return
        }
        
        /// Send this query directly to the router corresponding to the route specified by the url
        ///if let query = queries[DeepLinkManager.DeepLinkConstants.queryTag] {}
        
        /// On tabbar context switch action
        let onNavigateAction: (() -> Void) = {}
        
        manager.setActiveDeepLinkTarget(to: url)
        
        /// Switch the active tab to the following, and then from the child coordinator handle the path navigation
        root
            .router
            .navigateTo(tab: .alerts,
                        onNavigate: onNavigateAction)
        
        child.navigateTo(targetRoute: route)
    }
}

private extension String {
    /// Remove the first character in the path to turn it into a normal route to be used with the router
    var normalizedPath: String {
        return String(self.trimmingPrefix { $0 == "/" })
    }
}
