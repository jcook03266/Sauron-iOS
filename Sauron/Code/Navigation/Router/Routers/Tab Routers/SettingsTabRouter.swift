//
//  SettingsTabRouter.swift
//  Sauron
//
//  Created by Justin Cook on 1/22/23.
//

import SwiftUI
import OrderedCollections

class SettingsTabRouter: Routable {
    typealias Route = SettingsRoutes
    typealias Body = AnyView
    
    // MARK: -  View Models
    @Published var settingsScreenViewModel: SettingsScreenViewModel!
    
    // MARK: - Observed
    @ObservedObject var coordinator: SettingsTabCoordinator
    
    init(coordinator: SettingsTabCoordinator) {
        self.coordinator = coordinator
        
        initViewModels()
    }
    
    func initViewModels() {
        self.settingsScreenViewModel = .init(coordinator: self.coordinator)
    }
    
    func getPath(to route: Route) -> OrderedCollections.OrderedSet<Route> {
        
        switch route {
        case .main:
            return [.main]
        }
    }
    
    func getStringLiteral(for route: Route) -> String {
        return route.rawValue
    }
    
    func view(for route: Route) -> AnyView {
        var view: any View
        var statusBarHidden: Bool = false
        
        switch route {
        case .main:
            view = SettingsScreen(model: self.settingsScreenViewModel)
            
            statusBarHidden = false
        }
        
        /// Allow the coordinator to listen to updated from this toggle from this router
        self.coordinator.statusBarHidden = statusBarHidden
        return AnyView(view
            .routerStatusBarVisibilityModifier(visible: statusBarHidden,
                                               coordinator: self.coordinator)
        )
    }
}
