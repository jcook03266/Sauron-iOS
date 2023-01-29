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
    @Published var authScreenViewModel: AuthScreenViewModel!
    @Published var tabbarModel: SRNTabbarViewModel!
    
    // MARK: - Observed
    @ObservedObject var coordinator: MainCoordinator
    
    // MARK: - Deeplinking Properties
    /// Use this to navigate via the tabbar to any supported scene
    @Published var currentTab: SRNTabbarTabViewModel.tabs = SRNTabbarViewModel.defaultTab
    
    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
        
        initViewModels()
    }
    
    func initViewModels() {
        self.authScreenViewModel = .init(coordinator: self.coordinator)
        self.tabbarModel = .init(coordinator: self.coordinator,
                                 router: self,
                                 currentTab: currentTab)
    }
    
    /// Switches the tabbar to the specified tab which translates to the rendered tabbar view
    func navigateTo(tab: SRNTabbarViewModel.tabs,
                    onNavigate: @escaping (() -> Void) = {})
    {
        tabbarModel.navigateTo(tab: tab,
                               onNavigate: onNavigate)
    }
    
    /// Since this is a tabbar coordinator the coordinator children handle their own path finding
    func getPath(to route: MainRoutes) -> OrderedCollections.OrderedSet<MainRoutes> {
        guard route == .authScreen
        else { return [] }
        
        return [.authScreen]
    }
    
    func getStringLiteral(for route: Route) -> String {
        return route.rawValue
    }
    
    func view(for route: MainRoutes) -> AnyView {
        var view: any View = EmptyView()
        var statusBarHidden: Bool = false
        
        switch route {
        case .home:
            break
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
        
        self.coordinator.statusBarHidden = statusBarHidden
        return AnyView(view
            .routerStatusBarVisibilityModifier(visible: statusBarHidden,
                                               coordinator: self.coordinator)
        )
    }
}

