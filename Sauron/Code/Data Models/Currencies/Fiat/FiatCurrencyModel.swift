//
//  FiatCurrencyModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/14/23.
//

import Foundation

struct FiatCurrency: Identifiable, Hashable {
    let id: UUID = UUID()
    let currencyCode,
        currencySymbol: String
}

