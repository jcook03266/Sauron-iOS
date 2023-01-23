//
//  MLSProtocol.swift
//  Sauron
//
//  Created by Justin Cook on 1/22/23.
//

import Foundation

protocol MLSProtocol {
    // MARK: - Properties
    var activeUserSubscriptions: Set<MLSSubscription> { get set }
    var handlers: [MLSHandlerProtocol] { get }
    
    // MARK: - Singleton
    static var shared: MailingListService { get }
    
    // MARK: - Factory
    var subscriptionFactory: MailingListService.MailingListSubscriptions { get }
    
    // MARK: - Business Logic
    func manage(subscription: MLSSubscription)
    
    func isUserSubscribedTo(subscriptionType: MLSSubscription.MLSSubscriptionType) -> Bool
    
    func subscribeTo(subscription: MLSSubscription) -> Bool
    
    func unsubscribeFrom(subscription: MLSSubscription) -> Bool
    
    func unsubscribeFromAll()
}
