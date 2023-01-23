//
//  AppService.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI
import Combine

/** Singleton centralized service that stands as the reference point for this application*/
open class AppService: ObservableObject {
    static let shared: AppService = .init()
    
    // MARK: - Published
    // Deep Linking
    @Published var deepLinkManager: DeepLinkManager = .shared
    
    // MARK: - Debug Environment Properties
    static let isDebug: Bool = true
    static let useMockData: Bool = false /// Determines whether or not to use mock data when running the application or real data pulled from valid endpoints
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let fiatCurrencyManager: FiatCurrencyManager = inject()
        let networkingService: NetworkingService = inject()
        let userDefaultsService: UserDefaultsService = inject()
        let ftueService: FTUEService = inject()
        let featureFlagService: FeatureFlagService = inject()
        let userManager: UserManager = inject()
        let authenticationManager: SRNUserAuthenticator = inject()
    }
    var dependencies = Dependencies()
    
    struct DevelopmentDependencies: InjectableDevelopmentServices {
        let featureFlagService: FeatureFlagService = inject()
    }
    let developmentDependencies = DevelopmentDependencies()
    
    struct ManagerDependencies: InjectableManagers {
        let fiatCurrencyManager: FiatCurrencyManager = inject()
    }
    let managers = ManagerDependencies()
    
    // MARK: - Data Providers
    struct DataProviders: InjectableDataProviders {
        let coinDataProvider: CoinDataProvider = inject()
        let exchangeRateDataProvider: ExchangeRateDataProvider = inject()
    }
    var dataProviders = DataStores()
    
    // MARK: - Data Stores
    struct DataStores: InjectableStores {
        let coinDataStore: CoinStore = inject()
    }
    var dataStores = DataStores()
    
    // MARK: - Environments
    struct Environment: Environments {
        let devEnvironment: DevEnvironment = inject()
    }
    let environment = Environment()
    
    private init() {
        setup()
        load()
    }
    
    func setup() {
        // Disabled for testing purposes
        dependencies.userManager.changeUserPeferredAuthMethod(to: .none)
    }
    
    func load() {}
}
