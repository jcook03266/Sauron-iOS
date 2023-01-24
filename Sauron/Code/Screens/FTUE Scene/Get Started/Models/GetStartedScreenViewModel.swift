//
//  GetStartedScreenViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI

class GetStartedScreenViewModel: CoordinatedGenericViewModel {
    typealias coordinator = OnboardingCoordinator
    
    // MARK: - Observed
    @ObservedObject var coordinator: OnboardingCoordinator
    
    // MARK: - Third-party links
    private var learnMoreLink: URL? {
        let linkCopy: String = "https://www.coinbase.com/learn/crypto-basics"
        
        return linkCopy.asURL
    }
    
    // MARK: - Data Store Dependencies
    struct DataStores: InjectableStores {
        let portfolioManager: PortfolioManager = inject()
    }
    let dataStores = DataStores()
    
    // MARK: - Assets
    let lottieAnimation: LottieAnimationRepository = .radial_grid,
        appIcon: Image = Icons.getIconImage(named: .app_icon_transparent)
    
    // MARK: - Styling
    // Colors / Gradients
    let titleGradient: LinearGradient = Colors.gradient_1,
        curateButtonBackgroundGradient: LinearGradient = Colors.gradient_1,
        curateButtonForegroundColor: Color = Colors.permanent_white.0,
        autoGenButtonBackgroundColor: Color = Colors.permanent_black.0,
        autoGenButtonForegroundColor: Color = Colors.permanent_white.0,
        learnMoreButtonGradient: LinearGradient = Colors.gradient_1,
        appNameSignatureGradient: LinearGradient = Colors.gradient_1,
        tosPPPortalForegroundColor: Color = Colors.neutral_500.0,
        forkPromptBackgroundColor: Color = Colors.secondary_2.0,
        forkPromptForegroundColor: Color = Colors.permanent_white.0,
        verticalDividerDotColor: Color = Colors.secondary_2.0,
        verticalDividerGradient: LinearGradient = Colors.gradient_1,
        backgroundColor: Color = Colors.white.0,
        roundedTopBarBackgroundGradient: LinearGradient = Colors.gradient_1,
        appIconShadowColor: Color = Colors.shadow_1.0
    
    // Fonts
    let titleFont: Font = Fonts.getFont(named: .heading_1,
                                        with: .semibold,
                                        size: 40),
        titleFontName: FontRepository = .heading_1,
        ctaButtonFonts: FontRepository = .body_M_Bold,
        forkPromptFont: FontRepository = .body_S_Bold,
        learnMoreButtonFont: FontRepository = .body_M_Bold,
        appNameSignatureFont: FontRepository = .heading_0,
        appNameSignatureFontWeight: Font.Weight = .semibold,
        tosPPPortalFont: FontRepository = .body_S
    
    // MARK: - Localized Text
    let appNameSignature: String = LocalizedStrings.getLocalizedString(for: .APP_NAME).localizedUppercase,
        getStartedPrompt = LocalizedStrings.getLocalizedStringKey(for: .GET_STARTED_SCREEN_GET_STARTED_PROMPT),
        curatePortfolioButtonText = LocalizedStrings.getLocalizedStringKey(for: .GET_STARTED_SCREEN_CURATE_BUTTON),
        autoGenPortfolioButtonText = LocalizedStrings.getLocalizedStringKey(for: .GET_STARTED_SCREEN_AUTO_GEN_BUTTON),
        learnMoreButtonText = LocalizedStrings.getLocalizedStringKey(for: .GET_STARTED_SCREEN_LEARN_MORE_BUTTON),
        termsOfServicePortalText = LocalizedStrings.getLocalizedStringKey(for: .TOS),
        tosPPPortalDivider: String = "|",
        privacyPolicyPortalText = LocalizedStrings.getLocalizedStringKey(for: .PP),
        orForkPrompt = LocalizedStrings.getLocalizedString(for: .OR_FORK_PROMPT).localizedUppercase
    
    // MARK: - Actions
    var curatePortfolioAction: (() -> Void) {
        return { [weak self] in
            HapticFeedbackDispatcher.interstitialCTAButtonPress()
            guard let self = self else { return }
            
            self.coordinator.pushView(with: .portfolioCuration)
        }
    }
    
    var autoGeneratePortfolioAction: (() -> Void) {
        return { [weak self] in
            HapticFeedbackDispatcher.interstitialCTAButtonPress()
            guard let self = self else { return }
            
            self.dataStores.portfolioManager.randomize()
            
            /// Show the selected coins to the user automatically
            self.coordinator.router.filterPortfolioCoinsOnly = true
            self.coordinator.pushView(with: .portfolioCuration)
        }
    }
    var learnMoreAboutCryptoAction: (() -> Void) {
        return { [weak self] in
            HapticFeedbackDispatcher.interstitialCTAButtonPress()
            guard let self = self else { return }
            
            // Present a safari view controller with the given link
            if let learnMoreLink = self.learnMoreLink{
                self.coordinator.router.webURL = learnMoreLink
                self.coordinator.pushView(with: .web)
            }
        }
    }
    var termsOfServiceAction: (() -> Void) {
        return { [weak self] in
            HapticFeedbackDispatcher.genericButtonPress()
            guard let self = self else { return }
            
            //self.coordinator.pushView(with: .signUp)
        }
    }
    var privacyPolicyAction: (() -> Void) {
        return { [weak self] in
            HapticFeedbackDispatcher.genericButtonPress()
            guard let self = self else { return }
            
            //self.coordinator.pushView(with: .signUp)
        }
    }
    
    init(coordinator: OnboardingCoordinator) {
        self.coordinator = coordinator
    }
}
