//
//  HomeScreenViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/21/23.
//

import SwiftUI

/// View model for the home screen tab in the main coordinator
class HomeScreenViewModel: CoordinatedGenericViewModel {
    typealias coordinator = MainCoordinator
    
    // MARK: - Observed
    @ObservedObject var coordinator: MainCoordinator
    
    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }
}
