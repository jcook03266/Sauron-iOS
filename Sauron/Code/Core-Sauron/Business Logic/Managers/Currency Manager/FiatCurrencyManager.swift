//
//  FiatCurrencyManager.swift
//  Sauron
//
//  Created by Justin Cook on 12/27/22.
//

import Foundation

/// Manages the currency local to the user's current region, or their preferred currency if available
class FiatCurrencyManager: ObservableObject {
    // MARK: - Singleton instance for distributing the same manager instance across the application
    static let shared: FiatCurrencyManager = .init()
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let userDefaultsService: UserDefaultsService = inject()
    }
    let dependencies = Dependencies()
    
    // MARK: - Data Providers
    struct DataProviders: InjectableDataProviders {
        let exchangeRateDataProvider: ExchangeRateDataProvider = inject()
    }
    
    // MARK: - Data Persistence and storage
    /// Used to display the user's preferred currency
    @Published var displayedCurrency: SupportedFiatCurrencies = defaultCurrency
    
    static let defaultCurrency: SupportedFiatCurrencies = .USD
    
    /// Returns the conversion rate from USD [Base] to the current currency
    var currentCurrencyConversionRate: Double {
        guard let exchangeRates =  DataProviders().exchangeRateDataProvider.latestExchangeRates,
                let conversionRate =  exchangeRates.rates[displayedCurrency.rawValue]
        else {
            return 1
        }
        
        return conversionRate
    }
    
    /// Used to fetch, store, and or mutate and save the user's preferred currency from user defaults
    private var userPreferredCurrency: SupportedFiatCurrencies {
        get {
            let rawValue = dependencies
            .userDefaultsService
            .getValueFor(type: SupportedFiatCurrencies.RawValue.self,
                         key: .userPreferredFiatCurrency())
            
            // The raw value of the enum is fetched from the store and coerced into a specific enum value
            return SupportedFiatCurrencies(rawValue: rawValue) ?? FiatCurrencyManager.defaultCurrency
        }
        set {
            dependencies
            .userDefaultsService
            .setValueFor(type: SupportedFiatCurrencies.RawValue.self,
                         key: .userPreferredFiatCurrency(),
                         value: newValue.rawValue)
            
            displayedCurrency = userPreferredCurrency
        }
    }
    
    enum SupportedFiatCurrencies: String, CaseIterable, Hashable {
        case USD, EUR, JPY, GBP, AUD, CAD, CHF, CNY, HKD, NZD
        
        func getSymbol() -> FiatSymbols {
            switch self {
            case .USD, .CAD, .AUD, .HKD, .NZD:
                return .dollar
            case .EUR:
                return .euro
            case .JPY, .CNY:
                return .yen_yuan
            case .GBP:
                return .pound
            case .CHF:
                return .franc
            }
        }
    }
    
    /// Currency symbols for all supported fiat currencies
    enum FiatSymbols: String, CaseIterable {
        case dollar = "$",
        euro = "???",
        yen_yuan = "??",
        pound = "??",
        franc = "CHF"
    }
    
    // MARK: - Formatting
    /// Converts a precision type into a supported currency with 2<->2 decimal places
    ///  ```
    ///  Convert 1234.56 to $1,234.56
    ///  ```
    private var currencyFormatter: NumberFormatter {
        let currency = getFiat(for: displayedCurrency)
        
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true // Enable commas
        formatter.numberStyle = .currency
        formatter.locale = .current // Default currency for the given locale
        formatter.maximumFractionDigits = maxTrailingSigFigs
        formatter.minimumFractionDigits = minTrailingSigFigs
        formatter.currencyCode = currency.currencyCode
        formatter.currencySymbol = currency.currencySymbol
        
        return formatter
    }
    private let maxTrailingSigFigs: Int = 2,
                minTrailingSigFigs: Int = 2,
                defaultMonetaryAmount: String = "$0.00" // Fall back on this copy in case the currency converter fails
    
    private init() { setup() }
    
    private func setup() {
        self.displayedCurrency = userPreferredCurrency
    }
    
    // MARK: - Conversion and factory methods
    /// Converts from the base USD currency to the current currency
    private func convertFromBaseToCurrent(number: Double) -> Double {
        return currentCurrencyConversionRate * number
    }
    
    func convertToCurrencyFormat(number: NSNumber) -> String {
        let convertedNumber = convertFromBaseToCurrent(number: Double(truncating: number))
        
        return currencyFormatter.string(from: convertedNumber as NSNumber) ?? defaultMonetaryAmount
    }
    
    // MARK: - Return data relevant to the current currency used by the application
    func getCurrentSymbol() -> FiatSymbols {
        return getSymbol(for: displayedCurrency)
    }
    
    func getCurrentFiat() -> FiatCurrency {
        return getFiat(for: displayedCurrency)
    }
    
    func getCurrentCountryCode(uppercased: Bool = true) -> String {
        return getCountryCode(for: displayedCurrency,
                              uppercased: uppercased)
    }
    
    /// Use this to detect whether the input currency is the current selected currency reflected across the application
    func isCurrentCurrency(currency: SupportedFiatCurrencies) -> Bool {
        return getCurrentCountryCode() == getCountryCode(for: currency)
    }
    
    // MARK: - General getters and accessors
    func getCountryCode(for currency: SupportedFiatCurrencies, uppercased: Bool = true) -> String {
        let fiat = getFiat(for: currency)
        
        return uppercased ? fiat.currencyCode.uppercased() : fiat.currencyCode.lowercased()
    }
    
    func getSymbol(for currency: SupportedFiatCurrencies) -> FiatSymbols {
        switch currency {
        case .USD, .CAD, .AUD, .HKD, .NZD:
            return .dollar
        case .EUR:
            return .euro
        case .JPY, .CNY:
            return .yen_yuan
        case .GBP:
            return .pound
        case .CHF:
            return .franc
        }
    }
    
    func getFiat(for currency: SupportedFiatCurrencies) -> FiatCurrency {
        let symbol = getSymbol(for: currency)
        
        return FiatCurrency(currencyCode: currency.rawValue.lowercased(),
                            currencySymbol: symbol.rawValue)
    }
    
    /// Accessor method for private data
    func changePreferredCurrency(to currency: SupportedFiatCurrencies) {
        guard userPreferredCurrency != currency else { return }
        
        userPreferredCurrency = currency
    }
    
    /// Returns a formatted string using a sample number specified
    func getSampleFormattedNumber(number: NSNumber = 12345.67) -> String {
        return convertToCurrencyFormat(number: number)
    }
}
