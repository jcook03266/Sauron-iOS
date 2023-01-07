//
//  PortfolioModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/5/23.
//

import Foundation
import SwiftUI

class Portfolio: ObservableObject {
    // MARK: - Published
    @Published var coins: [PortfolioCoinEntity] = []
    
    // MARK: - Statistics
    var created: Date = .now
    var lastUpdate: Date = .now
    
    // For coding and decoding properties attributed to the portfolio coin entity
    enum EntityCodingKeys: String, Codable, CaseIterable {
        case coinID,
             lastUpdate,
             totalViews,
             addDate
    }
}
