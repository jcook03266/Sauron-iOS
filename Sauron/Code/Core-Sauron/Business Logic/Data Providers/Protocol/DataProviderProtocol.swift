//
//  DataProviderProtocol.swift
//  Sauron
//
//  Created by Justin Cook on 12/28/22.
//

import Foundation
import Combine

/// General protocol for defining some service that provides data to some receiver
protocol DataProviderProtocol: ObservableObject {
    associatedtype DataProvider: DataProviderProtocol
    
    static var shared: DataProvider { get }
    
    func setup()
    func load()
    func reload()
}

protocol InjectableDataProviders {}

/// Allows easy access of data providers from a single source of truth
extension InjectableDataProviders {
    // MARK: - Coin Data Provider
    static func inject() -> CoinDataProvider {
        return .shared
    }
    
    static func inject() -> PortfolioDataProvider {
        return .shared
    }
}
