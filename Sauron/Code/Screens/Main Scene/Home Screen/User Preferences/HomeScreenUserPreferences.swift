//
//  HomeScreenUserPreferences.swift
//  Sauron
//
//  Created by Justin Cook on 2/4/23.
//

import SwiftUI
import Combine

/// Publishable struct that stores user preferences pertaining to the home screen
struct HomeScreenUserPreferences {
    // MARK: - Dependencies
    private struct Dependencies: InjectableServices {
        let userDefaultsService: UserDefaultsService = inject()
    }
    private let dependencies = Dependencies()
    
    // MARK: - Subscriptions
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Portfolio Section
    var portfolioSectionMaximized: Bool {
        get {
            return dependencies
                .userDefaultsService
                .getValueFor(type: Bool.self,
                             key: .userPrefersPortfolioSectionMaximized())
        }
        set {
            dependencies
                .userDefaultsService
                .setValueFor(type: Bool.self,
                             key: .userPrefersPortfolioSectionMaximized(),
                             value: newValue)
        }
    }
    
    // Default
    static let defaultUserPrefersPortfolioSectionMaximizedValue: Bool = true
    
    // MARK: - All Assets Section
    var allAssetsSectionMaximized: Bool {
        get {
            return dependencies
                .userDefaultsService
                .getValueFor(type: Bool.self,
                             key: .userPrefersAllAssetsSectionMaximized())
        }
        set {
            dependencies
                .userDefaultsService
                .setValueFor(type: Bool.self,
                             key: .userPrefersAllAssetsSectionMaximized(),
                             value: newValue)
        }
    }
    
    // Default
    static let defaultUserPrefersAllAssetsSectionMaximized: Bool = false
}
