//
//  LatestExchangeRatesModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/14/23.
//

import Foundation

/// Stores the latest exchange rates for the base currency 'USD' | USD -> All
struct LatestExchangeRateModel: Codable {
    let rates: [String : Double]
}
