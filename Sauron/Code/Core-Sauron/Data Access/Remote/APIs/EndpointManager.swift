//
//  EndpointManager.swift
//  Sauron
//
//  Created by Justin Cook on 1/10/23.
//

import Foundation

/// A domain responsible for encapsulating all URLs for interfacing with known API endpoints
struct EndpointManager {
    // MARK: - All Endpoints
    // TODO: Setup a static 404 URL resource instead of force unwrapping the link for best practice
    
    // MARK: - Coin Gecko API Endpoints
    let coinGeckoAPIEndpointManager: CoinGeckoAPIEndpointManager = .init()
    
    // MARK: - Exchangerate API Endpoints
    func getEndpoint(endpoint: ExchangerateAPIGetRequestEndpoints) -> ExchangerateAPIGetRequestEndpoints
    { return endpoint }
    
    func getURL(for endpoint: ExchangerateAPIGetRequestEndpoints) -> URL
    { return endpoint.getAssociatedValue() }
    
    // Exchange Rate Data for converting crypto prices to other currencies in real-time
    enum ExchangerateAPIGetRequestEndpoints: AssociatedEnum, CaseIterable {
        static var allCases: [ExchangerateAPIGetRequestEndpoints] = [.latestRates()]
        typealias associatedValue = URL
        
        /// Gets latest conversion rates from the base parameter [USD]
        case latestRates(URL = "https://api.exchangerate.host/latest?base=USD".asURL!)

        func getAssociatedValue() -> URL {
            switch self {
            case .latestRates(let endpoint):
                return endpoint
            }
        }
    }
}


/// If next page's data is empty then don't increment the page counter ??

/// CoinGecko API Endpoint manager that manages all necessary endpoints and allows for direct customization of each get request
/// using api specific values to ensure a safe url resolution for every custom attribute added
class CoinGeckoAPIEndpointManager {
    var allCoinsEndpoint: allCoinsEndpointBuilder {
        return .init(manager: self)
    }
    
    /// Higher level URL builder, resolves the required URL using a base and specified parameters
    private func buildURL(using baseURLString: String,
                          with parameters: [String : String]) -> URL {
        var urlString = ""
        urlString += baseURLString
        
        // Add parameters (if any)
        if !parameters.isEmpty {
            urlString += URLConstants.queryIdentifier
            
            for (index, (parameter, argument)) in parameters.enumerated() {
                /// Chain sequential parameters together
                if index != 0 { urlString += URLConstants.parameterChainer }
                urlString += "\(parameter)\(URLConstants.parameterEquator)\(argument)"
            }
        }
        
        // Debug Specific Error Handling, each URL resolution is required to not fail in production
        guard let url = urlString.asURL
        else {
            ErrorCodeDispatcher
                .SwiftErrors
                .triggerFatalError(for: .urlCouldNotBeParsed,
                                   with: urlString)()
        }
        
        return url
    }
    
    struct allCoinsEndpointBuilder {
        let manager: CoinGeckoAPIEndpointManager,
            baseURLString: String = "https://api.coingecko.com/api/v3/coins/markets",
            targetCurrencyParameter = "vs_currency",
                sortKeyParameter = "order",
                coinsPerPageParameter = "per_page",
                paginationParameter = "page",
                sparklineParameter = "sparkline"
        
        var targetConversionCurrency: targetCurrencies = .usd,
            sparklineEnabled: Bool = true,
            /// Pagination, the page up to which all coin data will be returned [eg. page 1 -> 100 coins total, page 2 -> 200 coins total] [1 indexed]
            currentPage: Int = allCoinsEndpointBuilder.defaultStartingPage,
            /// [min 1..250 max]
            coinsPerPage: Int = allCoinsEndpointBuilder.defaultCoinPerPageLimit,
            sortKey: sortKeys = .marketCapDescending
        
        static let defaultStartingPage: Int = 1,
                   defaultCoinPerPageLimit: Int = 100
        
        // MARK: - Convenience
        /// The range of the pagination
        var pageRange: ClosedRange<Int> {
            return allCoinsEndpointBuilder.defaultStartingPage...currentPage
        }
            
        /// Builds multiple URLs that return different pages of JSON coin data to be sequentially concatenated on the receiving end after being parsed
        func build() -> [URL] {
            var builtEndpoints: [URL] = [],
                parameters: [String : String] = [
                    targetCurrencyParameter : targetConversionCurrency.rawValue,
                    sortKeyParameter : sortKey.rawValue,
                    coinsPerPageParameter : coinsPerPage.description,
                    paginationParameter: "",
                    sparklineParameter: sparklineEnabled.description
                ]
            
            for page in pageRange {
                parameters[paginationParameter] = page.description
                
                builtEndpoints.append(
                    manager
                    .buildURL(using: baseURLString,
                                 with: parameters)
                )
            }
            
            return builtEndpoints
        }
     
        /// The base currency to compare all coin data against
        enum targetCurrencies: String, CaseIterable {
            case usd
        }
        
        /// The order & value for which to sort the data on the server side before returning it to the client
        enum sortKeys: String, CaseIterable {
            case marketCapAscending = "market_cap_asc"
            case marketCapDescending = "market_cap_desc"
            case volumeAscending = "volume_asc"
            case volumeDescending = "volume_desc"
            case idAscending = "id_asc"
            case idDescending = "id_desc"
            case geckoAscending = "gecko_asc"
            case geckoDescending = "gecko_desc"
        }
    }
    
}
