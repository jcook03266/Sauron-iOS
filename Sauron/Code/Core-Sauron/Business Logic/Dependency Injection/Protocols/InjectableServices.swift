//
//  InjectableServices.swift
//  Sauron
//
//  Created by Justin Cook on 12/26/22.
//

import Foundation

/// Protocol that allows the deployment of case specific services within any instance that calls this protocol and selectively injects the necessary services to use within that scope
protocol InjectableServices {}

/// All dependency injectable services are listed below, from these implementations these services can be injected into any Instance without the host scope knowing how to instantiate them
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
    
    // MARK: - Localized Language Manager
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
    
    // MARK: - Endpoint Manager
    static func inject() -> EndpointManager {
        return .init()
    }
    
    // MARK: - Keychain Manager
    static func inject() -> KeychainManager {
        return .init()
    }
    
    // MARK: - Validator Manager
    static func inject() -> ValidatorManager {
        return .shared
    }
    
    // MARK: - Authentication Service
    static func inject() -> SRNUserAuthenticator {
        return .shared
    }
    
    // MARK: - User Manager
    static func inject() -> UserManager {
        return .shared
    }
    
    // MARK: - Mailing List Service
    static func inject() -> MailingListService {
        return .shared
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

/// Scope specific to only manager oriented services
extension InjectableManagers {
    // MARK: - Fiat Currency Manager
    static func inject() -> FiatCurrencyManager {
        return .shared
    }
    
    // MARK: - Localized Language Manager
    static func inject() -> LocalizedLanguageManager {
        return .shared
    }
    
    // MARK: - Endpoint Manager
    static func inject() -> EndpointManager {
        return .init()
    }
    
    // MARK: - Keychain Manager
    static func inject() -> KeychainManager {
        return .init()
    }
    
    // MARK: - Validator Manager
    static func inject() -> ValidatorManager {
        return .shared
    }
    
    // MARK: - User Manager
    static func inject() -> UserManager {
        return .shared
    }
}
