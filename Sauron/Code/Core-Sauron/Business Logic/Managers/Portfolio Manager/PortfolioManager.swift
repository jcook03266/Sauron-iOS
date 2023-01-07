//
//  PortfolioManager.swift
//  Sauron
//
//  Created by Justin Cook on 1/4/23.
//

import SwiftUI
import CoreData
import Combine

/// Manager that manages the lifecycle of the user's portfolio as well as interfacing directly with the data provider to ensure the latest data is accumulated and persisted
class PortfolioManager: ObservableObject {
    // MARK: - Published
    @Published var currentPortfolio: Portfolio = .init()
    @Published var coinEntities: [PortfolioCoinEntity] = []
    
    // MARK: - Singleton
    static let shared: PortfolioManager = .init()
    
    // MARK: - Data Provider Dependencies
    struct DataProviders: InjectableDataProviders {
        let portfolioDataProvider: PortfolioDataProvider = inject()
    }
    let dataProviders = DataProviders()
    
    // MARK: - Subscriptions
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Convenience
    var isEmpty: Bool {
        return coinEntities.isEmpty
    }
    
    private init() {
        syncWithDataProvider()
        addSubscribers()
    }
    
    // MARK: - Subscriptions
    func addSubscribers() {
        currentPortfolio.$coins
            .sink { [weak self] storedCoins in
                guard let self = self else { return }
                self.coinEntities = storedCoins
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Interfacing with data provider
    func doesCoinExistInPortfolio(coin: CoinModel) -> Bool {
        return dataProviders.portfolioDataProvider.doesCoinExistInPortfolio(coin: coin).0
    }
    
    func addCoin(coin: CoinModel) {
        dataProviders.portfolioDataProvider.updatePortfolio(with: coin)
        syncWithDataProvider()
    }
    
    func removeCoin(coin: CoinModel) {
        dataProviders.portfolioDataProvider.removeCoinFromPortfolio(coin: coin)
        syncWithDataProvider()
    }
    
    func reload() {
        syncWithDataProvider()
    }
    
    /// Wipes all data
    func clearAllData(resetMetaData: Bool = true) {
        dataProviders.portfolioDataProvider.removeAllCoins()
        
        if resetMetaData { resetPortfolioMetaData() }
    }
    
    /// Clears all statistics relating to the portfolio, but keeps the saved coins
    private func resetPortfolioMetaData() {
        let entitiesCopy = currentPortfolio.coins
        
        currentPortfolio = .init()
        currentPortfolio.coins = entitiesCopy
    }
    
    /// Use this whenever the manager has been initialized and or has sent updates to the provider and becomes out of sync
    private func syncWithDataProvider() {
        currentPortfolio.coins = dataProviders.portfolioDataProvider.savedEntities
        
        // Setting portfolio properties
        guard let coinEntity = currentPortfolio.coins.first else { return }
        
        // The earliest added coin is when this portfolio was created
        if let earliestAddedCoin = currentPortfolio.coins.min(by: { entity1, entity2 in
            entity1.addDate! < entity2.addDate!
        })
        { currentPortfolio.created = earliestAddedCoin.addDate ?? .now }
        else { currentPortfolio.created = coinEntity.addDate ?? .now }
        
        // The last updated coin is the last update of this portfolio
        if let mostRecentCoinUpdate = currentPortfolio.coins.max(by: { entity1, entity2 in
            entity1.lastUpdate! > entity2.lastUpdate!
        })
        { currentPortfolio.lastUpdate = mostRecentCoinUpdate.lastUpdate ?? .now }
        else { currentPortfolio.lastUpdate = coinEntity.lastUpdate ?? .now }
    }
}
