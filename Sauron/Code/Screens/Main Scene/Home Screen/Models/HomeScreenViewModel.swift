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
    let backgroundColor: Color = Color.clear,
        foregroundContainerColor: Color = Colors.white.0
    
    init(coordinator: coordinator) {
        self.coordinator = coordinator
    }
}
