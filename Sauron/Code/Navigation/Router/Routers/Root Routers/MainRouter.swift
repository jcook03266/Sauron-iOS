////
////  MainRouter.swift
////  Sauron
////
////  Created by Justin Cook on 1/14/23.
////
//
//import SwiftUI
//import OrderedCollections
//
//class MainRouter: Routable {
//    typealias Route = OnboardingRoutes
//    typealias Body = AnyView
//    
//    // MARK: -  View Models
//    @Published var onboardingViewModel: VOCViewModel!
//    @Published var homeScreenViewModel: GetStartedScreenViewModel!
//    @Published var portfolioCurationViewModel: PortfolioCurationViewModel!
//    
//    // MARK: - URLs
//    @Published var webURL: URL!
//    
//    // MARK: - Deeplink Queries
//    /// Portfolio Curation Screen
//    @Published var portfolioCurationSearchQuery: String = ""
//    @Published var filterPortfolioCoinsOnly: Bool = false
//    
//    // MARK: - Observed
//    @ObservedObject var coordinator: OnboardingCoordinator
//    
//    // MARK: - Dependencies
//    struct Dependencies: InjectableServices {
//        var ftueService: FTUEService = inject()
//    }
//    internal var dependencies = Dependencies()
//    
//    init(coordinator: OnboardingCoordinator) {
//        self.coordinator = coordinator
//        
//        initViewModels()
//    }
//    
//    func initViewModels() {
//        self.onboardingViewModel = VOCViewModel(coordinator: self.coordinator)
//        self.homeScreenViewModel = GetStartedScreenViewModel(coordinator: self.coordinator)
//        self.portfolioCurationViewModel = PortfolioCurationViewModel(coordinator: self.coordinator,
//                                                                     router: self)
//    }
//    
//    func getPath(to route: OnboardingRoutes) -> OrderedSet<OnboardingRoutes> {
//        var path: OrderedSet<OnboardingRoutes> = []
//        
//        switch route {
//        case .onboarding:
//            path = [.onboarding]
//        case .home:
//            path = [.onboarding, .home]
//        case .portfolioCuration:
//            path = [.onboarding, .home, .portfolioCuration]
//        case .web:
//            path = [.onboarding, .home, .web]
//        case .currencyPreferenceBottomSheet:
//            path = [.onboarding, .home, .portfolioCuration, .currencyPreferenceBottomSheet]
//        }
//        
//        /// If the user has completed onboarding then this view will never be in the navigation stack
//        if dependencies.ftueService.didCompleteOnboarding {
//            path.remove(.onboarding)
//        }
//        
//        return path
//    }
//    
//    func view(for route: OnboardingRoutes) -> AnyView {
//        var view: any View
//        var statusBarHidden: Bool = false
//        
//        switch route {
//        case .onboarding:
//            let progressBarCoordinator: ProgressBarNavigationCoordinator<VOCViewModel> = .init(viewModel: onboardingViewModel, progressBar: onboardingViewModel.progressBar)
//            
//            progressBarCoordinator.injectProgressViewOnTapActions()
//            
//            view = VOC(model: self.onboardingViewModel,
//                       PBNCoordinator: progressBarCoordinator,
//                       progressBarModel: self.onboardingViewModel.progressBar)
//            
//            statusBarHidden = true
//        case .home:
//            view = HomeScreen(model: self.homeScreenViewModel)
//                .navigationBarBackButtonHidden(true)
//            
//            statusBarHidden = true
//        case .portfolioCuration:
//            view = PortfolioCurationView(model: self.portfolioCurationViewModel)
//                .navigationBarBackButtonHidden(true)
//            
//            statusBarHidden = true
//        case .web:
//            view = SafariView(url: webURL)
//            
//        case .currencyPreferenceBottomSheet:
//            view = PreferenceBottomSheet(model: BottomSheetDispatcher.getCurrencyPreferenceModel(using: self.coordinator))
//            
//            statusBarHidden = self.coordinator.statusBarHidden
//        }
//        
//        return AnyView(view
//            .routerStatusBarVisibilityModifier(visible: statusBarHidden,
//                                               coordinator: self.coordinator)
//        )
//    }
//}
//
