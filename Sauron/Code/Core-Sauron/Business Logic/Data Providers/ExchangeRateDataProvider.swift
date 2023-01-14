//
//  ExchangeRateDataProvider.swift
//  Sauron
//
//  Created by Justin Cook on 1/13/23.
//

import Foundation
import Combine

/// Provides conversion rates from USD to supported currencies
class ExchangeRateDataProvider: DataProviderProtocol {
    typealias DataProvider = ExchangeRateDataProvider
    static let shared: ExchangeRateDataProvider = .init()
    
    // MARK: - Published
    @Published var latestExchangeRates: LatestExchangeRateModel? = nil
    
    // MARK: - Data sources
    var latestExchangeRateEndpoint: URL {
        return dependencies.endpointManager.getURL(for: .latestRates())
    }
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let networkingService: NetworkingService = inject()
        let endpointManager: EndpointManager = inject()
    }
    let dependencies = Dependencies()
    
    private init() {
        setup()
    }
    
    func setup() {
        load()
    }
    
    func load() {
        fetchLatestExchangeRates()
    }
    
    func reload() {
        fetchLatestExchangeRates()
    }
    
    private func fetchLatestExchangeRates() {
        Task(priority: .high) {
            do {
                let exchangeRateData = try await fetchData()
                
                latestExchangeRates = try JSONParsingHelper.parseJSON(with: LatestExchangeRateModel.self,
                                                     using: exchangeRateData)
            }
            catch {
                throw error
            }
        }
    }
    
    func fetchData() async throws -> Data {
        do {
            return try await dependencies.networkingService.fetchData(from: latestExchangeRateEndpoint)
        }
        catch { throw error }
    }
}
