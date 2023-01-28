//
//  HomeTabRouter.swift
//  Sauron
//
//  Created by Justin Cook on 1/22/23.
//

import SwiftUI
import OrderedCollections

class HomeTabRouter: Routable {
    typealias Route = HomeRoutes
    typealias Body = AnyView
    
    // MARK: -  View Models
    @Published var homeScreenViewModel: HomeScreenViewModel!
    @Published var portfolioCurationViewModel: PortfolioCurationViewModel<HomeTabCoordinator>!
    
    // MARK: - Deeplink URL Fragments
    /// The section to scroll to on the home screen when passed a section identifier
    @Published var homeScreenSectionFragment: HomeScreenViewModel.Sections? = nil
    
    // MARK: - Deeplink Queries
    /// Portfolio Curation Screen
    @Published var portfolioCurationSearchQuery: String = ""
    @Published var filterPortfolioCoinsOnly: Bool = false
    
    // MARK: - Observed
    @ObservedObject var coordinator: HomeTabCoordinator
    
    init(coordinator: HomeTabCoordinator) {
        self.coordinator = coordinator
        
        initViewModels()
    }
    
    func initViewModels() {
        self.homeScreenViewModel = .init(coordinator: self.coordinator,
                                         router: self)
        self.portfolioCurationViewModel = .init(coordinator: self.coordinator,
                                                      router: self)
    }
    
    func getPath(to route: Route) -> OrderedCollections.OrderedSet<Route> {
        switch route {
        case .main:
            return [.main]
        
        case .editPortfolio:
            return [.main, .editPortfolio]
        }
    }
    
    func view(for route: Route) -> AnyView {
        var view: any View
        var statusBarHidden: Bool = false
        
        switch route {
        case .main:
            view = HomeScreen(model: self.homeScreenViewModel)
            
            statusBarHidden = false
        case .editPortfolio:
            view = PortfolioCurationView(model: self.portfolioCurationViewModel)
                .navigationBarBackButtonHidden(true)
            
            statusBarHidden = false
        }
        
        self.coordinator.statusBarHidden = statusBarHidden
        return AnyView(view
            .routerStatusBarVisibilityModifier(visible: statusBarHidden,
                                               coordinator: self.coordinator)
        )
    }
}

