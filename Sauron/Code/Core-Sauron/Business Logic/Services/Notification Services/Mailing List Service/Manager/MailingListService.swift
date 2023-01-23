//
//  MailingListService.swift
//  Sauron
//
//  Created by Justin Cook on 1/22/23.
//

import Foundation

/// A service that subscribes the current user to their desired mailing list for an in-development feature, or something else down the line such as a newswire
class MailingListService: MLSProtocol {
    // MARK: - Properties
    /// A collection of the user's active subscription streams, this is loaded up in order to toggle the UI elements responsible for interfacing with the subscription service, the presence of elements
    var activeUserSubscriptions: Set<MLSSubscription> = []
    var handlers: [MLSHandlerProtocol] {
        return [
            SRNWalletReleaseMLSHandler(),
            SRNCloudAlertsReleaseMLSHandler()
        ]
    }
    
    /// Encapsulates a factory of all possible mailing list subscription types
    struct MailingListSubscriptions {
        func buildWalletReleaseMLSubscription(subscribe: Bool) -> MLSSubscription {
            return .init(type: .walletRelease,
                         subscribed: subscribe)
        }
        
        func buildCloudAlertsReleaseMLSubscription(subscribe: Bool) -> MLSSubscription {
            return .init(type: .cloudAlertsRelease,
                         subscribed: subscribe)
        }
    }
    let subscriptionFactory = MailingListSubscriptions()
    
    // MARK: - Singleton
    static let shared: MailingListService = .init()
    
    private init() {
        fetchAllSubscriptions()
    }
    
    func manage(subscription: MLSSubscription) {
        guard let handler = handlers.first(where: {
            $0.canHandle(subscription)
        })
        else { return }
        
        handler.handle(subscription)
    }
    
    func isUserSubscribedTo(subscriptionType: MLSSubscription.MLSSubscriptionType) -> Bool {
        
        return activeUserSubscriptions.contains {
            $0.type == subscriptionType
        }
    }
    
    // MARK: - Endpoint interfacing with backend service
    private func fetchAllSubscriptions() {
    }
    
    @discardableResult
    /// Gets the specific subscription type specified for this user (if it exists)
    private func fetchSubscription(subscription: MLSSubscription.MLSSubscriptionType) -> Bool {
        return true
    }
    
    @discardableResult
    /// Adds this subscription to the backend persistent store for later use when a notification is available for the mailing list described
    private func postSubscription(subscription: MLSSubscription) -> Bool {
        return true
    }
    
    @discardableResult
    /// Removes the subscription from the database, effectively unsubscribing the user from the PNS serverless function that crawls user subscriptions
    private func deleteSubscription(subscription: MLSSubscription.MLSSubscriptionType) -> Bool {
        return true
    }
    
    // MARK: - Data Mutation
    @discardableResult
    /// - Returns: A boolean describing the success of this operation
    func subscribeTo(subscription: MLSSubscription) -> Bool {
        guard !isUserSubscribedTo(subscriptionType: subscription.type),
              postSubscription(subscription: subscription)
        else { return false }
        
        activeUserSubscriptions.insert(subscription)
        
        return true
    }
    
    @discardableResult
    func unsubscribeFrom(subscription: MLSSubscription) -> Bool {
        guard isUserSubscribedTo(subscriptionType: subscription.type),
              deleteSubscription(subscription: subscription.type)
        else { return false }
        
        /// If the deletion from the backend is successful then remove it from the client side
        activeUserSubscriptions.remove(subscription)
        
        return true
    }
    
    /// Only use this when a user requests to delete their information
    func unsubscribeFromAll() {
        for subscription in activeUserSubscriptions {
            unsubscribeFrom(subscription: subscription)
        }
    }
}
