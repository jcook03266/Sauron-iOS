//
//  MLSSubscription.swift
//  Sauron
//
//  Created by Justin Cook on 1/22/23.
//

import Foundation

/// A transportable package describing a subscription of a specific type that can be posted, and requested from a remote server
struct MLSSubscription: Hashable {
    // MARK: - Properties
    /// Used by the responsibility chain to determine the correct handler
    let type: MLSSubscriptionType
    /// The time when this subscription was created, useful for keeping track of the campaign's success overtime
    var timeOfCreation: Date
    /// Informs the handler whether or not to subscribe or unsubscribe the user from the target mailing list
    var subscribed: Bool
    
    init(type: MLSSubscriptionType,
         timeOfCreation: Date = .now,
         subscribed: Bool)
    {
        self.type = type
        self.timeOfCreation = timeOfCreation
        self.subscribed = subscribed
    }
    
    enum MLSSubscriptionType {
        case walletRelease,
        cloudAlertsRelease
    }
}
