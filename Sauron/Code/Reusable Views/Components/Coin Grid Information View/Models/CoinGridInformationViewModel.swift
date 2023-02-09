//
//  CoinGridInformationViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/29/23.
//

import SwiftUI
import Combine

class CoinGridInformationViewModel: GenericViewModel {
    // MARK: - Properties
    /// Only allow the user to pick between these two possible time scales for this view
    let allowedTimeScales: [CoinModel.TimeScale] = [.one_hour,
                                                    .one_day]
    
    // MARK: - Published
    @Published var coinModel: CoinModel
    @Published var selectedTimeScale: CoinModel.TimeScale = .one_hour
    @Published var selectedTimeScaleIndex: Int = 0
    
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
    }
    let dataStores = DataStores()
    
    // MARK: - Styling
    // Colors
    let coinImageContainerBorderGradient: LinearGradient = Colors.gradient_4,
        coinIDBackgroundColor: Color = Colors.permanent_black.0,
        coinIDFontColor: Color = Colors.permanent_white.0,
        percentageChangeChipBackgroundColor: Color = Colors.permanent_white.0,
        shadowColor: Color = Colors.shadow_1.0,
        coinNameFontColor: Color = Colors.neutral_600.0,
        timeScaleSelectorButtonFontColor: Color = Colors.permanent_white.0,
        timeScaleSelectorButtonBackgroundColor: Color = Colors.primary_3.0,
        graphBorderGradient: LinearGradient = Colors.gradient_1,
        coinImageContainerBackgroundColor: Color = Colors.permanent_white.0,
        priceLabelNumericalFontColor: Color = Colors.permanent_white.0,
        priceLabelCurrencySymbolFontColor: Color = Colors.permanent_white.0
    
    var coinThemeColor: Color {
        return dataStores
            .coinStore
            .getThemeColor(for: coinModel) ?? Colors.primary_3.0
    }
        
    var priceLabelBackgroundColor: Color {
        return coinThemeColor.opacity(0.75)
    }
    
    var percentageChangeChipFontColor: Color {
        return wasPriceChangePositive ? Colors.primary_2.0 : Colors.attention.0
    }
    
    var graphSupplementaryBackgroundViewColor: Color {
        return coinThemeColor.opacity(0.75)
    }
    
    // Fonts
    let coinNameFont: FontRepository = .body_2XS,
        coinNameFontWeight: Font.Weight = .semibold,
        timeScaleSelectorButtonFont: FontRepository = .body_XS_Bold,
        coinIDFont: FontRepository = .body_XS,
        coinIDFontWeight: Font.Weight = .semibold,
        percentageChangeChipFont: FontRepository = .body_2XS,
        percentageChangeChipFontWeight: Font.Weight = .semibold,
        priceLabelFont: FontRepository = .body_2XS,
        priceLabelFontWeight: Font.Weight = .semibold
    
    // MARK: - Text
    var coinName: String {
        return coinModel.name
    }
    
    var coinID: String {
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
    
    // MARK: - Actions
    var timeScaleSelectorButtonAction: (() -> Void) {
        return { [weak self] in
            guard let self = self
            else { return }
            
            // Iterate to the next time scale (if any), if none then get the first element, if none then revert back to the default value provided
            self.selectedTimeScale = self.allowedTimeScales.last(where: {
                $0 != self.selectedTimeScale
            }) ?? self.allowedTimeScales.first ?? self.selectedTimeScale
            
            self.updatePageBarPage()
        }
    }
    
    // MARK: - Models
    @ObservedObject var coinImageViewModel: CoinImageViewModel
    @ObservedObject var miniChartViewModel: MiniHistoricalChartViewModel
    @Published var pageBarViewModel: PageBarViewModel!
    
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
    
    var allowedTimeScalesCount: UInt {
        return UInt(allowedTimeScales.count)
    }
    
    /// The index of the currently selected time scale in the allowed time scales array
    var selectedTimeScaleIndexInAllowedTimeScales: Int {
        return allowedTimeScales.firstIndex(of: self.selectedTimeScale) ?? 0
    }
    
    init(coinModel: CoinModel) {
        self.coinModel = coinModel
        self.coinImageViewModel = .init(coinModel: coinModel)
        self.miniChartViewModel = .init(coinModel: coinModel)
        self.pageBarViewModel = .init(totalPages: allowedTimeScalesCount,
                                      shrinkInactiveBars: false)
    }
    
    // MARK: - UI Updating
    func updatePageBarPage() {
        self.pageBarViewModel.currentPage = selectedTimeScaleIndexInAllowedTimeScales
    }
}
