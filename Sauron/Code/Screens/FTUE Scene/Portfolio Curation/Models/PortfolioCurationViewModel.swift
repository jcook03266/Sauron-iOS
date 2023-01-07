//
//  PortfolioCurationViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 12/29/22.
//

import SwiftUI
import Combine

class PortfolioCurationViewModel: CoordinatedGenericViewModel {
    typealias coordinator = OnboardingCoordinator
    
    // MARK: - Observed
    @ObservedObject var coordinator: OnboardingCoordinator
    
    // MARK: - Published
    @Published var sortButtonToggled: Bool = false
    @Published var assetIdentifierDisplayType: AssetIdentifierDisplayType = .Name
    @Published var isReloading: Bool = false
    @Published var searchBarTextFieldModel: SatelliteTextFieldModel!
    @Published var coins: [CoinModel] = []
    @Published var portfolioCoins: [PortfolioCoinEntity] = []
    
    // MARK: - States
    var filterPortfolioCoins: Bool = false
    
    // MARK: - Subscriptions
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Models
    private var builtSearchBarTextFieldModel: SatelliteTextFieldModel {
        let searchBarTextFieldModel: SatelliteTextFieldModel = .init()
        
        searchBarTextFieldModel.configurator { model in
            // Main properties
            model.title = "Search Bar"
            model.placeholderText = "Search for assets"
            model.satelliteButtonInActiveIcon = Icons.getIconImage(named: .magnifyingglass)
            model.satelliteButtonActiveIcon = Icons.getIconImage(named: .xmark)
            
            // Satellite button
            model.satelliteButtonAction = {
                model.focused.toggle()
                
                let shadowColor = model.focused ? Colors.shadow_2.0 : Colors.shadow_1.0
                model.satelliteButtonShadowColor = shadowColor
                model.shadowColor = shadowColor
            }
        }
        
        return searchBarTextFieldModel
    }
    
    // MARK: - Lazy Loading
    var placeholderCoinData: CoinModel? {
        return CoinModel.getPlaceholder()
    }
    let placeholderViewRange: Range<Int> = 0..<10
    
    // MARK: - Interface variables for convenience
    var searchResultsCount: Int {
        return self.dataStores.coinStore.searchResultCount
    }
    /// The user can only continue once they've added at least one coin to their portfolio
    var canContinue: Bool {
        let condition: Bool = userHasSelectedCoins
        return condition
    }
    
    var userHasSelectedCoins: Bool {
        return !dataStores.portfolioManager.isEmpty
    }
    
    var isSearchBarActive: Bool {
        return searchBarTextFieldModel.focused
    }
    
    var isUserSearching: Bool {
        return !searchBarTextFieldModel.textEntry.isEmpty
    }
    
