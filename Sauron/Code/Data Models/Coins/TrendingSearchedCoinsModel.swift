//
//  TrendingSearchedCoinsModel.swift
//  Sauron
//
//  Created by Justin Cook on 2/4/23.
//

import Foundation

struct TrendingSearchedCoinsModel: Codable {
    let coins: [Coin]
    
    // MARK: - Coin
    struct Coin: Codable {
        let metaData: MetaData
        
        enum CodingKeys: String, CodingKey {
            case metaData = "item"
        }
    }
    
    // MARK: - Item
    struct MetaData: Codable {
        let id: String
        let coinID: Int
        let name, symbol: String
        let marketCapRank: Int
        let thumb, small, large: String
        let slug: String
        let priceBtc: Double
        let score: Int
        
        enum CodingKeys: String, CodingKey {
            case id
            case coinID = "coin_id"
            case name, symbol
            case marketCapRank = "market_cap_rank"
            case thumb, small, large, slug
            case priceBtc = "price_btc"
            case score
        }
    }
}
