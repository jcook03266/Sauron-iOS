//
//  HomeScreenViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/21/23.
//

import SwiftUI

/// View model for the home screen tab in the main coordinator
class HomeScreenViewModel: CoordinatedGenericViewModel {
    typealias coordinator = HomeTabCoordinator
    
    // MARK: - Observed
    @ObservedObject var coordinator: coordinator
    
    // MARK: - Styling
    // Colors
    let backgroundColor: Color = Color.clear,
        foregroundContainerColor: Color = Colors.neutral_100.0,
        titleForegroundColor: Color = Colors.permanent_white.0,
        titleIconForegroundColor: Color = Colors.permanent_white.0
    
    // Fonts
    let titleFont: FontRepository = .heading_2,
        titleFontWeight: Font.Weight = .semibold
    
    // MARK: - Assets
    /// TDB
    
    // MARK: - Localized Text
    // TODO: - Create Daily Message Service For dynamic user message prompts for returning users, and first time users
    var title: String {
        return LocalizedStrings.getLocalizedString(for: .HOME_SCREEN_GREETING_RETURNING_USER_1)
    }
    
    init(coordinator: coordinator) {
        self.coordinator = coordinator
    }
}
