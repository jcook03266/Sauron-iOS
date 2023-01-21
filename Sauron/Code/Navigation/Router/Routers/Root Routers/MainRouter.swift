//
//  MainRouter.swift
//  Sauron
//
//  Created by Justin Cook on 1/14/23.
//

import SwiftUI
import OrderedCollections

class MainRouter: Routable {
    typealias Route = MainRoutes
    typealias Body = AnyView
    
    // MARK: -  View Models
    @Published var homeScreenViewModel: HomeScreenViewModel!
    @Published var authScreenViewModel: AuthScreenViewModel!
    
    // MARK: - Observed
    @ObservedObject var coordinator: MainCoordinator
    
    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
        
        initViewModels()
    }
    
    func initViewModels() {
        self.homeScreenViewModel = .init(coordinator: self.coordinator)
        self.authScreenViewModel = .init(coordinator: self.coordinator)
    }
    
    func getPath(to route: MainRoutes) -> OrderedSet<MainRoutes> {
        return []
    }
    
    func view(for route: MainRoutes) -> AnyView {
        var view: any View = EmptyView() // TODO: Remove placeholder
        var statusBarHidden: Bool = false
        
        switch route {
        case .home:
            view = HomeScreen(model: self.homeScreenViewModel)
            
            statusBarHidden = false
        case .wallet:
            break
        case .settings:
            break
        case .alerts:
            break
        case .authScreen:
            view = AuthScreen(model: self.authScreenViewModel)
            
            statusBarHidden = self.coordinator.statusBarHidden
        }
        
        return AnyView(view
            .routerStatusBarVisibilityModifier(visible: statusBarHidden,
                                               coordinator: self.coordinator)
        )
    }
}

