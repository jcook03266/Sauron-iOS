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
    @Published var currentPortfolio: Portfolio
    @Published var coinEntities: [PortfolioCoinEntity] = []
    
    // MARK: - Singleton
    static let shared: PortfolioManager = .init()
    
    // MARK: - Data Provider Dependencies
    struct DataProviders: InjectableDataProviders {
        lazy var portfolioDataProvider: PortfolioDataProvider = PortfolioManager.DataProviders.inject()
        lazy var coinDataProvider: CoinDataProvider = PortfolioManager.DataProviders.inject()
    }
    var dataProviders = DataProviders()
    
    // MARK: - Subscriptions
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Convenience
    var isEmpty: Bool {
        return coinEntities.isEmpty
    }
    
    // MARK: - Coin Randomization
    /// The hard limit of calls that can be stored on the stack to prevent overflow in the case where a random coin not already present in the portfolio cannot be sourced
    private let randomCoinRecursiveStackLimit: Int = 10
    private var currentRandomCoinCallStackSize: Int = 0
    
    private init() {
        self.currentPortfolio = .init()
        
        setup()
    }
    
    private func setup() {
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
    
    /// Randomize the user's portfolio
    func randomize() {
        clearAllData()
        
        let portfolioSize: Int = (2...12).randomElement() ?? 2,
            portfolioSizeRange: ClosedRange<Int> = 1...portfolioSize
        
        for _ in portfolioSizeRange {
            addRandomCoin()
        }
        
        reload()
    }
    
    /// A protected recursive function that adds a random coin not already found in the user's portfolio
    private func addRandomCoin() {
        guard let randomCoin = dataProviders.coinDataProvider.coins.randomElement(),
                !doesCoinExistInPortfolio(coin: randomCoin)
        else {
            if currentRandomCoinCallStackSize <= randomCoinRecursiveStackLimit {
                currentRandomCoinCallStackSize += 1
                
                addRandomCoin()
            }
            
            currentRandomCoinCallStackSize = 0
            return
        }
        
        addCoin(coin: randomCoin)
    }
    
    /// Wipes all data
    func clearAllData() {
        dataProviders.portfolioDataProvider.removeAllCoins()
        currentPortfolio = .init()
        
        addSubscribers()
    }
    
    /// Clears all statistics relating to the portfolio, but keeps the saved coins
    private func resetPortfolioMetaData() {
        let entitiesCopy = currentPortfolio.coins
        
        currentPortfolio = .init()
        currentPortfolio.coins = entitiesCopy
        
        addSubscribers()
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
