//
//  SRNTabbarViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/21/23.
//

import SwiftUI
import Combine

/// View model for the SRN Tabbar that navigates the user between the different scenes in the main part of the application
class SRNTabbarViewModel: GenericViewModel {
    // MARK: - Properties
    typealias tabs = MainRoutes
    
    // MARK: - Observed
    @ObservedObject var coordinator: MainCoordinator
    @ObservedObject var contextSessionService: TabbarContextSessionTrackingService
    @ObservedObject var router: MainRouter
    
    // MARK: - Published
    @Published var currentTab: tabs = SRNTabbarViewModel.defaultTab
    @Published var lastTab: tabs = SRNTabbarViewModel.defaultTab
    @Published var iconTapped: Bool = false
    @Published var toggleTabbarViewTransitionAnimation: Bool = false
    
    // MARK: - Static Instance Variables
    static let defaultTab: tabs = .home
    
    // MARK: - Subscriptions
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Assets
    // Images
    private let homeIcon: Image = Icons.getIconImage(named: .bitcoinsign_circle_fill),
                walletIcon: Image = Icons.getIconImage(named: .wallet),
                settingIcon: Image = Icons.getIconImage(named: .gear),
                alertsIcon: Image = Icons.getIconImage(named: .cloud_sun_bolt_fill),
                noIcon: Image = Icons.getIconImage(named: .questionmark_square_dashed)
    
    var currentIcon: Image {
        return getIcon(for: currentTab)
    }
    
    // MARK: - Localized Text
    let homeTabLabel: String = LocalizedStrings.getLocalizedString(for: .TABBAR_BUTTON_HOME),
        walletTabLabel: String = LocalizedStrings.getLocalizedString(for: .TABBAR_BUTTON_WALLET),
        settingsTabLabel: String = LocalizedStrings.getLocalizedString(for: .TABBAR_BUTTON_SETTINGS),
        alertsTabLabel: String = LocalizedStrings.getLocalizedString(for: .TABBAR_BUTTON_ALERTS)
    
    /// This not really necessary but allows for dynamic text changes when the current tab changes
    private let absenceOfValue: String = LocalizedStrings.getLocalizedString(for: .ABSENCE_OF_VALUE)
    
    var currentTabLabel: String {
        switch currentTab {
        case .home:
            return homeTabLabel
        case .wallet:
            return walletTabLabel
        case .settings:
            return settingsTabLabel
        case .alerts:
            return alertsTabLabel
        case .authScreen:
            return absenceOfValue
        }
    }
    
    // MARK: - Styling
    // Fonts
    let tabbarButtonFont: FontRepository = .body_XS,
        tabbarButtonFontActiveWeight: Font.Weight = .semibold,
        tabbarButtonFontInactiveWeigth: Font.Weight = .regular
    
    // Colors
    let containerBackgroundColor: Color = Colors.neutral_100.0,
        tabbarActiveButtonUnderlineGradient: LinearGradient = Colors.gradient_1,
        tabbarIconBackgroundGradient: LinearGradient = Colors.gradient_1,
        tabbarIconForegroundColor: Color = Colors.permanent_white.0,
        tabButtonActiveForegroundColor: Color = Colors.primary_2.0,
        tabButtonInactiveForegroundColor: Color = Colors.black.0,
        shadowColor: Color = Colors.shadow_1.0
    
    // MARK: - Actions
    var tabbarButtonPressed: (() -> Void) {
        HapticFeedbackDispatcher.tabbarButtonPress
    }
    
    var iconButtonPressed: (() -> Void) {
        return { [weak self] in
            guard let self = self
            else { return }
            HapticFeedbackDispatcher.genericButtonPress()
            
            self.iconTapped.toggle()
        }
    }
    
    // MARK: - Convenience
    var didMove: Bool {
        return contextSessionService.totalContextSwitches > 0
    }
    
    var icon3DRotationAngle: CGFloat {
        return iconTapped ? 360 : 0
    }
    
    // MARK: - Models
    var tabModels: [SRNTabbarTabViewModel] {
        return [
            .init(parent: self,
                  tab: .home),
            .init(parent: self,
                  tab: .wallet),
            .init(parent: self,
                  tab: .settings),
            .init(parent: self,
                  tab: .alerts),
        ]
    }
    
    init(coordinator: MainCoordinator,
         router: MainRouter,
         currentTab: tabs = SRNTabbarViewModel.defaultTab)
    {
        self.coordinator = coordinator
        self.router = router
        self.currentTab = currentTab
        self.contextSessionService = .init(currentTab: currentTab)
        
        addSubscribers()
    }
    
    func addSubscribers() {
        // Keep the session tracking service and this view model in sync when this view model is interacted with my the user
        $currentTab
            .assign(to: &contextSessionService.$currentTab)
        
        $lastTab
            .assign(to: &contextSessionService.$lastTab)
        
        // Listen for updates from the router and respond accordingly
        router
            .$currentTab
            .sink { [weak self] in
                guard let self = self
                else { return }
                
                self.navigateTo(tab: $0)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Navigation Logic
    /// Navigates the user to the specified tab (if appropriate)
    /// and executes an optional closure when that navigation operation is complete
    func navigateTo(tab: tabs,
                    onNavigate: @escaping (() -> Void) = {}) {
        guard tab != .authScreen,
              currentTab != tab
        else { return }
        
        toggleTabbarViewTransitionAnimation.toggle()
        
        // The user has switched contexts so the last session must be retired
        contextSessionService.retireCurrentContextSession()
        
        // Update publisher with values related to this navigation
        lastTab = currentTab
        currentTab = tab
        contextSessionService.createNewContextSession(with: tab)
        
        coordinator
            .navigateTo(tab: tab)
        
        onNavigate()
    }
    
    func goBackToLastTab(onNavigate: @escaping (() -> Void) = {}) {
        guard lastTab != currentTab
        else { return }
        
        navigateTo(tab: lastTab,
                   onNavigate: onNavigate)
    }
    
    // MARK: - Tab Specific Data Selections
    func getLocalizedTextLabel(for tab: tabs) -> String {
        guard tab != .authScreen
        else { return absenceOfValue }
        
        switch tab {
        case .home:
            return homeTabLabel
        case .wallet:
            return walletTabLabel
        case .settings:
            return settingsTabLabel
        case .alerts:
            return alertsTabLabel
        case .authScreen:
            /// This is not a tab and is not supported by the tabbar
            return absenceOfValue
        }
    }
    
    /// Retrieve the icon for the given tab (excluding the auth screen)
    func getIcon(for tab: tabs) -> Image {
        guard tab != .authScreen
        else { return noIcon }
        
        switch tab {
        case .home:
            return homeIcon
        case .wallet:
            return walletIcon
        case .settings:
            return settingIcon
        case .alerts:
            return alertsIcon
        case .authScreen:
            /// This is not a tab and is not supported by the tabbar
            return noIcon
        }
    }
}
