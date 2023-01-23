//
//  TabbarSessionTrackingService.swift
//  Sauron
//
//  Created by Justin Cook on 1/21/23.
//

import SwiftUI

/// A tracking service specific to the tabbar that keeps track of tab specific sessions, how long the user spends in each
/// tab the most frequently and least frequently used tabs
/// and the tabs that are never used are all observable with the help of this object
/// Note: This tracker has a direct dependency on the tabbar view model and cannot be injected into any other instance
class TabbarContextSessionTrackingService: ObservableObject {
    // MARK: - Properties
    typealias tabs = MainRoutes
    
    // MARK: - Published
    @Published var currentTabbarContext: TabbarContextSession
    @Published var pastTabbarContexts: Set<TabbarContextSession> = []
    
    /// Controlled by the tabbar view model
    @Published var currentTab: tabs
    @Published var lastTab: tabs
    
    // MARK: - Convenience
    /// The amount of the times the user has switched tabs
    var totalContextSwitches: Int {
        return pastTabbarContexts.count
    }
    
    init(currentTab: tabs) {
        self.currentTab = currentTab
        self.lastTab = currentTab
        self.currentTabbarContext = .init(tab: currentTab)
    }
    
    // MARK: - Debugging
    /// Logs the latest updates from this tracker in the console
    func logUpdates() {
        // Header
        print("\n")
        print("+------------------------Debugging--------------------------------------+")
        print("|###### Tabbar Context Session Tracking [10] Point Inspection List ######|")
        print("+-----------------------------------------------------------------------+")
        print("\n")
        
        // Life Cycle Duration
        print("+==[Life Cycle Duration Statistics]==+")
        print("1.) [Total] 🔁 Context Switches [Type: Int]: \(totalContextSwitches)")
        print("2.) [Total] Context Session Duration [Unit: Seconds [s]] | \(getTotalContextSessionDuration()) | Time Stamp Format: \(IntToTimeConversionHelper.convertIntToTimeStamp(number: UInt(getTotalContextSessionDuration()), with: .long))")
        print("\n")
        
        print("3.) [Average] Context Session Duration [Unit: Seconds [s]] | \(getAverageContextSessionDuration()) | Time Stamp Format: \(IntToTimeConversionHelper.convertIntToTimeStamp(number: UInt(getAverageContextSessionDuration()), with: .long))")
        
        print("4.) [Longest] Context Session Duration [Unit: Seconds [s]] | \(getLongestContextSession().getTotalDuration()) | Time Stamp Format: \(IntToTimeConversionHelper.convertIntToTimeStamp(number: UInt(getLongestContextSession().getTotalDuration()), with: .long))")
        print("🗂 Tab [Type: Sauron.MainRoutes] | \(getLongestContextSession().tab)")
        
        print("5.) [Shortest] Context Session Duration [Unit: Seconds [s]] | \(getShortestContextSession().getTotalDuration()) | | Time Stamp Format: \(IntToTimeConversionHelper.convertIntToTimeStamp(number: UInt(getShortestContextSession().getTotalDuration()), with: .long))")
        print("🗂 Tab [Type: Sauron.MainRoutes] | \(getShortestContextSession().tab)")
        print("\n")
        
        // Frequency
        print("+==[Tab Context Frequency Statistics]==+")
        print("6.) 🔥 Most used tab [Type: Sauron.MainRoutes] | \(getMostFrequentTab())")
        print("7.) ❄️ Least used tab [Type: Sauron.MainRoutes] | \(getLeastFrequentTab())")
        print("8.) ∅/🗂 Tabs never used [Type: Sauron.MainRoutes] | \(getNeverUsedTabs())")
        print("\n")
        
        // First Context
        print("+==[First Context <-> Last Context]==+ [Detailed Description]")
        print("9.) First Context Session <-----------------------------------------------")
        print("🏷 ID [Type: UUID]: \(getFirstContextSession().id)")
        print("🎯 Target Tab [Type: Sauron.MainRoutes]: \(getFirstContextSession().tab)")
        print("⏳ Session Start [Unit: Seconds [s]]: \(getFirstContextSession().sessionStart)")
        print("⌛️ Session End [Unit: Seconds [s]]: \(getFirstContextSession().sessionEnd)")
        print("🕰 Session Lifespan [Unit: Seconds [s]]: \(getFirstContextSession().getTotalDuration()) | Time Stamp Format: \(IntToTimeConversionHelper.convertIntToTimeStamp(number: UInt(getFirstContextSession().getTotalDuration()), with: .long))")
        print("+-----------------------------------------------------------------------+")
        print("\n")
        
        // Last Context
        print("10.) Last Context Session ----------------------------------------------->")
        print("🏷 ID [Type: UUID]: \(getLastContextSession().id)")
        print("🎯 Target Tab [Type: Sauron.MainRoutes]: \(getLastContextSession().tab)")
        print("⏳ Session Start [Unit: Seconds [s]]: \(getLastContextSession().sessionStart)")
        print("⌛️ Session End [Unit: Seconds [s]]: \(getLastContextSession().sessionEnd)")
        print("🕰 Session Lifespan [Unit: Seconds [s]]: \(getLastContextSession().getTotalDuration()) | Time Stamp Format: \(IntToTimeConversionHelper.convertIntToTimeStamp(number: UInt(getLastContextSession().getTotalDuration()), with: .long))")
        print("--------------------------------End------------------------------------")
    }

