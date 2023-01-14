//
//  DeeplinkHandlers.swift
//  Sauron
//
//  Created by Justin Cook on 1/12/23.
//

import Foundation

// MARK: - Handlers

// MARK: - Onboarding scene Deeplink handler
/// Test links:
/// - Home: Sauron://Onboarding/home
/// - Portfolio Curation Screen: Sauron://Onboarding/portfolioCuration
/// - Onboarding Screen: [Should fail if completed already] Sauron://Onboarding/onboarding
/// [Query] - Portfolio Curation Screen Search: Sauron://Onboarding/portfolioCuration?q=bitcoin
/// [Query] - Portfolio Curation Screen Search: Sauron://Onboarding/portfolioCuration?q=&pcf=true /// Sets the portfolio coin only filter to true
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
        
        let path = url.path()
        let route = path.normalizedPath
        let queries = getQueries(from: url)
          
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
            case .onboarding:
                break
            case .home:
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
