//
//  CoinListInformationViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/30/23.
//

import SwiftUI
import Combine

class CoinListInformationViewModel: GenericViewModel {
    // MARK: - Properties
    var displayTimeScale: Bool = true
    
    // MARK: - Published
    @Published var coinModel: CoinModel
    @Published var selectedTimeScale: CoinModel.TimeScale = .one_hour
    
    // MARK: - Subscriptions
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let currencyManager: FiatCurrencyManager = inject()
    }
    let dependencies = Dependencies()
    
    // MARK: - Data Store Dependencies
    struct DataStores: InjectableStores {
        let coinStore: CoinStore = inject()
        let portfolioManager: PortfolioManager = inject()
    }
    let dataStores = DataStores()
    
    // MARK: - Styling
    // Colors
    let coinImageContainerBorderGradient: LinearGradient = Colors.gradient_4,
        coinIDBackgroundColor: Color = Colors.permanent_black.0,
        coinIDFontColor: Color = Colors.neutral_500.0,
        percentageChangeChipBackgroundColor: Color = Colors.permanent_white.0,
        shadowColor: Color = Colors.shadow_1.0,
        coinNameFontColor: Color = Colors.black.0,
        priceLabelNumericalFontColor: Color = Colors.permanent_white.0,
        priceLabelCurrencySymbolFontColor: Color = Colors.permanent_white.0,
        dashedDividerLineColor: Color = Colors.black.0,
        priceChangeSignIndicatorForegroundColor: Color = Colors.permanent_white.0,
        metaDataInformationSectionBackgroundColor: Color = Colors.white.0,
        metaDataInformationSectionBorderColor: Color = Colors.black_45.0,
        metaDataInformationSectionBorderGradient: LinearGradient = Colors.gradient_5
    
    var coinThemeColor: Color {
        return dataStores
            .coinStore
            .getThemeColor(for: coinModel) ?? Colors.primary_3.0
    }
    
    var coinImageContainerBackgroundColor: Color {
        return Colors.permanent_white.0
    }
    
    var priceLabelBackgroundColor: Color {
        return Colors.black_45.0
    }
    
    var percentageChangeChipFontColor: Color {
        return wasPriceChangePositive ? Colors.primary_2.0 : Colors.attention.0
    }
    
    var priceChangeSignIndicatorBackgroundColor: Color {
        return wasPriceChangePositive ? Colors.primary_2.0 : Colors.attention.0
    }
    
    // Fonts
    let coinNameFont: FontRepository = .body_XS,
        coinNameFontWeight: Font.Weight = .semibold,
        coinIDFont: FontRepository = .body_3XS,
        coinIDFontWeight: Font.Weight = .semibold,
        percentageChangeChipFont: FontRepository = .body_2XS,
        percentageChangeChipFontWeight: Font.Weight = .semibold,
        priceLabelFont: FontRepository = .body_2XS,
        priceLabelFontWeight: Font.Weight = .semibold
    
    // MARK: - Text
    var coinName: String {
        return coinModel.name
    }
    
    var coinIDText: String {
        return displayTimeScale ? coinIDTimeScaleText : coinID
    }
    
    private var coinIDTimeScaleText: String {
        return coinID + " ~ " + selectedTimeScaleStringLiteral
    }
    
    private var coinID: String {
        return coinModel.symbol.uppercased()
    }
    
    var selectedTimeScaleStringLiteral: String {
        return selectedTimeScale.rawValue
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
    @ObservedObject var miniChartViewModel: MiniHistoricalChartViewModel
    
    // MARK: - Data Manipulation
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
    
    var isCoinInUserPortfolio: Bool {
        return dataStores
            .portfolioManager
            .doesCoinExistInPortfolio(coin: coinModel)
    }
    
    // MARK: - Convenience
    
    init(coinModel: CoinModel) {
        self.coinModel = coinModel
        self.coinImageViewModel = .init(coinModel: coinModel)
        self.miniChartViewModel = .init(coinModel: coinModel)
    }
}
