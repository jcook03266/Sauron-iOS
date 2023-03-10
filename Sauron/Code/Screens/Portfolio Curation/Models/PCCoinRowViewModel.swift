//
//  PCCoinRowViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 12/31/22.
//

import SwiftUI
import Combine

class PCCoinRowViewModel: GenericViewModel {
    // MARK: - Observed Objects
    @ObservedObject var parentViewModel: PortfolioCurationViewModel
    @ObservedObject var coinImageViewModel: CoinImageViewModel
    
    // MARK: - Published
    @Published var coinModel: CoinModel
    @Published var isSelected: Bool = false
    
    // MARK: - Convenience
    var currencyManager: FiatCurrencyManager {
        return parentViewModel.dependencies.fiatCurrencyManager
    }
    
    var assetMarketCapRank: String {
        return String(coinModel.marketCapRank)
    }
    
    var assetIdentifier: String {
        switch parentViewModel.assetIdentifierDisplayType {
        case .Symbol:
            return coinModel.symbol.uppercased()
        case .Name:
            return coinModel.name.capitalizeAllFirstLetters
        }
    }
    
    /// With currency symbol
    var priceConvertedToCurrency: String {
        return currencyManager.convertToCurrencyFormat(number: coinModel.currentPrice as NSNumber)
    }
    
    /// Without symbol attached to the front of the string
    var trimmedPriceConvertedToCurrency: String {
        let currencySymbol = currencyManager.getCurrentSymbol().rawValue
        
        return currencyManager.convertToCurrencyFormat(number: coinModel.currentPrice as NSNumber)
            .replacingOccurrences(of: currencySymbol, with: "")
    }
    
    var currencySymbol: String {
        return currencyManager.getCurrentSymbol().rawValue
    }
    
    // MARK: - Data Store Dependencies
    struct DataStores: InjectableStores {
        let portfolioManager: PortfolioManager = inject()
    }
    let dataStores = DataStores()
    
    // MARK: - Styling
    // MARK: - Fonts
    let assetIdentifierTextFont: FontRepository = .body_S,
        assetIdentifierTextFontWeight: Font.Weight = .semibold,
        assetPriceTextFont: FontRepository = .body_S,
        assetPriceTextFontWeight: Font.Weight = .semibold,
        rankTextFont: FontRepository = .body_S,
        rankTextFontWeight: Font.Weight = .semibold
    
    // MARK: - Actions
    var selectedAction: (() -> Void) {
        return { [weak self] in
            guard let self = self else { return }
            
            HapticFeedbackDispatcher.genericButtonPress()
            self.isSelected.toggle()
            
            self.updateCoinSelectionState()
        }
    }
    
    init(parentViewModel: PortfolioCurationViewModel,
         coinModel: CoinModel,
         isSelected: Bool = false)
    {
        self.parentViewModel = parentViewModel
        self.coinModel = coinModel
        self.coinImageViewModel = .init(coinModel: coinModel)
        self.isSelected = isSelected
    }
    
    private func updateCoinSelectionState() {
        self.isSelected ? dataStores.portfolioManager.addCoin(coin: coinModel) : dataStores.portfolioManager.removeCoin(coin: coinModel)
    }
    
    private func updateDataStore() {
        dataStores.portfolioManager.reload()
    }
}
