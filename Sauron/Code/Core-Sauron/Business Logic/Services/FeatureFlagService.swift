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
    
    var isOnboardingScreenEnabled: Bool {
        guard override == nil
        else { return override! }
        
        return true
    }
}
