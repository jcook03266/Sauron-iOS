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
    
//    // MARK: - Tabbar coordinator's child coordinators
//    var buildsCoordinator: BuildsCoordinator {
//        return BuildsCoordinator(parent: parentCoordinator)
//    }
//    var componentsCoordinator: ComponentsCoordinator {
//        return ComponentsCoordinator(parent: parentCoordinator)
//    }
//    var commandCenterCoordinator: CommandCenterCoordinator {
//        return CommandCenterCoordinator(parent: parentCoordinator)
//    }
//    var exploreCoordinator: ExploreCoordinator {
//        return ExploreCoordinator(parent: parentCoordinator)
//    }
//    var inboxCoordinator: InboxCoordinator {
//        return InboxCoordinator(parent: parentCoordinator)
//    }
    
    init(parentCoordinator: any Coordinator) {
        self.parentCoordinator = parentCoordinator
    }
    
//    func getCoordinatorFor(root: Coordinators) -> any Coordinator {
//        switch root {
//        case .BuildsCoordinator:
//            return self.buildsCoordinator
//        case .ComponentsCoordinator:
//            return self.componentsCoordinator
//        case .CommandCenterCoordinator:
//            return self.commandCenterCoordinator
//        case .ExploreCoordinator:
//            return self.exploreCoordinator
//        case .InboxCoordinator:
//            return self.inboxCoordinator
//        }
//    }
//    
//    func getCoordinatorFor(coordinator: Coordinators) -> any Coordinator {
//        switch coordinator {
//        case .BuildsCoordinator:
//            return self.buildsCoordinator
//        case .ComponentsCoordinator:
//            return self.componentsCoordinator
//        case .CommandCenterCoordinator:
//            return self.commandCenterCoordinator
//        case .ExploreCoordinator:
//            return self.exploreCoordinator
//        case .InboxCoordinator:
//            return self.inboxCoordinator
//        }
//    }
    
    /// Keeps track of all general coordinators
    enum Coordinators: Hashable, CaseIterable {
        case BuildsCoordinator
        case ComponentsCoordinator
        case CommandCenterCoordinator
        case ExploreCoordinator
        case InboxCoordinator
    }
}
