//
//  OnboardingRouter.swift
//  Inspec
//
//  Created by Justin Cook on 11/15/22.
//

import SwiftUI

class OnboardingRouter: Routable {
    typealias Route = OnboardingRoutes
    typealias Body = AnyView
    
    // MARK: -  View Models
    @Published var onboardingViewModel: VOCViewModel!
    @Published var homeScreenViewModel: HomeScreenViewModel!
    @Published var portfolioCurationViewModel: PortfolioCurationViewModel!
    
    // MARK: - URLs
    @Published var webURL: URL!
    
    // MARK: - Observed
    @ObservedObject var coordinator: OnboardingCoordinator
    
    init(coordinator: OnboardingCoordinator) {
        self.coordinator = coordinator
        
        initViewModels()
    }
    
    func initViewModels() {
        self.onboardingViewModel = VOCViewModel(coordinator: self.coordinator)
        self.homeScreenViewModel = HomeScreenViewModel(coordinator: self.coordinator)
        self.portfolioCurationViewModel = PortfolioCurationViewModel(coordinator: self.coordinator)
    }
    
    func view(for route: OnboardingRoutes) -> AnyView {
        var view: any View
        var statusBarHidden: Bool = false
        
        switch route {
        case .onboarding:
            let progressBarCoordinator: ProgressBarNavigationCoordinator<VOCViewModel> = .init(viewModel: onboardingViewModel, progressBar: onboardingViewModel.progressBar)
            
            progressBarCoordinator.injectProgressViewOnTapActions()
            
            view = VOC(model: self.onboardingViewModel,
                       PBNCoordinator: progressBarCoordinator,
                       progressBarModel: self.onboardingViewModel.progressBar)
            
            statusBarHidden = true
        case .home:
            view = HomeScreen(model: self.homeScreenViewModel)
                .navigationBarBackButtonHidden(true)
            
            statusBarHidden = true
        case .portfolioCuration:
            view = PortfolioCurationView(model: self.portfolioCurationViewModel)
                .navigationBarBackButtonHidden(true)
            
            statusBarHidden = false
        case .web:
            view = SafariView(url: webURL)
            
            statusBarHidden = false
            
        case .currencyPreferenceBottomSheet:
            view = PreferenceBottomSheet(model: BottomSheetDispatcher.getCurrencyPreferenceModel(using: self.coordinator))
            
        case .languagePreferenceBottomSheet:
            view = PreferenceBottomSheet(model: BottomSheetDispatcher.getCurrencyPreferenceModel(using: self.coordinator))
            
        }
        
        return AnyView(view
            .routerStatusBarVisibilityModifier(visible: statusBarHidden,
                                               coordinator: self.coordinator)
        )
    }
}

