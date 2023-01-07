//
//  StoreProtocol.swift
//  Sauron
//
//  Created by Justin Cook on 12/28/22.
//

import Foundation
import Combine

protocol StoreProtocol: ObservableObject {
    associatedtype Provider: DataProviderProtocol
    associatedtype Store: StoreProtocol

    // MARK: - Singleton instance to prevent unneccessary data refreshing
    static var shared: Store { get }
    
    // MARK: - Published
    var cancellables: Set<AnyCancellable> { get set }
    
    // MARK: - Observed Objects
    /// The source of the data to be stored by the conforming object
    var dataProvider: Provider { get set }
    
    func subscribeToProvider()
}

extension StoreProtocol {
    /// Empty implementation in case a store doesn't require a subscription to a provider
    func subscribeToProvider() {}
}

/// Allows easy access of data stores from a single source of truth
protocol InjectableStores {}

extension InjectableStores {
    // MARK: - Coin Store / Responsible for persisting all coin data
    static func inject() -> CoinStore {
        return .shared
    }
    
    // MARK: - Portfolio Manager / Portfolio Coin store responsible for persisting user portfolio data
    static func inject() -> PortfolioManager {
        return .shared
    }
}
