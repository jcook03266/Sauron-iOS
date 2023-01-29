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
    
    // MARK: - Observed
    @ObservedObject var coordinator: coordinator
    /// Strong reference to the target router for listening to published values from deeplink parsing
    @ObservedObject var router: HomeTabRouter
    @ObservedObject var eventBannerCarouselViewModel: SRNEventBannerViewModel
    /// Pending Feature Campaign
    @ObservedObject var FFRScreenViewModel: FFRScreenViewModel<coordinator>
    
    // MARK: - Published
    @Published var selectedSection: Sections? = nil
    // Navigation
    @Published var sheetItemState: HomeRoutes? = nil
    @Published var fullCoverItemState: HomeRoutes? = nil
    @Published var navigationPath: [HomeRoutes] = []
    
    // MARK: - Subscriptions
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let userManager: UserManager = inject()
    }
    let dependencies = Dependencies()
    
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
        titleForegroundColor: Color = Colors.permanent_white.0,
        titleIconForegroundColor: Color = Colors.permanent_white.0,
        sectionDividerColor: Color = Colors.neutral_200.0,
        sectionHeaderTitleColor: Color = Colors.black.0,
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
        portfolioSectionSortButtonTitle: String = LocalizedStrings.getLocalizedString(for: .PERFORMANCE),
        portfolioSectionPlaceholderButtonTitle: String = LocalizedStrings.getLocalizedString(for: .HOME_SCREEN_SECTION_MY_PORTFOLIO_PLACEHOLDER_BUTTON_TITLE),
        // Crypto News
        cryptoNewsSectionTitle: String = LocalizedStrings.getLocalizedString(for: .HOME_SCREEN_SECTION_TITLE_CRYPTO_NEWS)
    
    // MARK: - Actions
    /// Push the user to the portfolio creation screen where they can create a portfolio if they don't have one currently
    var createPorfolioAction: (() -> Void) {
        return { [weak self] in
            guard let self = self
            else { return }
            
            self.coordinator
                .pushView(with: .editPortfolio)
        }
    }
    
    // TODO: - Create Daily Message Service For dynamic user message prompts for returning users, and first time users
    var title: String {
        return LocalizedStrings.getLocalizedString(for: .HOME_SCREEN_GREETING_RETURNING_USER_1)
    }
    
    // MARK: - Convenience
    /// Detect whether or not the event banner has multiple events loaded up
    var isEventBannerSingular: Bool {
        return eventBannerCarouselViewModel.totalPages <= 1
    }
    
    /// If the user's portfolio is empty for some reason then prompt them to populate it
    var isPortfolioEmpty: Bool {
        return dataStores
            .portfolioManager
            .isEmpty
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
                     sortOrderIsDescending: true,
                     userTriggeredDescendingSortOrderToggleAction: .random(),
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
    }
    
    // MARK: - Transient Content Control
    /// Hides the daily greeting from the home screen after a 10 second delay
    func setUserHasSeenHomeScreen() {
        guard let currentUser = dependencies
            .userManager
            .currentUser,
              !currentUser.hasVisitedHomeScreen
        else { return }
        
        let delay = TimeInterval(10)
        
        DispatchQueue
            .main
            .asyncAfter(deadline: .now() + delay)
        {
            /// Inform observers that this observable object will change w/o requiring this value to be published
            currentUser.hasVisitedHomeScreen = true
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
