//
//  SRNTabbarTabViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/21/23.
//

import SwiftUI

/// View model for the buttons hosted inside of the tabbar view
class SRNTabbarTabViewModel: GenericViewModel {
    // MARK: - Properties
    typealias tabs = MainRoutes
    let id: UUID = .init()
    
    // MARK: - Interfacing with parent view model
    @ObservedObject var parent: SRNTabbarViewModel
    
    // MARK: - Published
    @Published var isSelected: Bool = false
    
    // MARK: - Static Instance Variables
    let tab: tabs
    
    // MARK: - Actions
    var action: (() -> Void) {
        return { [weak self] in
            guard let self = self
            else { return }
            
            self.parent.tabbarButtonPressed()
            self.parent.navigateTo(tab: self.tab,
                                   onNavigate: self.customOnNavigationAction)
            
            self.determineIfSelected()
        }
    }
    var customOnNavigationAction: (() -> Void) = {}
    
    // MARK: - Convenience
    var title: String {
        return parent.getLocalizedTextLabel(for: tab)
    }
    
    var font: FontRepository {
        return parent.tabbarButtonFont
    }
    
    var fontWeight: Font.Weight {
        return isSelected ? parent.tabbarButtonFontActiveWeight : parent.tabbarButtonFontInactiveWeigth
    }
    
    var foregroundColor: Color {
        return isSelected ? parent.tabButtonActiveForegroundColor : parent.tabButtonInactiveForegroundColor
    }
    
    init(parent: SRNTabbarViewModel,
         tab: tabs,
         customOnNavigationAction: @escaping () -> Void = {})
    {
        self.parent = parent
        self.tab = tab
        self.customOnNavigationAction = customOnNavigationAction
        
        determineIfSelected()
    }
    
    private func determineIfSelected() {
        isSelected = parent.currentTab == tab
    }
}
