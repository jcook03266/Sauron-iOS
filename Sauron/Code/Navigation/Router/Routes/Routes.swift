//
//  Routes.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import Foundation

// MARK: - Router Routes
/// Enums of all possible router routes (views) depending on the router
/// Each router is responsible for a specific set of views that it expects to present somewhere in its view hierarchy, this centralizes the app's navigation pathways to one source of truth
/// Note: Any new views must be added under their respective router

// MARK: - Launch Screen Router
enum LaunchScreenRoutes: String, CaseIterable, Hashable, RoutesProtocol {
    case main = "" /// Default root route implementation
}

// MARK: - Onboarding Router
enum OnboardingRoutes: String, CaseIterable, Hashable, RoutesProtocol {
    case main = ""
    case getStarted = "get started"
    case portfolioCuration = "portfolio curation"
    case web
    case currencyPreferenceBottomSheet = "currency preference bs"
}

// MARK: - Main / Tabbar Router [For tabbar use only, no deeplinks!]
enum MainRoutes: String, CaseIterable, Hashable, RoutesProtocol {
    /// For tabbar use only, hence why the auth screen is excluded
    static var allCases: [MainRoutes] = [.home, .wallet, .settings, .alerts]
    
    case home
    case wallet
    case settings
    case alerts
    case authScreen = "auth screen"
}

// MARK: - Home Tab router
enum HomeRoutes: String, CaseIterable, Hashable, RoutesProtocol {
    case main = ""
    case editPortfolio = "edit portfolio"
    case currencyPreferenceBottomSheet = "currency preference bs" // BS For bottom sheet presentation preference
}
// MARK: - Wallets Tab Router
enum WalletRoutes: String, CaseIterable, Hashable, RoutesProtocol {
    case main = ""
}
// MARK: - Settings Tab Router
enum SettingsRoutes: String, CaseIterable, Hashable, RoutesProtocol {
    case main = ""
}
// MARK: - Alerts Tab Router
enum AlertsRoutes: String, CaseIterable, Hashable, RoutesProtocol {
    case main = ""
}

/// A record of all possible route pathways across the app, this is used to deeplink a user into a specific part of the application when they trigger a link with a scheme specific to this application
enum RouteDirectories: String, CaseIterable, Hashable, RoutesProtocol {
    /// Routable Sections
    case LaunchScreenRoutes = "launch"
    case OnboardingRoutes = "onboarding"
    case HomeRoutes = "home"
    case WalletRoutes = "wallet"
    case SettingsRoutes = "settings"
    case AlertsRoutes = "alerts"
}

// MARK: - Deeplink Navigation Traversal
/// An enum that specifies the method of presentation for a target view, each view can be presented in a number of ways
/// Note: Please be advised that SwiftUI does not support multiple sheets being presented at once, if this is the case each sheet must be popped and a new one has to be presented in its place
enum PreferredViewPresentationMethod: String, CaseIterable, Hashable {
    case navigationStack = "ns"
    case bottomSheet = "bs"
    case fullCover = "fc"
    
    static func getPresentationType(from route: String) -> Self {
        let components = route.components(separatedBy: " ")
        
        for method in PreferredViewPresentationMethod.allCases {
            if components.contains(method.rawValue) {
                return method
            }
        }
        
        return navigationStack
    }
}
