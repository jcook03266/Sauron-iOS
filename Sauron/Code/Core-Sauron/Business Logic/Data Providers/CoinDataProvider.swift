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
    
    // MARK: - Environments
    struct InjectedEnvironments: Environments {
        let devEnvironment: DevEnvironment = inject()
    }
    let environments = InjectedEnvironments()
    
    // MARK: - Pagination
    var currentPage: Int = CoinDataProvider.defaultPaginationStartingPage
    /// Artificial Page limit for memory management and performance reasons as well as API throttling prevention as a max of 10-50 calls can be made per minute with the free tier of CoinGecko'sAPI
    var maxPage: Int = 5
    var canPaginate: Bool {
        return currentPage < maxPage
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
    
    private func fetchCoins() {
        Task(priority: .high) {
            do {
                let paginatedCoinData = try await fetchData()
                /// Create a unique copy of all coins to ensure no duplicate coin data is appended to the coin array
                var tempCoinBuffer: OrderedSet<CoinModel> = OrderedSet(coins)
                
                for coinDatum in paginatedCoinData {
                    let parsedCoins = try JSONParsingHelper
                        .parseJSON(with: [CoinModel].self,
                                   using: coinDatum)
                    
                    for coin in parsedCoins {
                        tempCoinBuffer.updateOrAppend(coin)
                    }
                }
                
                coins = Array(tempCoinBuffer)
            }
            catch { throw error }
        }
    }
    
    func fetchData() async throws -> [Data] {
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
