//
//  MLSHandlerProtocol.swift
//  Sauron
//
//  Created by Justin Cook on 1/22/23.
//

import Foundation

/// A handler that's responsible for subscribing the user to the correct mailing list
protocol MLSHandlerProtocol {
    var supportedSubscriptionType: MLSSubscription.MLSSubscriptionType { get }
    var mailingListService: MailingListService { get }
    
    func canHandle(_ subscription: MLSSubscription) -> Bool
    func handle(_ subscription: MLSSubscription)
}

extension MLSHandlerProtocol {
    func canHandle(_ subscription: MLSSubscription) -> Bool {
        return subscription.type == supportedSubscriptionType
    }
    
    /// Handles subscription service requests by subscribing or unsubscribing the user conditionally
    func handle(_ subscriptionRequest: MLSSubscription) {
        guard canHandle(subscriptionRequest)
        else { return }
        
        /// If the subscription request has a subscribed flag then subscribe the user to it, if not then unsubscribe
        switch subscriptionRequest.subscribed {
        case true:
            mailingListService
                .subscribeTo(subscription: subscriptionRequest)
        case false:
            mailingListService
                .unsubscribeFrom(subscription: subscriptionRequest)
        }
    }
}
