//
//  InjectableServices.swift
//  Sauron
//
//  Created by Justin Cook on 12/26/22.
//

import Foundation

/// Protocol that allows the deployment of case specific services within any instance that calls this protocol and selectively injects the necessary services to use within that scope
protocol InjectableServices {}

/// All dependency injectable services are listed below, from these implementations these services can be injected into any
/// Instance without the host scope knowing how to instantiate them
extension InjectableServices {
    // MARK: - App Service
    static func inject() -> AppService {
        return .shared
    }
    
    // MARK: - FTUE Service
    static func inject() -> FTUEService {
        return FTUEService()
    }
    
    // MARK: - UserDefaults Service
    static func inject() -> UserDefaultsService {
        return UserDefaultsService()
    }
    
    // MARK: - Feature Flag Service
    static func inject() -> FeatureFlagService {
        return FeatureFlagService()
    }
    
    // MARK: - Fiat Currency Manager
    static func inject() -> FiatCurrencyManager {
        return .shared
    }
    
    // MARK: - Localized LanguageManager Manager
    static func inject() -> LocalizedLanguageManager {
        return .shared
    }

    // MARK: - Networking Service / Monitor
    static func inject() -> NetworkingService {
        return .shared
    }
    
    // MARK: - Image Downloader Service
    static func inject() -> ImageDownloaderService {
        return .init()
    }
}

// MARK: - Other domain specific dependency containers

// MARK: - Development specific services
protocol InjectableDevelopmentServices {}
extension InjectableDevelopmentServices {
    // MARK: - Feature Flag Service
    static func inject() -> FeatureFlagService {
        return FeatureFlagService()
    }
}

// MARK: - Managers
protocol InjectableManagers {}
extension InjectableManagers {
    // MARK: - Fiat Currency Manager
    static func inject() -> FiatCurrencyManager {
        return .shared
    }
}
