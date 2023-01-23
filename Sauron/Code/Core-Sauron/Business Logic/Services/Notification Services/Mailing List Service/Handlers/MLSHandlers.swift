//
//  MLSHandlers.swift
//  Sauron
//
//  Created by Justin Cook on 1/22/23.
//

import Foundation

/// Subscribes the user to notifications about the release of the wallet service
class SRNWalletReleaseMLSHandler: MLSHandlerProtocol {
    // MARK: - Properties
    var supportedSubscriptionType: MLSSubscription.MLSSubscriptionType = .walletRelease
    var mailingListService: MailingListService = .shared
    
    func handle(_ subscription: MLSSubscription) {
        guard canHandle(subscription)
        else { return }
        
        mailingListService
            .unsubscribeFrom(subscription: subscription)
    }
}

/// Subscribes the user to a notification stream about the release of cloud alerts including any updates
class SRNCloudAlertsReleaseMLSHandler: MLSHandlerProtocol {
    // MARK: - Properties
    var supportedSubscriptionType: MLSSubscription.MLSSubscriptionType = .cloudAlertsRelease
    var mailingListService: MailingListService = .shared
}
