//
//  CoinModel.swift
//  Sauron
//
//  Created by Justin Cook on 12/27/22.
import Foundation
import SwiftUI
import UIKit

/// Coin Gecko API Info
/** End-point URL:
 https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=true
 */

/// MARK: - Codable model built to hold historical price and metadata for specific crypto currency coins
struct CoinModel: Identifiable, Codable, Equatable, Hashable {
    let id, symbol, name: String
    let image: String
    let currentPrice: Double
    let marketCap, totalVolume: Double
    let marketCapRank: Int
    let fullyDilutedValuation: Double?
    let high24H, low24H, priceChange24H, priceChangePercentage24H: Double
    let marketCapChange24H, marketCapChangePercentage24H: Double
    let circulatingSupply, totalSupply, maxSupply, ath: Double?
    let athChangePercentage: Double
    let athDate: String
    let atl, atlChangePercentage: Double
    let atlDate: String
    let lastUpdated: String
    let sparklineIn7D: SparklineIn7D
    
    enum CodingKeys: String, CodingKey, Codable {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case marketCapChange24H = "market_cap_change_24h"
        case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case lastUpdated = "last_updated"
        case sparklineIn7D = "sparkline_in_7d" }
    
    // MARK: - Protocol Conformance
    static func == (lhs: CoinModel, rhs: CoinModel) -> Bool {
        let condition = lhs.id == rhs.id
        && lhs.name == rhs.name
        && lhs.symbol == rhs.symbol
        && lhs.athDate == rhs.athDate
        
        return condition
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(currentPrice)
        hasher.combine(marketCap)
        hasher.combine(totalVolume)
    }
    
    // MARK: - Placeholder data for lazy loading
    static func getPlaceholder() -> CoinModel? {
        guard let JSONData = getPlaceholderJSONData() else { return nil }
        
        do {
            return try JSONParsingHelper.parseJSON(with: CoinModel.self, using: JSONData)
        }
        catch {
            ErrorCodeDispatcher.SwiftErrors.triggerFatalError(for: .jsonCouldNotBeParsed,
                                                              with: "Data: \(JSONData.debugDescription), \(error.localizedDescription)")()
        }
    }
    
    private static func getPlaceholderJSONData() -> Data? {
        return DevEnvironment.shared.testCoinModelJSON.data(using: .utf8)
    }
}

// MARK: - SparklineIn7D
struct SparklineIn7D: Codable { let price: [Double]? }

// MARK: - Encode/decode helpers
class JSONNull: Codable, Hashable {
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool { return true }
    
    func hash(into hasher: inout Hasher) { hasher.combine(0) }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

// MARK: - Other
/// Struct that holds the theme color corresponding to a given coin icon
struct CoinThemeColor: Identifiable, Equatable, Hashable {
    let id: String
    var themeColor: Color
    
    mutating func setThemeColorUsing(image: UIImage) {
        if let color = image.averageColor{
            self.themeColor = Color(color)
        }
        
        // Default back to the app's theme color
        self.themeColor = .accentColor
    }
    
    static func getThemeColorFrom(image: UIImage) -> (UIColor, Color)? {
        guard let color = image.averageColor else { return nil }
        
        return (color, Color(color))
    }
}
