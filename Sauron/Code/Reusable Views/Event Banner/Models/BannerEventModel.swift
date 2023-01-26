//
//  BannerEventModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/24/23.
//

import SwiftUI
import Combine

/// Stores data related to each event displayed inside of the banner view
class BannerEventModel: Codable, Equatable, Hashable, GenericViewModel {
    // MARK: - Properties
    // Public
    /// For tracking purposes, the id is a static entity used to identify the type of banner event that's currently being displayed, and will allow for analytics to understand which events had the most effective reach
    let id: String
    /// The order in which this event will be presented when batched with other events
    let rank: Int
    /// Optional URL that can be used to load a remote image asynchronously
    let imageURL: String?
    /// A deeplink safe URL specific to this application that the user can click on and navigate to the desired target with whatever parameters and tags enumerated in the URL
    let actionLink: String
    /// Describe the type of link the action link refers to, if it's a web link then open it in a web browser, if not then it's a deeplink and should be parsed as such
    let isActionWebLink: Bool
    
    // Private
    /// Optional description of this event, effectively the title (Max Length: 50 Characters) [Use the getter to obtain this value]
    private let eventCTA: String?

    // MARK: - Published / Local Properties
    /// States whether or not this banner event was fetched from a remote source or created locally on the client side, decoded JSONs are automatically treated as remote sources with the aid of this default value. Local events have priority over remote events in the priority queue for the events banner,
    /// ex.) a local event (LE) with a rank of 1 is placed before a remote event (RE) with the same rank [LE -> RE]
    var isLocalEvent: Bool = false
    /// The image to be presented for the event, if this is a locally created event this is passed in via the provided constructor, if remote then the image is loaded asynchronously from the provided URL parsed from the JSON
    @Published var image: Image? = nil
    /// Used to determine the current state of the async loading of the specified image asset
    @Published var isLoading: Bool = true
    
    // MARK: - View Animation Properties
    @Published var parallaxAnimationOffset: CGSize = .zero
    
    // MARK: - Constants
    static let maxEventCTACharacterLength: Int = 50
    
    // MARK: - Convenience
    var shouldDisplayCTA: Bool {
        return eventCTA != nil
    }
    
    // MARK: - Locally Acquired Events Constructor
    /// For locally created events
    init(id: String,
         rank: Int,
         eventCTA: String?,
         image: Image,
         actionLink: String,
         isActionWebLink: Bool)
    {
        self.id = id
        self.rank = rank
        self.eventCTA = eventCTA
        self.imageURL = nil
        self.actionLink = actionLink
        self.isActionWebLink = isActionWebLink
        
        // Image provided, inform potential subscribers with the current value
        self.image = image
        self.isLoading = false
        self.isLocalEvent = true
    }
    
    // MARK: - Remotely Acquired Events Constructor
    /// For remotely fetched events or local events that depend on URL resources
    init(id: String,
         rank: Int,
         eventCTA: String?,
         imageURL: String,
         actionLink: String,
         isActionWebLink: Bool)
    {
        self.id = id
        self.rank = rank
        self.eventCTA = eventCTA
        self.imageURL = imageURL
        self.actionLink = actionLink
        self.isActionWebLink = isActionWebLink
        self.isLocalEvent = false
    }
    
    // MARK: - Business Logic
    func performAction() {
        guard let actionLinkURL = actionLink.asURL
        else { return }
        HapticFeedbackDispatcher.eventBannerTapped()
        
        let deepLinkHandler = DeepLinkManager.shared
        if isActionWebLink {
            deepLinkHandler.open(webLink: actionLinkURL)
        }
        else {
            deepLinkHandler.manage(actionLinkURL)
        }
    }
    
    // MARK: - Mutation / Getter Methods
    /// Use this to generate a reusable ID for each local event, it permits the identification of target banner events in the analytics system
    static func generateReusableID(rank: Int,
                                   eventDescription: String,
                                   isActionWebLink: Bool) -> String
    {
        /// Formatted for snakecase
        let formattedID = "BANNER_EVENT_\(eventDescription.lowercased().getURLSafeString())_rank_#\(rank)_cta_isWebLink\(isActionWebLink.description)"
        
        return formattedID
    }
    
    /// - Returns: An optional string with a maximum length of 50 characters before being truncated
    func getEventCTA() -> String? {
        guard let cta = eventCTA
        else { return nil }
        
        if cta.count > BannerEventModel.maxEventCTACharacterLength {
            return cta.prefix(BannerEventModel.maxEventCTACharacterLength) + ("...")
        }
        else {
            return cta
        }
    }
    
    /// Downloads the required image resource from the imageURL (if any)
    func downloadImage() {
        let bannerEventImageFetcher: BannerEventImageFetcher = .init(bannerEvent: self)
        
        bannerEventImageFetcher.getImage { [weak self] fetchedImage in
            guard let self = self else { return }
            
            self.image = Image(uiImage: fetchedImage)
            self.isLoading = false
        }
    }
    
    enum CodingKeys: String, CodingKey, Codable {
        case id, rank
        case actionLink = "action_link"
        case eventCTA = "event_cta"
        case imageURL = "image_url"
        case isActionWebLink = "is_action_web_link"
    }
    
    // MARK: - Protocol Conformance
    static func == (lhs: BannerEventModel, rhs: BannerEventModel) -> Bool {
        let condition = lhs.id == rhs.id
        && lhs.rank == rhs.rank
        && lhs.eventCTA == rhs.eventCTA
        && lhs.imageURL == rhs.imageURL
        && lhs.actionLink == rhs.actionLink
        && lhs.isActionWebLink == rhs.isActionWebLink
        
        return condition
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(rank)
        hasher.combine(eventCTA)
        hasher.combine(imageURL)
        hasher.combine(actionLink)
        hasher.combine(isActionWebLink)
    }
}
