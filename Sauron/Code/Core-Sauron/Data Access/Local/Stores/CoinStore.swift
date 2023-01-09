//
//  CoinStore.swift
//  Sauron
//
//  Created by Justin Cook on 12/28/22.
//

import Foundation
import SwiftUI
import Combine

/// Stores and updates a global copy of all coin data for easy access from local memory
class CoinStore: StoreProtocol, Mockable {
    typealias Provider = CoinDataProvider
    typealias Store = CoinStore
    
    // MARK: - Properties
    static let shared: CoinStore = .init()
    var cancellables: Set<AnyCancellable> = [],
debounceInterval: Double = 0.25,
    scheduler = DispatchQueue.main
    
    // MARK: - Observed
    @ObservedObject var dataProvider: CoinDataProvider = .shared
    
    // MARK: - Published
    @Published private(set) var coins: [CoinModel] = []
    @Published private var themeColors: Set<CoinThemeColor> = []
    /// The current query being used to filter the store's data pool
    @Published var activeSearchQuery: String = ""
    @Published var displayPortfolioCoinsOnly: Bool = false
    
    // MARK: - Convenience variables
    var searchResultCount: Int = 0
    
    // MARK: - Data Store Dependencies
    struct DataStores: InjectableStores {
        let portfolioManager: PortfolioManager = inject()
    }
    let dataStores = DataStores()
    
    init() {
        setup()
    }
    
    func setup() {
        !mockEnvironment ? subscribeToProvider() : subscribeToMockProvider()
    }
    
