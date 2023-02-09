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

/// CoinGecko API Endpoint manager that manages all necessary endpoints and allows for direct customization of each get request
/// using api specific values to ensure a safe url resolution for every custom attribute added
class CoinGeckoAPIEndpointManager {
    // MARK: - Endpoints
    var allCoinsEndpoint: AllCoinsEndpointBuilder {
        return .init(manager: self)
    }
    
    var trendingCoinsEndpoint: TrendingCoinsEndpointBuilder {
        return .init(manager: self)
    }
    
    var globalMarketEndpoint: GlobalMarketEndpointBuilder {
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
    
    /// Data source interface for fetching higher level info about the entire crypto market
    struct GlobalMarketEndpointBuilder {
        let manager: CoinGeckoAPIEndpointManager,
            baseURLString: String = "https://api.coingecko.com/api/v3/global"
        
        func build() -> URL {
            // This endpoint doesn't require parameters so an empty dict is passed
            return manager
                .buildURL(using: baseURLString,
                          with: [:])
        }
    }
    
    /// Top-7 trending coins on CoinGecko (Descending [Most searched])
    struct TrendingCoinsEndpointBuilder {
        let manager: CoinGeckoAPIEndpointManager,
            baseURLString: String = "https://api.coingecko.com/api/v3/search/trending"
        
        func build() -> URL {
            return manager
                .buildURL(using: baseURLString,
                          with: [:])
        }
    }
    
    /// Data source interface for fetching info about all cryptocurrencies
    struct AllCoinsEndpointBuilder {
        let manager: CoinGeckoAPIEndpointManager,
            baseURLString: String = "https://api.coingecko.com/api/v3/coins/markets",
            /// Specify this + page = 0 to search for any specific coins by ID to return
            coinIDsParameter = "ids",
            targetCurrencyParameter = "vs_currency",
            categoryParameter = "category",
            sortKeyParameter = "order",
            coinsPerPageParameter = "per_page",
            paginationParameter = "page",
            sparklineParameter = "sparkline"
        
        var targetConversionCurrency: targetCurrencies = .usd,
            category: Categories = .all,
            coinIDsToQuery: [String] = [],
            sparklineEnabled: Bool = true,
            /// Pagination, the page up to which all coin data will be returned [eg. page 1 -> 100 coins total, page 2 -> 200 coins total] [1 indexed]
            currentPage: Int = AllCoinsEndpointBuilder.defaultStartingPage,
            /// [min 1..250 max]
            coinsPerPage: Int = AllCoinsEndpointBuilder.defaultCoinPerPageLimit,
            sortKey: sortKeys = .marketCapDescending
        
        static let defaultStartingPage: Int = 1,
                   defaultCoinPerPageLimit: Int = 250
        
        // MARK: - Convenience
        /// The range of the pagination
        var pageRange: ClosedRange<Int> {
            return AllCoinsEndpointBuilder.defaultStartingPage...currentPage
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
            
            
            // Provide the category parameter only if a specific category has been specified
            if category != .all {
                parameters[categoryParameter] = category.rawValue
            }
            
            // Join the coin ids (if any) with commas and use percent encoding in order to format the url properly
            parameters[coinIDsParameter] = coinIDsToQuery
                .joined(separator: ",")
                .addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            
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
        
        /// Builds just one URL, pagination is not possible as only one page specific URL can be returned by this method at a time, this is best suited for querying specific coin IDs with the current page set to 0 to invalidate the pagination factor on the backend
        func buildJust() -> URL {
            var parameters: [String : String] = [
                targetCurrencyParameter : targetConversionCurrency.rawValue,
                sortKeyParameter : sortKey.rawValue,
                coinsPerPageParameter : coinsPerPage.description,
                paginationParameter: "",
                sparklineParameter: sparklineEnabled.description
            ]
            
            // Join the coin ids (if any) with commas and use percent encoding in order to format the url properly
            parameters[coinIDsParameter] = coinIDsToQuery
                .joined(separator: ",")
                .addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            
            parameters[paginationParameter] = currentPage.description
            
            return manager
                .buildURL(using: baseURLString,
                          with: parameters)
        }
        
        /// All supported crypto currency categories via CoinGecko, Note: set the page number parameter to 0 when querying, pagination isn't supported
        enum Categories: String, CaseIterable {
            /// No category, returns all coins
            case all = ""
            case stableCoins = "stablecoins"
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
