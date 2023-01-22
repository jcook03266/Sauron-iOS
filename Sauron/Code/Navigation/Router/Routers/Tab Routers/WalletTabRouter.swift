//
//  WalletTabRouter.swift
//  Sauron
//
//  Created by Justin Cook on 1/22/23.
//

import SwiftUI
import OrderedCollections

class WalletTabRouter: Routable {
    typealias Route = WalletRoutes
    typealias Body = AnyView
    
    // MARK: -  View Models
    //@Published var buildsViewModel: BuildsViewModel!
    
    // MARK: - Observed
    @ObservedObject var coordinator: WalletTabCoordinator
    
    init(coordinator: WalletTabCoordinator) {
        self.coordinator = coordinator
        
        initViewModels()
    }
    
    func initViewModels() {
        
    }
    
    func getPath(to route: Route) -> OrderedCollections.OrderedSet<Route> {
        
        switch route {
        case .main:
            return [.main]
        }
    }
    
    func view(for route: Route) -> AnyView {
        var view: any View
        var statusBarHidden: Bool = false
        
        switch route {
        case .main:
            view = WalletScreen()
            
            statusBarHidden = false
        }
        
        return AnyView(view
            .routerStatusBarVisibilityModifier(visible: statusBarHidden,
                                               coordinator: self.coordinator)
        )
    }
}


