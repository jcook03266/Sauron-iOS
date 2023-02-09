//
//  HomeScreen.swift
//  Sauron
//
//  Created by Justin Cook on 1/21/23.
//

import SwiftUI
import Shimmer

struct HomeScreen: View {
    @Namespace var homeScreenNameSpace
    typealias Router = HomeTabRouter
    
    // MARK: - Observed
    @StateObject var model: HomeScreenViewModel
    
    // MARK: - Styling
    let backgroundGradient: LinearGradient = Colors.gradient_6
    var backgroundColor: Color {
        return Color.clear
    }
    
    // MARK: - Dimensions
    let foregroundContainerCornerRadius: CGFloat = 40,
        titleHeight: CGFloat = 40,
        sectionDividerHeight: CGFloat = 1,
        // Shared
        sectionHeaderIconSize: CGSize = .init(width: 20,
                                              height: 20),
        showAllUtilityButtonSize: CGSize = .init(width: 120,
                                                 height: 30),
        editUtilityButtonSize: CGSize = .init(width: 80,
                                              height: 30),
        sectionTransitionUtilityButtonSize: CGSize = .init(width: 85,
                                                           height: 25),
        // My Portfolio
        portfolioPlaceholderImageSize: CGSize = .init(width: 100,
                                                      height: 100),
        portfolioPlaceholderButtonSize: CGSize = .init(width: 270,
                                                       height: 50),
        // Crypto News
        cryptoNewsSectionIconSize: CGSize = .init(width: 35,
                                                  height: 35)
    
    // MARK: - Padding + Spacing
    let titleSectionBottomPadding: CGFloat = 10,
        titleSectionLeadingPadding: CGFloat = 10,
        sectionDividerVerticalPadding: CGFloat = 10,
        scrollViewBottomPadding: CGFloat = 100,
        // Shared
        sectionHeaderItemSpacing: CGFloat = 15,
        sectionHeaderTopSpacing: CGFloat = 10,
        sectionHeaderItemVerticalPadding: CGFloat = 2,
        sectionLeadingPadding: CGFloat = 15,
        utilityButtonSpacing: CGFloat = 10,
        coinContentScrollViewVerticalPadding: CGFloat = 30,
        sectionFooterVerticalPadding: CGFloat = 5,
        sectionFooterTopPadding: CGFloat = 5,
        // My Portfolio
        portfolioPlaceholderImageTopPadding: CGFloat = 35,
        portfolioPlaceholderImageBottomPadding: CGFloat = 25,
        portfolioCoinContentHorizontalPadding: CGFloat = 20,
        portfolioCoinContentPadding: CGFloat = 10,
        // Trending
        trendingCoinContentItemSpacing: CGFloat = 20,
        trendingCoinsContentPadding: CGFloat = 10,
        trendingCoinsContentHorizontalPadding: CGFloat = 20,
        // All Assets
        allAssetsContentHorizontalPadding: CGFloat = 20,
        allAssetsCoinContentPadding: CGFloat = 10,
        // Crypto News
        cryptoNewsSectionHeaderItemSpacing: CGFloat = 10,
        cryptoNewsSectionHeaderBottomPadding: CGFloat = 50,
        cryptoNewsSectionHeaderLeadingPadding: CGFloat = 40
    
    // Dynamic Content
    // My Portfolio
    var portfolioCoinContentItemSpacing: CGFloat {
        return model.homeScreenUserPreferences.portfolioSectionMaximized ? 20 : 10
    }
    
    // All Assets
    var allAssetsCoinContentItemSpacing: CGFloat {
        return model.homeScreenUserPreferences.allAssetsSectionMaximized ? 20 : 10
    }
    
    var body: some View {
        NavigationStack(path: $model.navigationPath) {
            ZStack {
                Group {
                    backgroundGradient
                    backgroundColor
                }
                .ignoresSafeArea()
                
                contentContainer
                    .fullScreenCover(item: $model.fullCoverItemState,
                                     onDismiss: {
                        DispatchQueue.main.async {
                            model.coordinator.dismissFullScreenCover()
                        }
                    },
                                     content: { route in model.coordinator.router.view(for: route)
                    })
                    .sheet(item: $model.sheetItemState,
                           onDismiss: {
                        DispatchQueue.main.async {
                            model.coordinator.dismissSheet()
                        }
                    },
                           content: { route in model
                            .coordinator
                            .router
                            .view(for: route)
                    })
                    .navigationDestination(for: Router.Route.self,
                                           destination: { route in model
                            .coordinator
                            .router
                            .view(for: route)
                    })
            }
        }
        .background(backgroundColor)
        .background(backgroundGradient)
        .animation(.spring(),
                   value: model.selectedSection)
        .animation(.spring(),
                   value: model.shouldDisplayGreeting)
        .animation(.spring(),
                   value: model
            .homeScreenUserPreferences
            .portfolioSectionMaximized)
        .animation(.spring(),
                   value: model
            .homeScreenUserPreferences
            .allAssetsSectionMaximized)
        .animation(.easeInOut, value: model.isReloading)
        .onAppear {
            performOnAppearTasks()
        }
        .onDisappear {
            performOnDisappearTasks()
        }
    }
    
