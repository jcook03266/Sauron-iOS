//
//  CoinDataProvider.swift
//  Sauron
//
//  Created by Justin Cook on 12/28/22.
//

import Foundation
import Combine

/// Data provider that asynchronously fetches JSON data from the specified endpoints
class CoinDataProvider: DataProviderProtocol, Mockable {
    typealias DataProvider = CoinDataProvider
    static let shared: CoinDataProvider = .init()
    
    // MARK: - Published
    @Published var coins: [CoinModel] = []
    
    // MARK: - Data Sources
    var allCoinsEndpoint: URL = GetRequestEndpoints.allCoins().getAssociatedValue()
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let networkingService: NetworkingService = inject()
    }
    let dependencies = Dependencies()
    
    // MARK: - Environments
    struct InjectedEnvironments: Environments {
        let devEnvironment: DevEnvironment = inject()
    }
    let environments = InjectedEnvironments()
    
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
    
    private func fetchCoins() {
        Task(priority: .high) {
            do {
                let coinData = try await fetchData()
                
                coins = try JSONParsingHelper.parseJSON(with: [CoinModel].self,
                                                     using: coinData)
            }
            catch {
                throw error
            }
        }
    }
    
    func fetchData() async throws -> Data {
        do {
            return try await dependencies.networkingService.fetchData(from: allCoinsEndpoint)
        }
        catch { throw error }
    }
    
    // MARK: - Mock Methods
    func mockFetchCoins() {
        Task(priority: .high) {
            do {
                if let coinData = environments.devEnvironment.testCoinModelJSONArray.data(using: .utf8) {
                    coins = try JSONParsingHelper.parseJSON(with: [CoinModel].self,
                                                            using: coinData)
                }
            }
            catch { throw error }
        }
    }
    
    /// Truth table for all valid endpoints
    enum GetRequestEndpoints: AssociatedEnum, CaseIterable {
        static var allCases: [GetRequestEndpoints] = [.allCoins()]
        typealias associatedValue = URL
        
        case allCoins(URL = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=true")!)
        
        func getAssociatedValue() -> URL {
            switch self {
            case .allCoins(let endpoint):
                return endpoint
            }
        }
    }
}
