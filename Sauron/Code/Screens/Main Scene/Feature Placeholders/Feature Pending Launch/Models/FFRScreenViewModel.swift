//
//  FFRScreenViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/23/23.
//

import SwiftUI

class FFRScreenViewModel<HostCoordinator: Coordinator>: GenericViewModel {
    typealias coordinator = HostCoordinator
    
    // MARK: - Observed
    @ObservedObject var coordinator: HostCoordinator
    @ObservedObject var radioButtonViewModel: RadioButtonViewModel = .init()
    
    // MARK: - Published
    @Published var isUserSubscribed: Bool = false
    
    // MARK: - Mailing List Subscription Service
    var targetMailingListSubscriptionType: MLSSubscription.MLSSubscriptionType
    
    struct Dependencies: InjectableServices {
        let mailingListService: MLSProtocol = inject()
    }
    let dependencies = Dependencies()
    
    // MARK: - Convenience
    var isUserSubscribedToTargetMailingList: Bool {
        return dependencies.mailingListService
            .isUserSubscribedTo(subscriptionType: targetMailingListSubscriptionType)
    }
    
    // MARK: - Styling
    // Colors
    let backgroundColor: Color = Colors.white.0,
        titleForegroundColor: Color = Colors.black.0,
        subscriptionPromptForegroundGradient: LinearGradient = Colors.gradient_1,
        subscriptionSubtitleForegroundColor: Color = Colors.neutral_500.0,
        appNameSignatureGradient: LinearGradient = Colors.gradient_1
    
    // Fonts
    let titleFont: FontRepository = .heading_3,
        titleFontWeight: Font.Weight = .semibold,
        subscriptionPromptFont: FontRepository = .body_L,
        subscriptionPromptFontWeight: Font.Weight = .semibold,
        subscriptionSubtitleFont: FontRepository = .body_M,
        appNameSignatureFont: FontRepository = .heading_2,
        appNameSignatureFontWeight: Font.Weight = .semibold
    
    // MARK: - Assets
    let coinClusterBackgroundGraphic: Image = Images.getImage(named: .coin_cluster_background_graphic),
        twoToneDotMatrixBackgroundGraphic: Image = Images.getImage(named: .two_tone_dot_matrix_background_graphic)
    
    // MARK: - Localized Text
    let title: String = LocalizedStrings.getLocalizedString(for: .FUTURE_FEATURE_RELEASE_SCREEN_COMING_SOON),
        appNameSignature: String = LocalizedStrings.getLocalizedString(for: .APP_NAME).localizedUppercase
    
    var subscriptionPrompt: String {
        return isUserSubscribedToTargetMailingList ?
        LocalizedStrings.getLocalizedString(for: .FUTURE_FEATURE_RELEASE_SCREEN_MAILING_LIST_SUBSCRIPTION_PROMPT_SUBSCRIBED)
        :
        LocalizedStrings.getLocalizedString(for: .FUTURE_FEATURE_RELEASE_SCREEN_MAILING_LIST_SUBSCRIPTION_PROMPT_NOT_SUBSCRIBED)
    }
    
    var subscriptionPromptSubtitle: String {
        return isUserSubscribedToTargetMailingList ?
        LocalizedStrings.getLocalizedString(for: .FUTURE_FEATURE_RELEASE_SCREEN_MAILING_LIST_SUBSCRIPTION_PROMPT_SUBSCRIBED_SUBTITLE)
        :
        LocalizedStrings.getLocalizedString(for: .FUTURE_FEATURE_RELEASE_SCREEN_MAILING_LIST_SUBSCRIPTION_PROMPT_NOT_SUBSCRIBED_SUBTITLE)
    }
    
    // MARK: - Actions
    @discardableResult
    func radioButtonAction() -> Bool {
        let subscriptionUpdateRequest: MLSSubscription = .init(type: self.targetMailingListSubscriptionType,
                                                               subscribed: !self.isUserSubscribed)
        
        self.dependencies
            .mailingListService
            .manage(subscription: subscriptionUpdateRequest)
        
        // Determine if the user is still subscribed or not
        self.isUserSubscribed = self.isUserSubscribedToTargetMailingList
        
        return self.isUserSubscribed
    }
    
    init(coordinator: HostCoordinator,
         targetMailingListSubscriptionType: MLSSubscription.MLSSubscriptionType)
    {
        self.coordinator = coordinator
        self.targetMailingListSubscriptionType =  targetMailingListSubscriptionType
        self.isUserSubscribed = isUserSubscribedToTargetMailingList
        self.radioButtonViewModel = .init(onSelectAction: self.radioButtonAction(),
                                          isSelected: self.isUserSubscribed)
    }
}
