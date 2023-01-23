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
    
    func handle(_ subscription: MLSSubscription) {
        guard canHandle(subscription)
        else { return }
        
        switch subscription.subscribed {
        case true:
            mailingListService
                .subscribeTo(subscription: subscription)
        case false:
            mailingListService
                .unsubscribeFrom(subscription: subscription)
        }
    }
}
