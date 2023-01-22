//
//  TabbarSessionModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/21/23.
//

import SwiftUI

/// An object that records the amount of time a user was in a specific tab, can be used for custom analytics
class TabbarContextSession: Identifiable, Hashable {
    // MARK: - Properties
    typealias tabs = MainRoutes
    let id: UUID = .init()
    
    // MARK: - Tabbar tab tracking
    let tab: tabs
    
    // MARK: - Life Cycle information
    let sessionStart: Date = .now
    var sessionEnd: Date = .now
    
    // MARK: - Conformance
    static func == (lhs: TabbarContextSession,
                    rhs: TabbarContextSession) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(tab: tabs) {
        self.tab = tab
    }
    
    /// - Returns: The total duration the user was in the current tab context for [in  seconds]
    func getTotalDuration() -> Double {
        return sessionEnd.distance(to: sessionStart)
    }
    
    /// The user has switched out of the current tab and so the duration has to be recorded
    func endSession() {
        sessionEnd = .now
    }
}