    private func performOnAppearTasks() {
        model
            .eventBannerCarouselViewModel
            .startAutoScroll()
        
        model.setUserHasSeenHomeScreen()
    }
    
    private func performOnDisappearTasks() {
        model
            .eventBannerCarouselViewModel
            .stopAutoScroll()
    }
}

// MARK: - View Combinations
extension HomeScreen {
    // Greeting Section
    var GreetingSection: some View {
        Group {
            if model.shouldDisplayGreeting {
                HStack(spacing: 0) {
                    titleView
                    Spacer()
                }
                .padding(.bottom,
                         titleSectionBottomPadding)
                .padding(.leading,
                         titleSectionLeadingPadding)
                .transition(
                    .offset(x: -400)
                    .animation(.spring())
                )
            }
        }
    }
    
    // Main Content
    var contentContainer: some View {
        GeometryReader { geom in
            ZStack(alignment: .bottom) {
                background
                
                VStack(spacing: 0) {
                    GreetingSection
                    
                    HStack {
                        Spacer()
                        
                        ZStack(alignment: .bottom) {
                            foregroundContainer
                                .ignoresSafeArea()
                            
                            foregroundContent
                        }
                        .frame(width: geom.size.width * 0.975,
                               height: geom.size.height * 0.84 + (model.shouldDisplayGreeting ? 0 : 40))
                    }
                }
            }
        }
    }
    
    var foregroundContent: some View {
        VStack(spacing: 0) {
            eventBannerHeaderSection
            
            scrollViewContent
        }
    }
    
    var scrollViewContent: some View {
        GeometryReader { geom in
            ScrollView(.vertical,
                       showsIndicators: true) {
                ScrollViewReader { reader in
                    VStack {
                        eventBannerSectionAnchor
                            .id(HomeScreenViewModel
                                .Sections
                                .eventBanner)
                        
                        portfolioSection
                            .id(HomeScreenViewModel
                                .Sections
                                .myPortfolio)
                        
                        trendingSection
                            .id(HomeScreenViewModel
                                .Sections
                                .trendingCoins)
                        
                        allAssetsSection
                            .id(HomeScreenViewModel
                                .Sections
                                .allAssets)
                        
                        cryptoNewsSection
                            .id(HomeScreenViewModel
                                .Sections
                                .news)
                    }
                    .onChange(of: model.selectedSection) {
                        guard $0 != nil
                        else { return }
                        
                        withAnimation(.spring()) {
                            model.scrollToSelectedSection(with: reader)
                        }
                    }
                }
                .padding(.bottom,
                         scrollViewBottomPadding)
                .frame(minWidth: geom.size.width,
                       minHeight: geom.size.height)
            }
                       .scrollDismissesKeyboard(.automatic)
                       .refreshable(action: {
                           model.refresh()
                       })
        }
    }
    
    // Event Header
    var eventBannerHeaderSection: some View {
        VStack {
            eventBannerCarouselView
            
            if !model.isEventBannerSingular {
                sectionDivider
                    .padding(.bottom,
                             -sectionDividerVerticalPadding)
            }
        }
    }
}

// MARK: - Subviews
extension HomeScreen {
    // Background Elements
    var background: some View {
        Rectangle()
            .fill(model.backgroundColor)
            .ignoresSafeArea()
    }
    
    var foregroundContainer: some View {
        Rectangle()
            .fill(model.foregroundContainerColor)
            .cornerRadius(foregroundContainerCornerRadius,
                          corners: [.topLeft,
                                    .bottomLeft])
    }
    
    // Trending
    
    // Shared
    var sectionDivider: some View {
        GeometryReader { geom in
            StraightSolidDividingLine(color: model.sectionDividerColor,
                                      width: geom.size.width,
                                      height: sectionDividerHeight)
        }
        .frame(height: sectionDividerHeight)
        .padding(.vertical,
                 sectionDividerVerticalPadding)
    }
    
    // User Personalized Greeting
    var titleView: some View {
        Text(model.title)
            .withFont(model.titleFont)
            .fontWeight(model.titleFontWeight)
            .minimumScaleFactor(0.5)
            .foregroundColor(model.titleForegroundColor)
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .frame(height: titleHeight)
    }
    
    // Event Header
    var eventBannerCarouselView: some View {
        EventBannerCarouselView(model: model.eventBannerCarouselViewModel, currentPage: $model.eventBannerCarouselViewModel.currentPage)
    }
    
    /// Gives the scrollview an anchor to scroll to when the event banner section is selected as a section when a fragment is passed in via deeplink
    /// This effectively scrolls the scrollview to the top aka a 0 vertical offset
    var eventBannerSectionAnchor: some View {
        EmptyView()
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(model: .init(coordinator: .init(parent: MainCoordinator()),
                                router: .init(coordinator: .init(parent: MainCoordinator()))))
        .background(Colors.gradient_6)
        .ignoresSafeArea()
    }
}
