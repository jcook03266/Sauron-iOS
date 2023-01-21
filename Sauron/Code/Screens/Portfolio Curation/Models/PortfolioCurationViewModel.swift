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
    @ObservedObject var router: OnboardingRouter
    
    // MARK: - Published
    @Published var assetIdentifierDisplayType: AssetIdentifierDisplayType = .Name
    @Published var isReloading: Bool = false
    @Published var searchBarTextFieldModel: SatelliteTextFieldModel!
    @Published var coins: [CoinModel] = []
    @Published var portfolioCoins: [PortfolioCoinEntity] = []
    @Published var currentCurrency = Dependencies().fiatCurrencyManager.displayedCurrency
    @Published var filterPortfolioCoins: Bool = false
    
    // MARK: - Subscriptions
    var cancellables: Set<AnyCancellable> = []
    let scheduler: DispatchQueue = DispatchQueue.main
    let coinDataRefreshInterval: CGFloat = 60 // 1 minute auto refresh interval
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let fiatCurrencyManager: FiatCurrencyManager = inject()
        let languageManager: LocalizedLanguageManager = inject()
        let ftueService: FTUEService = inject()
    }
    let dependencies = Dependencies()
    
    // MARK: - Data Store Dependencies
    struct DataStores: InjectableStores {
        let coinStore: CoinStore = inject()
        let portfolioManager: PortfolioManager = inject()
    }
    let dataStores = DataStores()
    
    // MARK: - Models
    var contextMenuModel: FloatingContextMenuViewModel!
    
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
    
    var shouldDisplayNoSearchResultsText: Bool {
        return isCoinsEmpty && (isSearchBarActive || isUserSearching)
    }
    
    var isCoinsEmpty: Bool {
        return coins.isEmpty
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
    
    /// This screen has two states, FTUE and normal, this toggles either feature set
    var shouldDisplayFTUEUI: Bool {
        return !dependencies.ftueService.isComplete
    }
    
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
        return { [weak self] in
            
            HapticFeedbackDispatcher.arrowButtonPress()
            guard let self = self else { return }
            
            self.coordinator.popView()
        }
    }
    
    var continueAction: (() -> Void) {
        return {
            HapticFeedbackDispatcher.interstitialCTAButtonPress()
                
        }
    }
    
    // MARK: - Context Menu Sorting Actions
    var sortByNameAction: (() -> Void) {
        return { [weak self] in
            HapticFeedbackDispatcher.genericButtonPress()
            guard let self = self else { return }
            
            self.dataStores.coinStore.updateSortingCriteria(sortKey: .name,
                                                            ascendingOrder: self.contextMenuModel.sortInAscendingOrder)
        }
    }
    
    var sortByIDAction: (() -> Void) {
        return { [weak self] in
            HapticFeedbackDispatcher.genericButtonPress()
            guard let self = self else { return }
            
            self.dataStores.coinStore.updateSortingCriteria(sortKey: .id,
                                                            ascendingOrder: self.contextMenuModel.sortInAscendingOrder)
        }
    }
    
    var sortByPriceAction: (() -> Void) {
        return { [weak self] in
            HapticFeedbackDispatcher.genericButtonPress()
            guard let self = self else { return }
            
            self.dataStores.coinStore.updateSortingCriteria(sortKey: .price,
                                                            ascendingOrder: self.contextMenuModel.sortInAscendingOrder)
        }
    }
    
    var sortByRankAction: (() -> Void) {
        return { [weak self] in
            HapticFeedbackDispatcher.genericButtonPress()
            guard let self = self else { return }
            
            self.dataStores.coinStore.updateSortingCriteria(sortKey: .rank,
                                                            ascendingOrder: self.contextMenuModel.sortInAscendingOrder)
        }
    }
    
    var sortByVolumeAction: (() -> Void) {
        return { [weak self] in
            HapticFeedbackDispatcher.genericButtonPress()
            guard let self = self else { return }
            
            self.dataStores.coinStore.updateSortingCriteria(sortKey: .volume,
                                                            ascendingOrder: self.contextMenuModel.sortInAscendingOrder)
        }
    }
    
    var sortButtonPressedAction: (() -> Void) {
        return { [weak self] in
            HapticFeedbackDispatcher.genericButtonPress()
            guard let self = self else { return }
            
            hideKeyboard()
            
            self.contextMenuModel.shouldDisplay.toggle()
        }
    }
    
    var currencyPreferenceAction: (() -> Void) {
        return {[weak self] in
            guard let self = self else { return }
            
            HapticFeedbackDispatcher.bottomSheetPresented()
            self.coordinator.presentSheet(with: .currencyPreferenceBottomSheet)
        }
    }
    
    var languagePreferenceAction: (() -> Void) {
        return { [weak self] in
            guard let self = self else { return }
            
            HapticFeedbackDispatcher.genericButtonPress()
            self.dependencies.languageManager.goToAppSettings()
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
        return shouldDisplayFTUEUI ? LocalizedStrings.getLocalizedString(for: .PORTFOLIO_CURATION_SCREEN_TITLE_FTUE_NEWLINE) : LocalizedStrings.getLocalizedString(for: .PORTFOLIO_CURATION_SCREEN_TITLE)
    }
    var continueButtonText: LocalizedStringKey {
        return shouldDisplayFTUEUI ? LocalizedStrings.getLocalizedStringKey(for: .CONTINUE) :  LocalizedStrings.getLocalizedStringKey(for: .DISMISS)
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
        rankHeader = LocalizedStrings.getLocalizedStringKey(for: .PORTFOLIO_CURATION_SCREEN_RANK),
        currencyPreferencesButtonText = LocalizedStrings.getLocalizedStringKey(for: .PORTFOLIO_CURATION_SCREEN_CURRENCY_PREFERENCES_BUTTON),
        languagePreferencesButtonText = LocalizedStrings.getLocalizedStringKey(for: .PORTFOLIO_CURATION_SCREEN_LANGUAGE_PREFERENCES_BUTTON),
        makeChangesLaterPrompt = LocalizedStrings.getLocalizedStringKey(for: .PORTFOLIO_CURATION_SCREEN_MAKE_CHANGES_LATER_PROMPT),
        searchBarPlaceholder = LocalizedStrings.getLocalizedStringKey(for: .PORTFOLIO_CURATION_SCREEN_SEARCHBAR_PLACEHOLDER),
        noSearchResultsText = LocalizedStrings.getLocalizedStringKey(for: .PORTFOLIO_CURATION_SCREEN_NO_SEARCH_RESULTS_NEWLINE)
    
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
        bottomSectionBackgroundColor: Color = Colors.neutral_100.0,
        rankHeaderTextColor: Color = Colors.neutral_400.0
    
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
        noSearchResultsTextFont: FontRepository = .heading_3,
        noSearchResultsTextFontWeight: Font.Weight = .semibold,
        contextPropertiesHeaderFont: FontRepository = .body_S,
        contextPropertiesHeaderFontWeight: Font.Weight = .regular,
        rankHeaderFont: FontRepository = .body_S,
        rankHeaderFontWeight: Font.Weight = .medium
    
    init(coordinator: OnboardingCoordinator,
         router: OnboardingRouter)
    {
        self.coordinator = coordinator
        self.router = router
        self.searchBarTextFieldModel = builtSearchBarTextFieldModel
        self.contextMenuModel = buildContextMenuModel()
        
        addSubscribers()
    }
    
    // MARK: - Model Building
    func anchorContextMenuTo(anchor: CGPoint) {
        contextMenuModel.anchorPoint = anchor
    }
    
    func buildContextMenuModel() -> FloatingContextMenuViewModel {
        let contextMenuViewModel: FloatingContextMenuViewModel = .init()
        let coinStore = dataStores.coinStore
        
        let contextMenuRows: [FloatingContextMenuViewModel.FloatingContextMenuRow] = [
            .init(action: self.sortByNameAction,
                  label: LocalizedStrings.getLocalizedString(for: .SORT_FILTER_CONTEXT_MENU_NAME_OPTION),
                  sideBarIcon: Icons.getIconImage(named: .textformat_abc),
                  isSelected: coinStore.isCurrenSortKey(sortKey: .name)),
            
            .init(action: self.sortByIDAction,
                  label: LocalizedStrings.getLocalizedString(for: .SORT_FILTER_CONTEXT_MENU_ID_OPTION),
                  sideBarIcon: Icons.getIconImage(named: .tag_fill),
                  isSelected: coinStore.isCurrenSortKey(sortKey: .id)),
            
            .init(action: self.sortByPriceAction,
                  label: LocalizedStrings.getLocalizedString(for: .SORT_FILTER_CONTEXT_MENU_PRICE_OPTION),
                  sideBarIcon: Icons.getIconImage(named: .dollarsign_square_fill),
                  isSelected: coinStore.isCurrenSortKey(sortKey: .price)),
            
            .init(action: self.sortByRankAction,
                  label: LocalizedStrings.getLocalizedString(for: .SORT_FILTER_CONTEXT_MENU_RANK_OPTION),
                  sideBarIcon: Icons.getIconImage(named: .list_number),
                  isSelected: coinStore.isCurrenSortKey(sortKey: .rank)),
            
            .init(action: self.sortByVolumeAction,
                  label: LocalizedStrings.getLocalizedString(for: .SORT_FILTER_CONTEXT_MENU_VOLUME_OPTION),
                  sideBarIcon: Icons.getIconImage(named: .flame_fill),
                  isSelected: coinStore.isCurrenSortKey(sortKey: .volume))
        ]
        
        contextMenuViewModel.selectedRow = contextMenuRows.first(where: { $0.isSelected })
        contextMenuViewModel.sortInAscendingOrder = coinStore.isSortOrderAscending
        contextMenuViewModel.rows = contextMenuRows
        contextMenuViewModel.menuTitle = LocalizedStrings.getLocalizedString(for: .SORT_FILTER_CONTEXT_MENU_TITLE)
        
        return contextMenuViewModel
    }
    
    // MARK: - Subscriptions
    private func addSubscribers() {
        // Updates the local coin store with data from the external coin store
        dataStores.coinStore
            .$coins
            .assign(to: &$coins)
        
        // Updates the local portfolio coins store with data from the external manager
        dataStores.portfolioManager
            .$coinEntities
            .assign(to: &$portfolioCoins)
        
        // Updates the coin store's search query whenever the text entry's publisher emits a new value (note: A debounce interval is active)
        searchBarTextFieldModel
            .$textEntry
            .assign(to: &dataStores.coinStore.$activeSearchQuery)
        
        // Pass in external search queries and properties from the deeplinker here
        self.router
            .$portfolioCurationSearchQuery
            .assign(to: &searchBarTextFieldModel.$textEntry)
        
        // Triggers the portfolio coins only filter from an external source
        self.router
            .$filterPortfolioCoinsOnly
            .sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                
                self.dataStores.coinStore.displayPortfolioCoinsOnly = $0
                self.filterPortfolioCoins = $0
            })
            .store(in: &cancellables)
        
        // Sorting order publisher for changing the sort order of coin data
        contextMenuModel
            .$sortInAscendingOrder
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.dataStores.coinStore.changeAscendingSortOrder(to: $0)
            }
            .store(in: &cancellables)
        
        // Auto refresh publisher for refreshing coin data
        Timer.publish(every: coinDataRefreshInterval,
                      on: .main,
                      in: .default)
        .autoconnect()
        .receive(on: scheduler)
        .sink { [weak self] _ in
            guard let self = self
            else { return }
            
            self.refresh()
        }
        .store(in: &cancellables)
    
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