    /// Recieve all updates from the given subscription and store the received coins while cancelling any type erased cancellable instances
    func subscribeToProvider() {
        /// The publishers for the search query and data provider are combined to form a tuple that's updated with new data whenever either publisher recieves an update. This combination is then filtered with a subscriber being attached to receive the data passing through the filter.
        $activeSearchQuery
            .combineLatest(dataProvider.$coins)
            .debounce(for: .seconds(debounceInterval),
                      scheduler: scheduler)
            .map(filter)
            .combineLatest($displayPortfolioCoinsOnly, dataStores.portfolioManager.$coinEntities)
            .map(filterPortfolioCoins)
            .assign(to: &$coins)
        
        /// Subscribe directly to the data provider and use this to build up the store for all coin theme colors
        dataProvider.$coins
            .sink { [weak self] coins in
                guard let self = self else { return }
                self.batchUpdateThemeColors(for: coins)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Store mutation and accessor methods
    func refresh() {
        dataProvider.reload()
    }
    
    func add(_ coin: CoinModel) {
        guard coins.contains(where: {
            $0 != coin
        }) else { return }
        
        coins.append(coin)
        addThemeColor(for: coin)
    }
    
    func batchAdd(coins: [CoinModel]) {
        for coin in coins {
            self.add(coin)
        }
    }
    
    func remove(_ coin: CoinModel) {
        coins.removeAll {
            $0 == coin
        }
        
        removeThemeColor(for: coin)
    }
    
    func batchRemove(coins: [CoinModel]) {
        for coin in coins {
            self.remove(coin)
        }
    }
    
    func getCoin(at index: Int) -> CoinModel {
        return coins[index]
    }
    
    func getCoins(at indices: [Int]) -> [CoinModel] {
        var coinsToReturn: [CoinModel] = []
        
        for index in indices {
            let coin = getCoin(at: index)
            coinsToReturn.append(coin)
        }
        
        return coinsToReturn
    }
    
    func getAllCoins() -> [CoinModel] {
        return self.coins
    }
    
    func getCoinsIn(range: ClosedRange<Int>) -> [CoinModel] {
        var coinsToReturn: [CoinModel] = []
        
        for index in range {
            let coin = getCoin(at: index)
            coinsToReturn.append(coin)
        }
        
        return coinsToReturn
    }
    
    // MARK: - Coin Theme Colors
    private func batchUpdateThemeColors(for coins: [CoinModel]) {
        // Add new colors
        for coin in coins {
            if !doesThemeColorExist(for: coin) {
                addThemeColor(for: coin)
            }
        }
        
        // Remove old colors
        for themeColor in themeColors {
            if coins.first(where: { $0.id == themeColor.id }) == nil {
                themeColors.remove(themeColor)
            }
        }
    }
    
    private func batchAddThemeColors(for coins: [CoinModel]) {
        for coin in coins {
            self.addThemeColor(for: coin)
        }
    }
    
    private func addThemeColor(for coin: CoinModel) {
        guard !doesThemeColorExist(for: coin) else { return }
        
        CoinImageFetcher(coinModel: coin).getImage { [weak self] in
            guard let self = self,
                  let avgColor = $0.averageColor
            else { return }
            
            let coinThemeColor = CoinThemeColor(id: coin.id, themeColor: Color(avgColor))
            self.themeColors.insert(coinThemeColor)
        }
    }
    
    private func doesThemeColorExist(for coin: CoinModel) -> Bool {
        return themeColors.first {
            $0.id == coin.id
        } != nil
    }
    
    private func batchRemoveThemeColors(for coins: [CoinModel]) {
        for coin in coins {
            self.removeThemeColor(for: coin)
        }
    }
    
    private func removeThemeColor(for coin: CoinModel) {
        if let memberToRemove = themeColors.first(where: { $0.id == coin.id }) {
            themeColors.remove(memberToRemove)
        }
    }
    
    func getThemeColor(for coin: CoinModel) -> Color? {
        var fetchedThemeColor: Color? = nil
        
        if let themeColor = themeColors.first(where: {
            $0.id == coin.id
        }) {
            fetchedThemeColor = themeColor.themeColor
        }
        else {
            addThemeColor(for: coin)
        }
        
        return fetchedThemeColor
    }
    
    // MARK: - Filtering
    private func filter(using query: String,
                        on unfilteredCoins: [CoinModel]) -> [CoinModel]
    {
        guard !query.isEmpty else { return unfilteredCoins }
        
        // To accurately compare the model's identifier strings with the given query, all strings have to be lowercased
        let lowercasedQuery = query.lowercased()
        
        // If a coin satisfies the specified predicate then it is returned in the local filtered array of coins
        let filteredCoins = unfilteredCoins.filter { (coin) -> Bool in
            let condition = coin.name.lowercased().contains(lowercasedQuery) ||
            coin.symbol.lowercased().contains(lowercasedQuery) ||
            coin.id.lowercased().contains(lowercasedQuery)
            
            return condition
        }
        
        searchResultCount = filteredCoins.count
        
        return filteredCoins
    }
    
    private func filterPortfolioCoins(unfilteredCoins: [CoinModel],
                                      shouldFilter: Bool,
                                      portfolioCoins: [PortfolioCoinEntity]) -> [CoinModel] {
        guard !portfolioCoins.isEmpty && shouldFilter else { return unfilteredCoins }
        
        let filteredCoins = unfilteredCoins.filter { (coin) -> Bool in
            let condition = portfolioCoins.contains { $0.coinID == coin.id }
            return condition
        }
        
        return filteredCoins
    }
    
    // MARK: - Sorting
    func sort<T: Comparable>(ascending: Bool = true,
                             sortKey: SortKeys = .name,
                             sortKeyType: T.Type) {
        coins = coins.sorted { coin1, coin2 in
            var value1, value2: T
            
            switch sortKey {
            case .name:
                value1 = coin1.name as! T
                value2 = coin2.name as! T
            case .id:
                value1 = coin1.id as! T
                value2 = coin2.id as! T
            case .price:
                value1 = coin1.currentPrice as! T
                value2 = coin2.currentPrice as! T
            }
            
            return ascending ? (value1 < value2) : (value1 > value2)
        }
    }
    
    // MARK: - Mock Methods
    /// Mock data acquisition from some preset data source
    func subscribeToMockProvider() {
        $activeSearchQuery
            .combineLatest(dataProvider.$coins)
            .map(filter)
            .assign(to: &$coins)
    }
    
    enum SortKeys: CaseIterable, Hashable, Codable {
        case name
        case id
        case price
    }
}