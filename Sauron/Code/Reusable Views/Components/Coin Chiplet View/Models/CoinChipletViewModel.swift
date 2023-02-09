//
//  CoinChipletViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 2/4/23.
//

import SwiftUI
import Combine

class CoinChipletViewModel: GenericViewModel {
    // MARK: - Published
    @Published var coinModel: CoinModel
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let currencyManager: FiatCurrencyManager = inject()
    }
    let dependencies = Dependencies()
    
    // MARK: - Styling
    // Colors + Gradients
    let borderGradient: LinearGradient = Colors.gradient_5,
        backgroundColor: Color = Colors.white.0,
        coinIDFontColor: Color = Colors.black.0,
        coinNameFontColor: Color = Colors.neutral_400.0,
        priceLabelFontColor: Color = Colors.neutral_600.0,
        priceChangeSignIndicatorForegroundColor: Color = Colors.permanent_white.0,
        priceChangeSignPositiveIndicatorGradient: LinearGradient = Colors.gradient_6,
        priceChangeSignNegativeIndicatorColor: Color = Colors.attention.0,
        priceChangePositiveGradient: LinearGradient = Colors.gradient_1,
        priceChangeNegativeColor: Color = Colors.attention.0,
        coinImageContainerBackgroundColor: Color = Colors.permanent_white.0,
        shadowColor: Color = Colors.shadow_1.0
    
    // Fonts
    let coinNameFont: FontRepository = .body_3XS,
        coinNameFontWeight: Font.Weight = .semibold,
        coinIDFont: FontRepository = .body_S,
            coinIDFontWeight: Font.Weight = .semibold,
        coinPriceFont: FontRepository = .body_2XS,
        coinPriceFontWeight: Font.Weight = .medium,
        priceChangeFont: FontRepository = .body_3XS,
        priceChangeFontWeight: Font.Weight = .semibold,
        priceLabelFont: FontRepository = .body_2XS,
        priceLabelFontWeight: Font.Weight = .medium
    
    // MARK: - Text
    var coinName: String {
        return coinModel.name
    }
    
    var coinID: String {
        return coinModel.symbol.uppercased()
    }
    
    /// String represented numerical currency without symbol attached to the front of the string
    var trimmedPriceConvertedToCurrency: String {
        let currencySymbol = dependencies
            .currencyManager
            .getCurrentSymbol().rawValue
        
        return dependencies
            .currencyManager
            .convertToCurrencyFormat(number: coinModel.currentPrice as NSNumber)
            .replacingOccurrences(of: currencySymbol, with: "")
    }
    
    var currencySymbol: String {
        return dependencies
            .currencyManager
            .getCurrentSymbol()
            .rawValue
    }
    
    var priceChangePercentageFormattedText: String {
        var priceChangePercentageText = ""
        priceChangePercentageText += wasPriceChangePositive ? "+" : "-"
        priceChangePercentageText += FormattingHelper.convertToPercentage(number: abs(priceChangePercentage))
        
        return priceChangePercentageText
    }
    
    // MARK: - Assets
    var priceChangeSignIndicatorArrow: Image {
        return wasPriceChangePositive ? Icons.getIconImage(named: .arrow_up_forward) : Icons.getIconImage(named: .arrow_down_forward)
    }
    
    // MARK: - Actions
    
    // MARK: - Models
    @ObservedObject var coinImageViewModel: CoinImageViewModel
    
    // MARK: - Data Manipulation / Convenience
    var chartData: [Double] {
        return coinModel.sparklineIn7D.price ?? []
    }
    
    var priceChange: Double {
        return (chartData.last ?? 0) - (chartData.first ?? 0)
    }
    
    var priceChangePercentage: Double {
        return (priceChange / coinModel.currentPrice) * 100
    }
    
    var wasPriceChangePositive: Bool {
        return priceChange >= 0
    }
    
    init(coinModel: CoinModel) {
        self.coinModel = coinModel
        self.coinImageViewModel = .init(coinModel: coinModel)
    }
}
