//
//  Routes.swift
//  Inspec
//
//  Created by Justin Cook on 11/15/22.
//

import Foundation

/// Enums of all possible router routes (views) depending on the router
/// Each router is responsible for a specific set of views that it expects to present somewhere in its view hierarchy, this centralizes the app's navigation pathways to one source of truth
/// Note: Any new views must be added under their respective router

// MARK: - Launch Screen Router
enum LaunchScreenRoutes: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    case main = "" /// Default root route implementation
}

// MARK: - Onboarding Router
enum OnboardingRoutes: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }

    case main = ""
    case getStarted = "get started"
    case portfolioCuration = "portfolio curation"
    case web
    case currencyPreferenceBottomSheet = "currency preference bottom sheet"
}

// MARK: - Main / Tabbar Router [For tabbar use only, no deeplinks!]
enum MainRoutes: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    case home
    case wallet
    case settings
    case alerts
    case authScreen = "auth screen"
}

// MARK: - Home Tab router
enum HomeRoutes: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    case main
}
// MARK: - Wallets Tab Router
enum WalletRoutes: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    case main
}
// MARK: - Settings Tab Router
enum SettingsRoutes: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    case main
}
// MARK: - Alerts Tab Router
enum AlertsRoutes: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    case main
}

/// A record of all possible route pathways across the app, this is used to deeplink a user into a specific part of the application when they trigger a link with a scheme specific to this application
enum RouteDirectories: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    /// Routable Sections
    case LaunchScreenRoutes = "launch"
    case OnboardingRoutes = "onboarding"
    case HomeRoutes = "home"
    case WalletRoutes = "wallet"
    case SettingsRoutes = "settings"
    case AlertsRoutes = "alerts"
}
