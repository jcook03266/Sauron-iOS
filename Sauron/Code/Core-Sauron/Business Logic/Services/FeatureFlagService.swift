//
//  FeatureFlagService.swift
//  Sauron
//
//  Created by Justin Cook on 12/26/22.
//

import Foundation

/// Service that can determine which features are currently toggled and applicable to the app's current runtime state, this can also be remotely controlled from a remote configuration file or proxy service for A/B Testing
protocol FeatureFlagServiceProtocol {
    var isOnboardingScreenEnabled: Bool { get }
}

/// Determines what features are enabled, all features can be disabled or enabled if the override variable is specified
final class FeatureFlagService {
    var override: Bool? = nil
    
    /// Toggles the visibility of the onboarding carousel scene at the beginning of the app on first install / FTUE
    var isOnboardingScreenEnabled: Bool {
        if let override = override {
            return override
        }
        
        return true
    }
    
    /// Toggles the auth screen functionality, when disabled no auth screen is ever presented which is equivalent to no auth method being selected which is the default behavior
    var isAuthScreenEnabled: Bool {
        if let override = override {
            return override
        }
        
        return true
    }
}
