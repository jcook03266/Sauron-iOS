//
//  HomeScreenViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/21/23.
//

import SwiftUI
import Combine

/// View model for the home screen tab in the main coordinator
class HomeScreenViewModel: CoordinatedGenericViewModel {
    typealias coordinator = HomeTabCoordinator
    
    // MARK: - Properties
    /// The maximum amount of elements to display on the home screen for each section, if the user wants to see all the data then they have to navigate to the respective detail view
    let maxElementCount: Int = 5
    
    // MARK: - Observed
    @ObservedObject var coordinator: coordinator
    /// Strong reference to the target router for listening to published values from deeplink parsing
    @ObservedObject var router: HomeTabRouter
    @ObservedObject var eventBannerCarouselViewModel: SRNEventBannerViewModel
    /// Pending Feature Campaign
    @ObservedObject var FFRScreenViewModel: FFRScreenViewModel<coordinator>
    
    // MARK: - Published
    // Data Cycling
    @Published var isReloading: Bool = false
    
    // Deeplinking Fragment
    @Published var selectedSection: Sections? = nil
    // Greeting Message Display
    @Published var userHasSeenHomepage: Bool = false
    // Navigation
    @Published var sheetItemState: HomeRoutes? = nil
    @Published var fullCoverItemState: HomeRoutes? = nil
    @Published var navigationPath: [HomeRoutes] = []
    
    // MARK: - Section States
    @Published var portfolioSectionMaximized: Bool = false
    
    // MARK: - Data Sources
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    
    // MARK: - Sorting Parameters
    /// Highest values to lowest
    @Published var portfolioSectionSortIsDescending: Bool = true
    
    // MARK: - Subscriptions
    private var cancellables: Set<AnyCancellable> = []
    private let scheduler: DispatchQueue = DispatchQueue.main
    
