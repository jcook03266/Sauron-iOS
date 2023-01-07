//
//  RootCoordinatorDispatcher.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import Foundation

/// Dispatches root coordinators
struct RootCoordinatorDispatcher {
    var delegate: RootCoordinatorDelegate
    
    var launchScreenCoordinator: LaunchScreenCoordinator {
        return LaunchScreenCoordinator(rootCoordinatorDelegate: delegate)
    }

    var onboardingCoordinator: OnboardingCoordinator {
        return OnboardingCoordinator(rootCoordinatorDelegate: delegate)
    }
//
//    var mainCoordinator: MainCoordinator {
//        return MainCoordinator(rootCoordinatorDelegate: delegate)
//    }
    
    init(delegate: RootCoordinatorDelegate) {
        self.delegate = delegate
    }
    
    func getRootCoordinatorFor(root: RootCoordinators) -> any RootCoordinator {
        switch root {
        case .launchScreenCoordinator:
            return self.launchScreenCoordinator
        case .onboardingCoordinator:
            return self.onboardingCoordinator
        case .mainCoordinator:
            return self.onboardingCoordinator
        }
    }
    
    /// Keeps track of all root coordinators
    enum RootCoordinators: Hashable, CaseIterable {
        case launchScreenCoordinator
        case onboardingCoordinator
        case mainCoordinator
    }
}
