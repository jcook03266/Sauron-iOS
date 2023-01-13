//
//  LaunchScreenRouter.swift
//  Inspec
//
//  Created by Justin Cook on 11/22/22.
//

import SwiftUI
import OrderedCollections

class LaunchScreenRouter: Routable {
    typealias Route = LaunchScreenRoutes
    typealias Body = AnyView
    
    // MARK: - Observed
    @ObservedObject var coordinator: LaunchScreenCoordinator
    
    init(coordinator: LaunchScreenCoordinator) {
        self.coordinator = coordinator
        
        initViewModels()
    }
    
    func initViewModels() {
    }
    
    func getPath(to route: LaunchScreenRoutes) -> OrderedCollections.OrderedSet<LaunchScreenRoutes>
    { return [] }
    
    func view(for route: LaunchScreenRoutes) -> AnyView {
        switch route {
        case .main:
            return AnyView(LaunchScreenBridgeView())
        }
    }
}
