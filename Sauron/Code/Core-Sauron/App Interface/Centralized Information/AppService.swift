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
    
    // MARK: - Deep Linker
    let deepLinkManager: DeepLinkManager = .shared
    
    // MARK: - Published
    @Published var deepLinkTarget: DeepLinkManager.DeepLinkTarget?
    
    // MARK: - Debug Environment Properties
    static let isDebug: Bool = false
    static let useMockData: Bool = false /// Determines whether or not to use mock data when running the application or real data pulled from valid endpoints
    
    // MARK: -  Observed
    @ObservedObject var rootCoordinatorDelegate: RootCoordinatorDelegate = .shared
    
    var activeRootCoordinator: any RootCoordinator {
        return rootCoordinatorDelegate.activeRootCoordinator
    }
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let fiatCurrencyManager: FiatCurrencyManager = inject()
        let networkingService: NetworkingService = inject()
        let userDefaultsService: UserDefaultsService = inject()
        let ftueService: FTUEService = inject()
        let featureFlagService: FeatureFlagService = inject()
    }
    let dependencies = Dependencies()
    
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
    }
    let dataProviders = DataStores()
    
    // MARK: - Data Stores
    struct DataStores: InjectableStores {
        let coinDataStore: CoinStore = inject()
    }
    let dataStores = DataStores()
    
    // MARK: - Environments
    struct Environment: Environments {
        let devEnvironment: DevEnvironment = inject()
    }
    let environment = Environment()
    
    private init() { setup() }
    
    func setup() {
        //let store = dataStores.coinDataStore
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
        //            print(store.coins)
        //        }
    }
}