    // MARK: - Mock data for placeholders and lazy loading
    var placeholderCoinData: CoinModel? {
        return CoinModel.getPlaceholder()
    }
    let placeholderViewRange: Range<Int> = 0..<5
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        lazy var userManager: UserManager = HomeScreenViewModel.Dependencies.inject()
        lazy var appService: AppService = HomeScreenViewModel.Dependencies.inject()
    }
    var dependencies = Dependencies()
    
    // MARK: - Data Stores
    struct DataStores: InjectableStores {
        let portfolioManager: PortfolioManager = inject()
        let coinStore: CoinStore = inject()
    }
    let dataStores = DataStores()
    
    // MARK: - Styling
    // Colors
    // Shared
    let backgroundColor: Color = Color.clear,
        foregroundContainerColor: Color = Colors.neutral_100.0,
        shadowColor: Color = Colors.shadow_1.0,
        titleForegroundColor: Color = Colors.permanent_white.0,
        titleIconForegroundColor: Color = Colors.permanent_white.0,
        sectionDividerColor: Color = Colors.neutral_200.0,
        sectionHeaderTitleColor: Color = Colors.black.0,
        utilityButtonTitleColor: Color = Colors.permanent_white.0,
        utilityButtonBackgroundColor: Color = Colors.permanent_black.0,
        specializedUtilityButtonTitleGradient: LinearGradient = Colors.gradient_1,
        specializedUtilityButtonBackgroundColor: Color = Colors.permanent_white.0,
        // My Portfolio
        portfolioHeaderIconGradient: LinearGradient = Colors.gradient_1,
        portfolioSectionPlaceholderImageColor: Color = Colors.black.0,
        portfolioSectionPlaceholderButtonBackgroundColor: Color = Colors.permanent_black.0,
        portfolioSectionPlaceholderButtonForegroundColor: Color = Colors.permanent_white.0,
        portfolioSectionPlaceholderButtonShadowColor: Color = Colors.shadow_2.0,
        // Crypto News Section
        cryptoNewsSectionTitleGradient: LinearGradient = Colors.gradient_1,
        cryptoNewsImageColor: Color = Colors.black.0
    
    // Fonts
    let titleFont: FontRepository = .heading_2,
        titleFontWeight: Font.Weight = .semibold,
        // Shared
        sectionHeaderTitleFont: FontRepository = .heading_3,
        sectionHeaderTitleFontWeight: Font.Weight = .semibold,
        utilityButtonTitleFont: FontRepository = .body_S_Bold,
        specializedUtilityButtonTitleFont: FontRepository = .body_XS_Bold,
        // My Portfolio
        portfolioSectionPlaceholderButtonFont: FontRepository = .body_L_Bold,
        // Crypto News
        cryptoNewsSectionTitleFont: FontRepository = .heading_4,
        cryptoNewsSectionTitleFontWeight: Font.Weight = .semibold
    
    // MARK: - Assets
    // My Portfolio
    let portfolioSectionIcon: Image = Icons.getIconImage(named: .chart_pie_fill),
        portfolioSectionPlaceholderImage: Image = Images.getImage(named: .placeholder_coin_stack_three),
        // Crypto News Section
        cryptoNewsSectionIcon: Image = Icons.getIconImage(named: .mic_circle_fill)
    
    // MARK: - Localized Text
    // My Portfolio
    let portfolioSectionTitle: String = LocalizedStrings.getLocalizedString(for: .HOME_SCREEN_SECTION_TITLE_MY_PORTFOLIO),
        portfolioSectionSortButtonTitle: String = LocalizedStrings.getLocalizedString(for: .VOLUME),
        portfolioSectionPlaceholderButtonTitle: String = LocalizedStrings.getLocalizedString(for: .HOME_SCREEN_SECTION_MY_PORTFOLIO_PLACEHOLDER_BUTTON_TITLE),
        // Crypto News
        cryptoNewsSectionTitle: String = LocalizedStrings.getLocalizedString(for: .HOME_SCREEN_SECTION_TITLE_CRYPTO_NEWS),
        // Shared
        showAllButtonTitle: String = LocalizedStrings.getLocalizedString(for: .SHOW_ALL),
        editButtonTitle: String = LocalizedStrings.getLocalizedString(for: .EDIT),
        maximizeButtonTitle: String = LocalizedStrings.getLocalizedString(for: .MAXIMIZE),
        minimizeButtonTitle: String = LocalizedStrings.getLocalizedString(for: .MINIMIZE)
    
    // Dynamic Text | Portfolio Section
    var portfolioSectionTransitionButtonTitle: String {
        return portfolioSectionMaximized ? maximizeButtonTitle : minimizeButtonTitle
    }
    
    // MARK: - Deeplinks
    /// Moves the user to the edit screen and selects only the coins in their portfolio
    var editPortfolioDeeplink: URL? {
        let filterPortfolioCoinsOnlyTag = DeepLinkManager
            .DeepLinkConstants
            .portfolioCoinsOnlyFilterTag
        
        let tagArgument = true.description
        
        return DeepLinkBuilder
            .buildDeeplinkFor(routerDirectory: .HomeRoutes,
                              directories: [HomeRoutes.editPortfolio.rawValue],
                              parameters: [filterPortfolioCoinsOnlyTag : tagArgument])
    }
    
    // MARK: - Actions
    // Data Cycling
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
    
    // My Portfolio
    /// Push the user to the portfolio creation screen where they can create a portfolio if they don't have one currently
    var createPorfolioAction: (() -> Void) {
        return { [weak self] in
            guard let self = self
            else { return }
            
            self.coordinator
                .pushView(with: .editPortfolio)
        }
    }
    
    // Push the corresponding detail view for the full list / grid view
    var showAllPortfolioCoinsAction: (() -> Void) {
        return {}
    }
    
    // Same as create action
    var editPortfolioAction: (() -> Void) {
        return { [weak self] in
            guard let self = self,
                  let editPortfolioDeeplink = self.editPortfolioDeeplink
            else { return }
            
            self.dependencies
                .appService
                .deepLinkManager
                .manage(editPortfolioDeeplink)
        }
    }
    
    // Shrinks / Enlarges the portfolio section into a list instead of a grid
    var transitionPortfolioSectionAction: (() -> Void) {
        return { [weak self] in
            guard let self = self
            else { return }
            
            self.portfolioSectionMaximized.toggle()
        }
    }
    
    // TODO: - Create Daily Message Service For dynamic user message prompts for returning users, and first time users
    var title: String {
        return LocalizedStrings.getLocalizedString(for: .HOME_SCREEN_GREETING_RETURNING_USER_1)
    }
    
    // MARK: - Convenience
    /// Detect whether or not the event banner has multiple events loaded up
    var isEventBannerSingular: Bool {
        return !eventBannerCarouselViewModel.hasMultipleEvents
    }
    
    /// If the user's portfolio is empty for some reason then prompt them to populate it
    var isPortfolioEmpty: Bool {
        return dataStores
            .portfolioManager
            .isEmpty
    }
    
    var isCoinStoreEmpty: Bool {
        return dataStores
            .coinStore
            .coins
            .isEmpty
    }
    
    /// If the user's portfolio is loading then display placeholder values
    var portfolioIsLoading: Bool {
       return !isPortfolioEmpty && isCoinStoreEmpty
    }
    
    var shouldDisplayPortfolioSectionPlaceholder: Bool {
        return isPortfolioEmpty
    }
    
    var shouldDisplayGreeting: Bool {
        return !dependencies
            .userManager
            .currentUser
            .hasVisitedHomeScreen
    }
    
    // MARK: - Models
    var portfolioSortButtonViewModel: RectangularSortButtonViewModel {
        return .init(sortIconType: .pointer,
                     sortOrderIsDescending: self.portfolioSectionSortIsDescending,
                     userTriggeredDescendingSortOrderToggleAction: { [weak self] in
            guard let self = self
            else { return false }
            
            self.portfolioSectionSortIsDescending.toggle()
            return self.portfolioSectionSortIsDescending
        }(),
                     title: portfolioSectionSortButtonTitle)
    }
    
    init(coordinator: coordinator,
         router: HomeTabRouter)
    {
        self.coordinator = coordinator
        self.router = router
        self.FFRScreenViewModel = .init(coordinator: coordinator,
                                        targetMailingListSubscriptionType: .cryptoNewsRelease,
                                        useLongFormat: false)
        self.eventBannerCarouselViewModel = .init()
        
        addSubscribers()
    }
    
    func addSubscribers() {
        // MARK: - Navigation
        self.router
            .$homeScreenSectionFragment
            .assign(to: &$selectedSection)
        
        self.coordinator
            .$sheetItem
            .assign(to: &$sheetItemState)
        
        self.coordinator
            .$fullCoverItem
            .assign(to: &$fullCoverItemState)
        
        self.coordinator
            .$navigationPath
            .assign(to: &$navigationPath)
        
        // MARK: - Data Providers
        dataStores
            .coinStore
            .$coins
            .receive(on: scheduler)
            .assign(to: &$allCoins)
        
        /// Portfolio Coins sorted by 'Performance' aka 24h volume
        $portfolioSectionSortIsDescending
            .combineLatest(
                dataStores
                    .coinStore
                    .$portfolioCoins
            )
            .receive(on: scheduler)
            .compactMap({ [weak self] publishers in
                guard let self = self
                else { return publishers.1 }
                
                let isDescendingSortOrder = publishers.0,
                    coins = publishers.1,
                    coinStore = self.dataStores.coinStore,
                    sortKeyType = coinStore
                    .sortKey.getVolumeType()
                
                return Array(coinStore
                    .sort(coins: coins,
                          ascending: !isDescendingSortOrder,
                          sortKey: .volume,
                          sortKeyType: sortKeyType)
                    .prefix(self.maxElementCount))
            })
            .assign(to: &$portfolioCoins)
    }
    
    // MARK: - Transient Content Control
    /// Hides the daily greeting from the home screen after a 10 second delay
    func setUserHasSeenHomeScreen() {
        guard let currentUser = dependencies
            .userManager
            .currentUser,
              !currentUser.hasVisitedHomeScreen
        else {
            userHasSeenHomepage = true
            return
        }
        
        let delay = TimeInterval(10)
        
        DispatchQueue
            .main
            .asyncAfter(deadline: .now() + delay)
        {
            /// Inform observers that this observable object will change w/o requiring this value to be published
            currentUser.hasVisitedHomeScreen = true
            self.userHasSeenHomepage = true
        }
    }
    
    // MARK: - Section Selection
    /// Called from the view to scroll to the newly selected section
    func scrollToSelectedSection(with proxy: ScrollViewProxy) {
        guard let selectedSection = selectedSection
        else { return }
        
        proxy.scrollTo(selectedSection)
        resetSelectedSectionOnScroll()
    }
    
    /// Triggers the scrollview to scroll to the newly selected section
    func changeSelectedSection(to section: Sections) {
        selectedSection = section
    }
    
    /// The selected section has to be reset when the scrollview scrolls to the section already,
    /// otherwise if a person deeplinks back with the same fragment the scrollview won't scroll to the section it's supposed to
    private func resetSelectedSectionOnScroll() {
        selectedSection = nil
    }
    
    // MARK: - Sections | Allows ScrollView Reader to scroll to specific views when deeplinking with a URL using anchors / fragments
    enum Sections: String, CaseIterable {
        case eventBanner = "events"
        case myPortfolio = "my portfolio"
        case allAssets = "all assets"
        case highPerformers = "highs"
        case lowPerformers = "lows"
        case predictions
        case news
        
        // MARK: - URL Building For Fragmented HomeTab Deeplinks
        func getURL() -> URL? {
            DeepLinkBuilder.buildDeeplinkFor(routerDirectory: .HomeRoutes,
                                             fragment: self.rawValue.getURLSafeString())
        }
        
        func getURLString() -> String? {
            return self.getURL()?.asString
        }
    }
}
