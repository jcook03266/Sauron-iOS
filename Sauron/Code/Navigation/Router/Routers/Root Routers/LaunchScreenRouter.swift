//
//  LaunchScreenRouter.swift
//  Sauron
//
//  Created by Justin Cook on 11/22/22.
//

import SwiftUI
import OrderedCollections

class LaunchScreenRouter: Routable {
    typealias Route = LaunchScreenRoutes
    typealias Body = AnyView
    
    // MARK: -  View Models
    @Published var coverScreenViewModel: CoverScreenViewModel<LaunchScreenCoordinator>!
    
    // MARK: - Observed
    @ObservedObject var coordinator: LaunchScreenCoordinator
    
    init(coordinator: LaunchScreenCoordinator) {
        self.coordinator = coordinator
        
        initViewModels()
    }
    
    func initViewModels() {
        coverScreenViewModel = .init(coordinator: self.coordinator)
    }
    
    func getPath(to route: LaunchScreenRoutes) -> OrderedCollections.OrderedSet<LaunchScreenRoutes>
    {
        switch route {
        case .main:
            return [.main]
        }
    }
    
    func view(for route: LaunchScreenRoutes) -> AnyView {
        switch route {
        case .main:
            return AnyView(CoverScreenView(model: self.coverScreenViewModel))
        }
    }
}
