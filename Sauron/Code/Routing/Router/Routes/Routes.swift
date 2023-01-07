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
    
    case main
}

// MARK: - Onboarding Router
enum OnboardingRoutes: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    case onboarding
    case home
    case portfolioCuration
    case web
}

// MARK: - Main / Tabbar Router
enum TabbarRoutes: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    case builds
    case components
    case command_center
    case explore
    case inbox
}

// MARK: - Builds Router
enum BuildsRoutes: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    case main
}
// MARK: - Components Router
enum ComponentsRoutes: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    case main
}
// MARK: - Command Center Router
enum CommandCenterRoutes: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    case main
}
// MARK: - Explore Router
enum ExploreRoutes: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    case main
}

// MARK: - Inbox Router
enum InboxRoutes: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    case main
}

/// A record of all possible route pathways across the app
enum RouteDirectories: String, CaseIterable, Hashable, Identifiable, RoutesProtocol {
    var id: String {
        UUID().uuidString
    }
    
    case TabbarRoutes
    case OnboardingRoutes
    case BuildsRoutes
}

// MARK: - Generic protocol for all routes to conform to
protocol RoutesProtocol {
    var id: String { get }
}
