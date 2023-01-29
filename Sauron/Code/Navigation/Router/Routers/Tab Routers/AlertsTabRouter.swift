//
//  AlertsTabRouter.swift
//  Sauron
//
//  Created by Justin Cook on 1/22/23.
//

import SwiftUI
import OrderedCollections

class AlertsTabRouter: Routable {
    typealias Route = AlertsRoutes
    typealias Body = AnyView
    
    // MARK: -  View Models
    @Published var alertsScreenViewModel: AlertsScreenViewModel!
    
    // MARK: - Observed
    @ObservedObject var coordinator: AlertsTabCoordinator
    
    init(coordinator: AlertsTabCoordinator) {
        self.coordinator = coordinator
        
        initViewModels()
    }
    
    func initViewModels() {
        self.alertsScreenViewModel = .init(coordinator: self.coordinator)
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
            view = AlertsScreen(model: self.alertsScreenViewModel)
            
            statusBarHidden = false
        }
        
        self.coordinator.statusBarHidden = statusBarHidden
        return AnyView(view
            .routerStatusBarVisibilityModifier(visible: statusBarHidden,
                                               coordinator: self.coordinator)
        )
    }
}

