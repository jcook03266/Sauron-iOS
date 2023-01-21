//
//  RootCoordinatorDispatcher.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import Foundation

/// Dispatches root coordinators
class RootCoordinatorDispatcher {
    var delegate: RootCoordinatorDelegate
    
    var launchScreenCoordinator: LaunchScreenCoordinator!,
        onboardingCoordinator: OnboardingCoordinator!,
        mainCoordinator: MainCoordinator!
    
    init(delegate: RootCoordinatorDelegate) {
        self.delegate = delegate
        
        initCoordinators()
    }
    
    func initCoordinators() {
        launchScreenCoordinator = .init(rootCoordinatorDelegate: delegate)
        onboardingCoordinator = .init(rootCoordinatorDelegate: delegate)
        mainCoordinator = .init(rootCoordinatorDelegate: delegate)
    }
    
    func getRootCoordinatorFor(root: RootCoordinators) -> any RootCoordinator {
        switch root {
        case .launchScreenCoordinator:
            return self.launchScreenCoordinator
        case .onboardingCoordinator:
            return self.onboardingCoordinator
        case .mainCoordinator:
            return self.mainCoordinator
        }
    }
    
    /// Keeps track of all root coordinators
    enum RootCoordinators: Hashable, CaseIterable {
        case launchScreenCoordinator
        case onboardingCoordinator
        case mainCoordinator
    }
}