    // MARK: - Session Tracking
    func retireCurrentContextSession() {
        currentTabbarContext.endSession()
        pastTabbarContexts.update(with: currentTabbarContext)
    }
    
    func createNewContextSession(with tab: tabs) {
        currentTabbarContext = .init(tab: tab)
        
        logUpdates()
    }
    
    func getLastContextSession() -> TabbarContextSession {
        return pastTabbarContexts.min { value1, value2 in
            return value1.sessionEnd > value2.sessionEnd
        } ?? currentTabbarContext
    }
    
    func getFirstContextSession() -> TabbarContextSession {
        return pastTabbarContexts.min { value1, value2 in
            return value1.sessionStart < value2.sessionStart
        } ?? currentTabbarContext
    }
    
    func getLongestContextSession() -> TabbarContextSession {
        return pastTabbarContexts.min { value1, value2 in
            return value1.getTotalDuration() > value2.getTotalDuration()
        } ?? currentTabbarContext
    }
    
    func getShortestContextSession() -> TabbarContextSession {
        return pastTabbarContexts.min { value1, value2 in
            return value1.getTotalDuration() < value2.getTotalDuration()
        } ?? currentTabbarContext
    }
    
    func getTotalContextSessionDuration() -> Double {
        return pastTabbarContexts.reduce(0) { partialResult, contextSession in
            partialResult + contextSession.getTotalDuration()
        }
    }
    
    /// The average time the user spent across all tabs
    func getAverageContextSessionDuration() -> Double {
        let totalDuration = getTotalContextSessionDuration()
        return totalDuration / Double(totalContextSwitches)
    }
    
    /// - Returns: The tab the user has frequented the most across all sessions
    func getMostFrequentTab() -> TabbarContextSession.tabs {
        let allContextsTupleMap = pastTabbarContexts.map { ($0.tab, 1) },
            totalSwitches = Dictionary(allContextsTupleMap, uniquingKeysWith: +)
        ///  Note: Reduces all duplicate key pair tuples into a single key pair by incrementing their values by one with the + operator
        
        return totalSwitches.max { value1 , value2 in
            value1.value < value2.value
        }?.key ?? currentTab
    }
    
    /// - Returns: The tab the user HAS used the least across all sessions
    func getLeastFrequentTab() -> TabbarContextSession.tabs {
        let allContextsTupleMap = pastTabbarContexts.map { ($0.tab, 1) },
            totalSwitches = Dictionary(allContextsTupleMap, uniquingKeysWith: +)
        
        return totalSwitches.min { value1 , value2 in
            value1.value < value2.value
        }?.key ?? currentTab
    }
    
    /// - Returns: A collection of the tabs that were never used by the user across all sessions
    func getNeverUsedTabs() -> [tabs] {
        let allContextsTupleMap = pastTabbarContexts.map { ($0.tab, 1) },
            totalSwitches = Dictionary(allContextsTupleMap, uniquingKeysWith: +)
        
        var neverUsedTabs: [tabs] = []
        
        // If a specific tabbar tab is not contained in the switch dictionary then the tab was never used
        for tab in tabs.allCases {
            if !totalSwitches.keys.contains(tab) {
                neverUsedTabs.append(tab)
            }
        }
        
        return neverUsedTabs
    }
}
