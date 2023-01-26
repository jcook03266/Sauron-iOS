//
//  BannerEventsManager.swift
//  Sauron
//
//  Created by Justin Cook on 1/24/23.
//

import Combine
import SwiftUI
import OrderedCollections

/// Manages the banner events shown on the home screen for users to interact with dynamically depending on their preferences, ftue status, or feature services
class BannerEventsManager: ObservableObject {
    // MARK: - Published
    @Published var events: OrderedSet<BannerEventModel> = []
    
    // MARK: - Singleton
    static let shared: BannerEventsManager = .init()
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let userManager: UserManager = inject()
    }
    var dependencies = Dependencies()
    
    private init() {
        populateEvents()
    }
    
    /// Populates the events priority queue with events from both local and remote sources depending on the current state of the application and progress of the user experience progression pipeline.
    /// Note: Locally created events have priority over remote
    private func populateEvents() {
        // Welcome Banner Event For New Users | Rank: 0
        events.append(LocalBannerEvents
            .ftueWelcomeMessage
            .createBannerEvent())
        
        events.append(LocalBannerEvents
            .ftueWelcomeMessage
            .createBannerEvent())
        
        events.append(LocalBannerEvents
            .ftueWelcomeMessage
            .createBannerEvent())
        
        events.append(LocalBannerEvents
            .ftueWelcomeMessage
            .createBannerEvent())
    }
    
    // MARK: - Banner Events Defined Within Client
    /// All supported local banners and their respective properties
    enum LocalBannerEvents: String, CaseIterable, Hashable {
        case ftueWelcomeMessage = "FTUE Welcome Message"
        
        // MARK: - Factory Methods
        func createBannerEvent() -> BannerEventModel {
            switch self {
            case .ftueWelcomeMessage:
            let actionLinkIsWebLinkTuple = self.getActionLink()
            
            let rank = 0,
                actionLink = actionLinkIsWebLinkTuple.0,
                isActionWebLink = actionLinkIsWebLinkTuple.1,
                eventCTA = self.getLocalizedEventCTA(),
                image = self.getBackgroundImage(),
                eventDescription = self.getEventDescription(),
                id = BannerEventModel.generateReusableID(rank: rank,
                                                         eventDescription: eventDescription,
                                                         isActionWebLink: isActionWebLink)
                
                return .init(id: id,
                             rank: rank,
                             eventCTA: eventCTA,
                             image: image,
                             actionLink: actionLink,
                             isActionWebLink: isActionWebLink)
            }
        }
        
        // MARK: - Properties
        func getLocalizedEventCTA() -> String {
            switch self {
            case .ftueWelcomeMessage:
                return LocalizedStrings.getLocalizedString(for: .BANNER_EVENT_FTUE_WELCOME_MESSAGE_CTA)
            }
        }
        
        func getBackgroundImage() -> Image {
            switch self {
            case .ftueWelcomeMessage:
                return Images.getImage(named: .event_banner_ftue_welcome_background)
            }
        }
        
        func getEventDescription() -> String {
            return self.rawValue
        }
        
        /// - Returns: Tuple (URL String, isActionWebLink Boolean)
        func getActionLink() -> (String, Bool) {
            switch self {
            case .ftueWelcomeMessage:
                return (DeepLinkManager
                    .EventBannerActions
                    .ftueWelcomeMessageDeepLink()?.asString ?? "",
                        false)
            }
        }
    }
}
