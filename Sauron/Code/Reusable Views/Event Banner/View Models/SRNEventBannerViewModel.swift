//
//  SRNEventBannerViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/25/23.
//

import SwiftUI
import Combine
import OrderedCollections

/// A view model for the event banner view, displays events inside of a non-looping carousel for the user to view manually or automatically
class SRNEventBannerViewModel: GenericViewModel {
    // MARK: - Observed
    @ObservedObject var eventManager: BannerEventsManager = .shared
    
    // MARK: - Published
    @Published var currentPage: Int = 0
    @Published var pageBarViewModel: PageBarViewModel!
    
    /// Forces the view to display the page bar unconditionally (if the total page count > 0 of course)
    @Published var forceDisplayPageBar: Bool = false
    @Published var forceHidePageBar: Bool = false
    
    // MARK: - Subscriptions
    @Published var autoScrollTimer: Timer.TimerPublisher? = nil
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Tab View Auto-scrolling Functionality
    /// In seconds [s]
    static let defaultAutoScrollDuration: CGFloat = 30
    
    // MARK: - Styling
    // Colors
    let ctaSectionInnerBackgroundColor: Color = Colors.white.0,
        ctaSectionForegroundColor: Color = Colors.black.0,
        ctaSectionOuterGradient: LinearGradient = Colors.gradient_6,
        imageBackgroundColor: Color = Colors.white.0,
        shadowColor: Color = Colors.shadow_1.0
    
    // Fonts
    let ctaSectionFont: FontRepository = .body_M,
        ctaSectionFontWeight: Font.Weight = .semibold
    
    // MARK: - Convenience
    var currentEvent: BannerEventModel? {
        return eventManager
            .events[currentPage]
    }
    
    var totalPages: UInt {
        return UInt(eventManager
            .events
            .count)
    }
    
    var zeroIndexedPageRange: UInt {
        return totalPages - 1
    }
    
    var isOnLastPage: Bool {
        return currentPage == zeroIndexedPageRange
    }
    
    var bannerEvents: OrderedSet<BannerEventModel> {
        return eventManager.events
    }
    
    var shouldDisplayPageBar: Bool {
        return (totalPages > 1 && !forceHidePageBar) || forceDisplayPageBar
    }
    
    var hasMultipleEvents: Bool {
        return totalPages > 1
    }
    
    init() {
        self.pageBarViewModel = .init(totalPages: totalPages,
                                      currentPage: 0,
                                      shrinkInactiveBars: true)
        
        addSubscribers()
    }
    
    func addSubscribers() {
        /// Keep the current page in-sync for both models
        $currentPage
            .assign(to: &pageBarViewModel.$currentPage)
    }
    
    // MARK: - Auto-scrolling functionality
    func startAutoScroll(duration: CGFloat = SRNEventBannerViewModel.defaultAutoScrollDuration) {
        /// Only auto scroll when there's more than one event
        guard hasMultipleEvents
        else { return }
        
        autoScrollTimer = .init(interval: TimeInterval(duration),
                                runLoop: .main,
                                mode: .default)
        
        if let autoScrollTimer = autoScrollTimer {
            autoScrollTimer
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self = self
                    else { return }
                    
                    self.currentPage = self.isOnLastPage ? (0) : (self.currentPage + 1)
                }
                .store(in: &cancellables)
        }
    }
    
    func stopAutoScroll() {
        guard let autoScrollTimer = autoScrollTimer
        else { return }
        
        autoScrollTimer
            .connect()
            .cancel()
        
        self.autoScrollTimer = nil
    }
}
