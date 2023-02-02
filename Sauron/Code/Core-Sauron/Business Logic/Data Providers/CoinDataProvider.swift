//
//  CoinDataProvider.swift
//  Sauron
//
//  Created by Justin Cook on 12/28/22.
//

import Foundation
import Combine
import OrderedCollections

/// Data provider that asynchronously fetches JSON data from the specified endpoints
class CoinDataProvider: DataProviderProtocol, Mockable {
    typealias DataProvider = CoinDataProvider
    static let shared: CoinDataProvider = .init()
    
    // MARK: - Published
    @Published var coins: [CoinModel] = []
    /// A static reference of the most relevant stable coins on the market, used to categorize stable coins from the rest of the user's portfolio coins for statistical reasons
    @Published var stableCoins: [CoinModel] = []
    
    // MARK: - Data Sources
    var endpointManager: CoinGeckoAPIEndpointManager {
        return dependencies
            .endpointManager
            .coinGeckoAPIEndpointManager
    }
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let networkingService: NetworkingService = inject()
        let endpointManager: EndpointManager = inject()
    }
    let dependencies = Dependencies()
    
    // MARK: - Data Store Dependencies
    struct DataStores: InjectableStores {
        lazy var portfolioManager: PortfolioManager = CoinDataProvider.DataStores.inject()
    }
    var dataStores = DataStores()
    
    // MARK: - Environments
    struct InjectedEnvironments: Environments {
        let devEnvironment: DevEnvironment = inject()
    }
    let environments = InjectedEnvironments()
    
    // MARK: - Pagination
    /// The starting page is maximized to hold the amount of coins listed static, this is to simplify the application's data acquisition pipeline so that the user can only work with a select set of coins, of course when there's a coin present in the user's portfolio that's not listed in this set then a separate fetch is made to return those coins in question
    var currentPage: Int = CoinDataProvider.maxPage
    /// Artificial Page limit for memory management and performance reasons as well as API throttling prevention as a max of 10-50 calls can be made per minute with the free tier of CoinGecko'sAPI
    static let maxPage: Int = 2
    var canPaginate: Bool {
        return currentPage < CoinDataProvider.maxPage
    }
    
    // MARK: - Constants
    static let defaultPaginationStartingPage: Int = CoinGeckoAPIEndpointManager
        .allCoinsEndpointBuilder
        .defaultStartingPage
    
    private init() {
        setup()
    }
    
    func setup() {
        load()
    }
    
    func load() {
        !mockEnvironment ? fetchCoins() : mockFetchCoins()
    }
    
    /// If network access was interrupted the first time or if data needs to be fetched again use this
    func reload() {
        !mockEnvironment ? fetchCoins() : mockFetchCoins()
    }
    
    /// Load the upcoming data from the next page
    func paginateToNextPage() {
        guard canPaginate
        else { return }
        
        currentPage += 1
        
        reload()
    }
    
    // MARK: - Data Transformation
    private func fetchCoins() {
        fetchPortfolioCoins()
        fetchAllCoins()
    }
    
    /// Return coins specific to the user's portfolio first before getting all coins, this allows for a faster load time on the home screen
    private func fetchPortfolioCoins() {
       // The specific IDs to fetch from the endpoint
       let portfolioCoinIDs = dataStores
            .portfolioManager
            .coinEntities
            .compactMap { return $0.coinID }
        
        Task(priority: .high) {
            do {
                let coinData = try await fetchData(for: portfolioCoinIDs)

                let parsedCoins = try JSONParsingHelper
                    .parseJSON(with: [CoinModel].self,
                               using: coinData)
                
                updateCoinData(with: parsedCoins)
            }
            catch { throw error }
        }
    }
    
    private func fetchStableCoins() {
        
    }
 
    private func fetchAllCoins() {
        Task(priority: .high) {
            do {
                let paginatedCoinData = try await fetchAllData()

                for coinDatum in paginatedCoinData {
                    let parsedCoins = try JSONParsingHelper
                        .parseJSON(with: [CoinModel].self,
                                   using: coinDatum)
                    
                    updateCoinData(with: parsedCoins)
                }
            }
            catch { throw error }
        }
    }
    
    private func updateCoinData(with newCoins: [CoinModel]) {
        /// Create a unique copy of all coins to ensure no duplicate coin data is appended to the coin array
        var tempCoinBuffer: OrderedSet<CoinModel> = OrderedSet(coins)
        
        for coin in newCoins {
            tempCoinBuffer.updateOrAppend(coin)
        }
        
        coins = Array(tempCoinBuffer)
    }
    
    // MARK: - Data Acquistion
    func fetchData(for coinIDs: [String]) async throws -> Data {
        do {
            var endPoint = endpointManager.allCoinsEndpoint
            
            // Returns the coins from any page, not just a specific one
            endPoint.currentPage = 0
            endPoint.coinIDsToQuery = coinIDs
            
            return try await dependencies
                .networkingService
                .fetchData(from: endPoint.buildJust())
        }
    }
    
    func fetchAllData() async throws -> [Data] {
        do {
            var sequentialData: [Data] = [],
                endpoint = endpointManager
                .allCoinsEndpoint
            
            // Specify the pagination upper limit
            endpoint.currentPage = currentPage
            
            // Iterate through all the page specific endpoints
            for endpoint in endpoint.build() {
                let data = try await dependencies
                    .networkingService
                    .fetchData(from: endpoint)
                
                sequentialData.append(data)
            }
            
            return sequentialData
        }
        catch { throw error }
    }
    
    // MARK: - Mock Methods
    func mockFetchCoins() {
        Task(priority: .high) {
            do {
                if let coinData = environments
                    .devEnvironment
                    .testCoinModelJSONArray
                    .data(using: .utf8)
                {
                    coins = try JSONParsingHelper.parseJSON(with: [CoinModel].self,
                                                            using: coinData)
                }
            }
            catch { throw error }
        }
    }
}