    var contextPropertiesHasChanged: Bool {
        return Bool.XOR(operands: [isUserSearching,
                                   !isSearchBarActive,
                                   userHasSelectedCoins])
    }
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let fiatCurrencyManager: FiatCurrencyManager = inject()
        let ftueService: FTUEService = inject()
    }
    let dependencies = Dependencies()
    
    // MARK: - Data Store Dependencies
    struct DataStores: InjectableStores {
        let coinStore: CoinStore = inject()
        let portfolioManager: PortfolioManager = inject()
    }
    let dataStores = DataStores()
    
    // MARK: - Actions
    var toggleFilterPortfolioCoins: (() -> Void) {
        return { [weak self] in
            guard let self = self else { return }
            
            self.dataStores.coinStore.displayPortfolioCoinsOnly.toggle()
            self.filterPortfolioCoins = self.dataStores.coinStore.displayPortfolioCoinsOnly
        }
    }
    
    var refresh: (() -> Void) {
        return { [weak self] in
            guard let self = self else { return }
            
            self.isReloading = true
            self.dataStores.coinStore.refresh()
            
            DispatchQueue.main.async {
                self.isReloading = false
            }
        }
    }
    
    var goBackAction: (() -> Void) {
        return {
            HapticFeedbackDispatcher.arrowButtonPress()
            self.coordinator.popView()
        }
    }
    
    var continueAction: (() -> Void) {
        return {
            HapticFeedbackDispatcher.interstitialCTAButtonPress()
        }
    }
    
    var searchAction: (() -> Void) {
        return {
            HapticFeedbackDispatcher.genericButtonPress()
        }
    }
    
    var sortButtonPressedAction: (() -> Void) {
        return {
            HapticFeedbackDispatcher.genericButtonPress()
        }
    }
    
    var currencyPreferenceAction: (() -> Void) {
        return {
            HapticFeedbackDispatcher.bottomSheetPresented()
        }
    }
    
    var languagePreferenceAction: (() -> Void) {
        return {
            HapticFeedbackDispatcher.bottomSheetPresented()
        }
    }
    
    var assetIdentifierHeaderTappedAction: (() -> Void) {
        return { [weak self] in
            guard let self = self else { return }
            
            HapticFeedbackDispatcher.genericButtonPress()
            
            self.assetIdentifierDisplayType = self.assetIdentifierDisplayType == .Name ? .Symbol : .Name
        }
    }
    
    // MARK: - Localized Text
    var assetIdentifierHeader: LocalizedStringKey {
        switch assetIdentifierDisplayType {
        case .Symbol:
            return LocalizedStrings.getLocalizedStringKey(for: .PORTFOLIO_CURATION_SCREEN_ASSET_ID_HEADER)
        case .Name:
            return LocalizedStrings.getLocalizedStringKey(for: .PORTFOLIO_CURATION_SCREEN_ASSET_NAME_HEADER)
        }
    }
    
    var priceHeader: String {
        let localCurrencyString: String = dependencies.fiatCurrencyManager.getCurrentCountryCode()
        
        let localizedCombination = LocalizedStrings.getLocalizedString(for: .PORTFOLIO_CURATION_SCREEN_PRICE_HEADER) + "\n" + "(\(localCurrencyString))"
        
        return localizedCombination
    }
    
    /// Shows the FTUE copy for first time users, else show the regular customization title for returning users that are editing their current portfolios
    var title: String {
        return dependencies.ftueService.isComplete ? LocalizedStrings.getLocalizedString(for: .PORTFOLIO_CURATION_SCREEN_TITLE) : LocalizedStrings.getLocalizedString(for: .PORTFOLIO_CURATION_SCREEN_TITLE_FTUE_NEWLINE)
    }
    
    var searchResultsCounter: String {
        let searchResultCount = dataStores.coinStore.searchResultCount
        
        if searchResultCount == 1 {
            return LocalizedStrings.getLocalizedString(for: .PORTFOLIO_CURATION_SCREEN_SEARCH_RESULT_COUNT_SINGULAR)
        } else if searchResultCount > 1 {
            return LocalizedStrings.getLocalizedString(for: .PORTFOLIO_CURATION_SCREEN_SEARCH_RESULT_COUNT_PLURAL)
        } else {
            return LocalizedStrings.getLocalizedString(for: .PORTFOLIO_CURATION_SCREEN_SEARCH_RESULT_COUNT_NONE)
        }
    }
    
    var coinSelectionCounter: String {
        let portfolioCoinCount = dataStores.portfolioManager.coinEntities.count
        
        if portfolioCoinCount == 1 {
            return LocalizedStrings.getLocalizedString(for: .PORTFOLIO_CURATION_SCREEN_PORTFOLIO_COIN_COUNT_SINGULAR)
        } else if portfolioCoinCount > 1 {
            return LocalizedStrings.getLocalizedString(for: .PORTFOLIO_CURATION_SCREEN_PORTFOLIO_COIN_COUNT_PLURAL)
        } else {
            return ""
        }
    }
    
    let symbolHeader = LocalizedStrings.getLocalizedStringKey(for: .PORTFOLIO_CURATION_SCREEN_SYMBOL_HEADER),
        currencyPreferencesButtonText = LocalizedStrings.getLocalizedStringKey(for: .PORTFOLIO_CURATION_SCREEN_CURRENCY_PREFERENCES_BUTTON),
        languagePreferencesButtonText = LocalizedStrings.getLocalizedStringKey(for: .PORTFOLIO_CURATION_SCREEN_LANGUAGE_PREFERENCES_BUTTON),
        continueButtonText = LocalizedStrings.getLocalizedStringKey(for: .CONTINUE),
        makeChangesLaterPrompt = LocalizedStrings.getLocalizedStringKey(for: .PORTFOLIO_CURATION_SCREEN_MAKE_CHANGES_LATER_PROMPT),
        searchBarPlaceholder = LocalizedStrings.getLocalizedStringKey(for: .PORTFOLIO_CURATION_SCREEN_SEARCHBAR_PLACEHOLDER),
        noSearchResultsText = LocalizedStrings.getLocalizedStringKey(for: .PORTFOLIO_CURATION_SCREEN_NO_SEARCH_RESULTS)
    
    // MARK: - Assets
    var sortButtonIcon: Image {
        return Icons.getIconImage(named: .line_3_horizontal_decrease_circle_fill)
    }
    
    var informationIcon: Image {
        return Icons.getIconImage(named: .info_circle_fill)
    }
    
    // MARK: - Styling
    // Colors / Gradients
    let titleGradient: LinearGradient = Colors.gradient_1,
        backButtonBackgroundColor: Color = Colors.neutral_100.0,
        backButtonForegroundColor: Color = Colors.primary_1.0,
        verticalDividerGradient: LinearGradient = Colors.gradient_1,
        sortButtonGradient: LinearGradient = Colors.gradient_1,
        searchBarButtonBackgroundGradient: LinearGradient = Colors.gradient_1,
        searchBarButtonForegroundColor: Color = Colors.white.0,
        searchBarBackgroundColor: Color = Colors.white.0,
        searchBarBorderGradient: LinearGradient = Colors.gradient_1,
        searchBarForegroundGradient: LinearGradient = Colors.gradient_1,
        searchBarPlaceholderColor: Color = Colors.neutral_600.0,
        searchBarShadowColor: Color = Colors.shadow_2.0,
        assetPropertiesHeaderTextColor: Color = Colors.black.0,
        assetPropertiesHeaderDividerGradient: LinearGradient = Colors.gradient_1,
        assetSymbolContainerBackgroundGradient: LinearGradient = Colors.gradient_1,
        assetSymbolContainerBorderGradient: LinearGradient = Colors.gradient_4,
        preferencesChipletBackgroundColor: Color = Colors.neutral_100.0,
        preferencesChipletTextColor: Color = Colors.black.0,
        contextPropertiesHeaderBackgroundColor: Color = Colors.white.0,
        contextPropertiesHeaderMessageTextColor: Color = Colors.black.0,
        contextPropertiesHeaderMessageBorderGradient: LinearGradient = Colors.gradient_1,
        contextPropertiesHeaderCounterTextGradient: LinearGradient = Colors.gradient_1,
        languagesPreferencesChipletBorderGradient: LinearGradient = Colors.gradient_5,
        currencyPreferencesChipletBorderGradient: LinearGradient = Colors.gradient_4,
        shadowColor: Color = Colors.shadow_1.0,
        continueButtonBackgroundColor: Color = Colors.permanent_black.0,
        continueButtonForegroundColor: Color = Colors.permanent_white.0,
        makeChangesLaterPromptTextColor: Color = Colors.neutral_600.0,
        makeChangesLaterPromptIconGradient: LinearGradient = Colors.gradient_1,
        searchResultsCountNumberGradient: LinearGradient = Colors.gradient_1,
        searchResultsCountCopyTextColor: Color = Colors.black.0,
        noSearchResultsTextGradient: LinearGradient = Colors.gradient_1,
        bottomSectionBackgroundColor: Color = Colors.neutral_100.0
    
    // Fonts
    let assetPropertiesHeaderFont: FontRepository = .special_heading_2,
        assetPropertiesHeaderFontWeight: Font.Weight = .semibold,
        preferencesChipletFont: FontRepository = .body_S,
        preferencesChipletFontWeight: Font.Weight = .semibold,
        continueCTAFont: FontRepository = .body_L_Bold,
        makeChangesLaterPromptFont: FontRepository = .body_S,
        makeChangesLaterPromptFontWeight: Font.Weight = .regular,
        titleFont: FontRepository = .heading_2,
        titleFontWeight: Font.Weight = .semibold,
        searchResultsCountFont: FontRepository = .body_M,
        searchResultsCountFontWeight: Font.Weight = .regular,
        noSearchResultsTextFont: FontRepository = .heading_4,
        noSearchResultsTextFontWeight: Font.Weight = .semibold,
        contextPropertiesHeaderFont: FontRepository = .body_S,
        contextPropertiesHeaderFontWeight: Font.Weight = .regular
    
    init(coordinator: OnboardingCoordinator) {
        self.coordinator = coordinator
        self.searchBarTextFieldModel = builtSearchBarTextFieldModel
        
        addSubscribers()
    }
    
    // MARK: - Subscriptions
    func addSubscribers() {
        dataStores.coinStore
            .$coins
            .assign(to: &$coins)
        
        dataStores.portfolioManager
            .$coinEntities
            .assign(to: &$portfolioCoins)
        
        // Update the coin store's search query whenever the text entry's publisher emits a new value (note: A debounce interval is active)
        searchBarTextFieldModel
            .$textEntry
            .assign(to: &dataStores.coinStore.$activeSearchQuery)
    }
    
    // MARK: - Convenience Methods
    func doesCoinExistInPortfolio(coin: CoinModel) -> Bool {
        return dataStores.portfolioManager.doesCoinExistInPortfolio(coin: coin)
    }
    
    /// Determines which asset identifier to display in the table
    enum AssetIdentifierDisplayType: CaseIterable {
        case Symbol, Name
    }
}
