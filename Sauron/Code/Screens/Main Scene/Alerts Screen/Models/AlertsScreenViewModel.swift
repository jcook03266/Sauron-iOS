//
//  AlertsScreenViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/23/23.
//

import SwiftUI

class AlertsScreenViewModel: CoordinatedGenericViewModel {
    typealias coordinator = AlertsTabCoordinator
    
    // MARK: - Observed
    @ObservedObject var coordinator: coordinator
    /// Pending Feature Campaign
    @ObservedObject var FFRScreenViewModel: FFRScreenViewModel<coordinator>
    
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
    /// Images
    let titleIcon: Image = Icons.getIconImage(named: .cloud_sun_bolt_fill)
    
    // MARK: - Localized Text
    let title: String = LocalizedStrings.getLocalizedString(for: .ALERTS_SCREEN_TITLE)
    
    init(coordinator: coordinator) {
        self.coordinator = coordinator
        self.FFRScreenViewModel = .init(coordinator: coordinator,
                               targetMailingListSubscriptionType: .cloudAlertsRelease)
    }
}
