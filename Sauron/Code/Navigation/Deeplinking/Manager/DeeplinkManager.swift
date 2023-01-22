//
//  DeeplinkManager.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import Foundation

final class DeepLinkManager: ObservableObject {
    // MARK: - Published
    @Published var activeDeepLinkTarget: URL? = nil
    
    // MARK: - Singleton
    static let shared: DeepLinkManager = .init()
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let userDefaultsService: UserDefaultsService = inject()
        let userManager: UserManager = inject()
    }
    let dependencies = Dependencies()
    
    // MARK: - Properties
    // Static
    var deeplinkHandlers: [any DeeplinkHandlerProtocol] = []
    
    // For debugging purposes, the last successfully opened link is saved
    var lastActiveLink: URL? {
        get {
            return dependencies
                .userDefaultsService
                .getValueFor(key: .lastActiveDeeplink())
        }
        set {
            dependencies
                .userDefaultsService
                .setValueFor(key: .lastActiveDeeplink(),
                             value: newValue)
        }
    }
    
    private init() {
        setup()
    }
    
    private func setup() {
        injectHandlers()
    }
}

extension DeepLinkManager: DeeplinkManagerProtocol {
    func injectHandlers() {
        deeplinkHandlers = [
            LaunchScreenDeeplinkHandler(manager: self),
            OnboardingDeeplinkHandler(manager: self),
            HomeTabDeeplinkHandler(manager: self),
            WalletTabDeeplinkHandler(manager: self),
            SettingsTabDeeplinkHandler(manager: self),
            AlertsTabDeeplinkHandler(manager: self)
        ]
    }
}

extension DeepLinkManager {
    class DeepLinkConstants {
        /// Universal links TBA:
        static let universalScheme = "https"
        static let host = "www.sauron.io"
        
        // Deep links
        static let scheme = "sauron"
        static let identifier = "com.sauron.deeplinker"
        
        // Shared
        static let schemeSuffix = "://"
        static let queryTag = "q"
        static let portfolioCoinsOnlyFilterTag = "pcf"
        static let parameterStub = "/?"
        static let fragmentStub = "#"
        static let directorySlash = "/"
    }
}
