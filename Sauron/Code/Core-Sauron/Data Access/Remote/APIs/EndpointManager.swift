//
//  EndpointManager.swift
//  Sauron
//
//  Created by Justin Cook on 1/10/23.
//

import Foundation

/// A domain responsible for encapsulating all URLs for interfacing with known API endpoints
struct EndpointManager {
    // MARK: - Singleton
    static let shared: EndpointManager = .init()
    
    private init() {}
    
    // MARK: - All Endpoints
    // TODO: Setup a static 404 URL resource instead of force unwrapping the link for best practice
    
    // MARK: - Coin Gecko API Endpoints
    func getEndpoint(endpoint: CoinGeckoAPIGetRequestEndpoints) -> CoinGeckoAPIGetRequestEndpoints {
        return endpoint
    }
    
    func getURL(for endpoint: CoinGeckoAPIGetRequestEndpoints) -> URL {
        return endpoint.getAssociatedValue()
    }
    
    enum CoinGeckoAPIGetRequestEndpoints: AssociatedEnum, CaseIterable {
        static var allCases: [CoinGeckoAPIGetRequestEndpoints] = [.allCoins()]
        typealias associatedValue = URL
        
        case allCoins(URL = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=true".asURL!)
        
        func getAssociatedValue() -> URL {
            switch self {
            case .allCoins(let endpoint):
                return endpoint
            }
        }
    }
}
