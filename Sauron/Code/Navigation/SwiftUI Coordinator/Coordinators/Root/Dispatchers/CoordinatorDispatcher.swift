//
//  CoordinatorDispatcher.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import Foundation

/// Dispatches general coordinators that don't act as the roots for view hierarchies
public struct CoordinatorDispatcher {
    var parentCoordinator: any Coordinator
    
    // MARK: - Tabbar coordinator's child coordinators
    var homeTabCoordinator: HomeTabCoordinator {
        return HomeTabCoordinator(parent: parentCoordinator)
    }
    var walletTabCoordinator: WalletTabCoordinator {
        return WalletTabCoordinator(parent: parentCoordinator)
    }
    var settingsTabCoordinator: SettingsTabCoordinator {
        return SettingsTabCoordinator(parent: parentCoordinator)
    }
    var alertsTabCoordinator: AlertsTabCoordinator {
        return AlertsTabCoordinator(parent: parentCoordinator)
    }
    
    init(parentCoordinator: any Coordinator) {
        self.parentCoordinator = parentCoordinator
    }
    
    func getCoordinatorFor(tab: Coordinators) -> any Coordinator {
        switch tab {
        case .homeTabCoordinator:
            return self.homeTabCoordinator
        case .walletTabCoordinator:
            return self.walletTabCoordinator
        case .settingsTabCoordinator:
            return self.settingsTabCoordinator
        case .alertsTabCoordinator:
            return self.alertsTabCoordinator
        }
    }
    
    /// Keeps track of all tabbar tab coordinators
    enum Coordinators: Hashable, CaseIterable {
        case homeTabCoordinator
        case walletTabCoordinator
        case settingsTabCoordinator
        case alertsTabCoordinator
    }
}
