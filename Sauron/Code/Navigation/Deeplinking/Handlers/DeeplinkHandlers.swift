//
//  DeeplinkHandlers.swift
//  Sauron
//
//  Created by Justin Cook on 1/12/23.
//

import Foundation

// MARK: - Deeplink Handlers

// MARK: - Launch Screen Handler
final class LaunchScreenDeeplinkHandler: DeeplinkHandlerProtocol {
    typealias Router = LaunchScreenRouter
    typealias Route = LaunchScreenRoutes
    typealias Coordinator = LaunchScreenCoordinator
    
    // MARK: - Properties
    var manager: DeepLinkManager,
        routerDirectory: RouteDirectories = .LaunchScreenRoutes,
        routes: LaunchScreenRoutes.Type = LaunchScreenRoutes.self
    
    var router: LaunchScreenRouter {
        return coordinator.router
    }
    
    var coordinator: LaunchScreenCoordinator {
        return manager
            .rootCoordinatorDelegate
            .dispatcher
            .launchScreenCoordinator
    }
    
    init(manager: DeepLinkManager) {
        self.manager = manager
    }
    
    func openURL(_ url: URL) {
        guard canOpenURL(url) else { return }
        
        let path = url.path(),
            route = path.normalizedPath.convertFromURLSafeString()
          
        manager.switchActiveRoot(to: .launchScreenCoordinator)

        guard let route = routes.init(rawValue: route),
              let root = manager.rootCoordinatorDelegate.activeRootCoordinator as? LaunchScreenCoordinator
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
/// - Get Started: sauron://onboarding/get_started
/// - Portfolio Curation Screen: sauron://onboarding/portfolio_curation
/// - Onboarding Screen: [Should fail if completed already] sauron://onboarding/
/// [Query] - Portfolio Curation Screen Search: sauron://onboarding/portfolio_curation?q=bitcoin
/// [Query] - Portfolio Curation Screen Search w/ Filter: sauron://onboarding/portfolio_curation?q=eth&pcf=true /// Sets the portfolio coin only filter to true
final class OnboardingDeeplinkHandler: DeeplinkHandlerProtocol {
    typealias Router = OnboardingRouter
    typealias Route = OnboardingRoutes
    typealias Coordinator = OnboardingCoordinator
    
    // MARK: - Properties
    var manager: DeepLinkManager,
        routerDirectory: RouteDirectories = .OnboardingRoutes,
        routes: OnboardingRoutes.Type = OnboardingRoutes.self
    
    var router: OnboardingRouter {
        return coordinator.router
    }
    
    var coordinator: OnboardingCoordinator {
        return manager
            .rootCoordinatorDelegate
            .dispatcher
            .onboardingCoordinator
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
              let root = manager.rootCoordinatorDelegate.activeRootCoordinator as? OnboardingCoordinator
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

private extension String {
    /// Remove the first character in the path to turn it into a normal route to be used with the router
    var normalizedPath: String {
        return String(self.trimmingPrefix { $0 == "/" })
    }
}
