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
    
    // MARK: - Subscriptions
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Styling
    // Colors
    /// Shared
    let backgroundColor: Color = Color.clear,
        foregroundContainerColor: Color = Colors.neutral_100.0,
        titleForegroundColor: Color = Colors.permanent_white.0,
        titleIconForegroundColor: Color = Colors.permanent_white.0,
        sectionDividerColor: Color = Colors.neutral_200.0,
        /// Crypto News Section
        cryptoNewsSectionTitleGradient: LinearGradient = Colors.gradient_1,
        cryptoNewsImageColor: Color = Colors.black.0
    
    // Fonts
    let titleFont: FontRepository = .heading_2,
        titleFontWeight: Font.Weight = .semibold,
        // Crypto News
        cryptoNewsSectionTitleFont: FontRepository = .heading_4,
        cryptoNewsSectionTitleFontWeight: Font.Weight = .semibold
    
    // MARK: - Assets
    /// Crypto News Section
    let cryptoNewsSectionIcon: Image = Icons.getIconImage(named: .mic_circle_fill)
    
    // MARK: - Localized Text
    let cryptoNewsSectionTitle: String = LocalizedStrings.getLocalizedString(for: .HOME_SCREEN_SECTION_TITLE_CRYPTO_NEWS)
    
    // TODO: - Create Daily Message Service For dynamic user message prompts for returning users, and first time users
    var title: String {
        return LocalizedStrings.getLocalizedString(for: .HOME_SCREEN_GREETING_RETURNING_USER_1)
    }
    
    // MARK: - Convenience
    /// Detect whether or not the event banner has multiple events loaded up
    var isEventBannerSingular: Bool {
        return eventBannerCarouselViewModel.totalPages <= 1
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
