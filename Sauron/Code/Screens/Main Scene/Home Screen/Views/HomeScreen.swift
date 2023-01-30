//
//  HomeScreen.swift
//  Sauron
//
//  Created by Justin Cook on 1/21/23.
//

import SwiftUI
import Shimmer

struct HomeScreen: View {
    typealias Router = HomeTabRouter
    
    // MARK: - Observed
    @StateObject var model: HomeScreenViewModel
    
    // MARK: - Styling
    private let backgroundGradient: LinearGradient = Colors.gradient_6
    private var backgroundColor: Color {
        return Color.clear
    }
    
    // MARK: - Dimensions
    private let foregroundContainerCornerRadius: CGFloat = 40,
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
    private let titleSectionBottomPadding: CGFloat = 10,
                titleSectionLeadingPadding: CGFloat = 10,
                sectionDividerVerticalPadding: CGFloat = 10,
                scrollViewBottomPadding: CGFloat = 100,
                // Shared
                sectionHeaderItemSpacing: CGFloat = 15,
                sectionHeaderTopSpacing: CGFloat = 10,
                sectionLeadingPadding: CGFloat = 15,
                utilityButtonSpacing: CGFloat = 10,
                // MY Portfolio
                portfolioPlaceholderImageTopPadding: CGFloat = 35,
                portfolioPlaceholderImageBottomPadding: CGFloat = 25,
                portfolioFooterTopPadding: CGFloat = 15,
                portfolioBottomPadding: CGFloat = 0,
                portfolioCoinGridContentHorizontalPadding: CGFloat = 20,
                portfolioCoinGridContentVerticalPadding: CGFloat = 10,
                portfolioCoinGridContentTopPadding: CGFloat = 10,
                portfolioCoinGridContentItemSpacing: CGFloat = 20,
                // Crypto News
                cryptoNewsSectionHeaderItemSpacing: CGFloat = 10,
                cryptoNewsSectionHeaderBottomPadding: CGFloat = 50,
                cryptoNewsSectionHeaderLeadingPadding: CGFloat = 40
    
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
    
    // My Portfolio
    var portfolioSection: some View {
        VStack(spacing: 0) {
            portfolioSectionHeader
            
            // Prompt user to add coins to their portfolio
            if model.shouldDisplayPortfolioSectionPlaceholder {
                portfolioPlaceholder
            }
            
            // User has coins, display them like normal
            if !model.shouldDisplayPortfolioSectionPlaceholder {
                portfolioCoinContent
                
                portfolioSectionFooter
            }
            
            Spacer()
        }
        .padding(.top,
                 sectionHeaderTopSpacing)
        .padding(.bottom,
                 portfolioBottomPadding)
    }
    
    // Crypto News
    var cryptoNewsSection: some View {
        VStack {
            sectionDivider
            
            cryptoNewsSectionHeader
                .padding(.bottom,
                         cryptoNewsSectionHeaderBottomPadding)
            
            FutureFeatureReleaseScreen(model: model.FFRScreenViewModel)
        }
    }
    
    var cryptoNewsSectionHeader: some View {
        HStack(spacing: cryptoNewsSectionHeaderItemSpacing) {
            cryptoNewsSectionIcon
            
            cryptoNewsSectionTitle
            
            Spacer()
        }
        .padding(.leading,
                 cryptoNewsSectionHeaderLeadingPadding)
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
    
    // My Portfolio
    var portfolioSectionHeader: some View {
        ScrollView (.horizontal,
                    showsIndicators: false)
        {
            HStack(alignment: .center,
                   spacing: sectionHeaderItemSpacing) {
                // Title
                Text(model.portfolioSectionTitle)
                    .withFont(model.sectionHeaderTitleFont)
                    .fontWeight(model.sectionHeaderTitleFontWeight)
                    .foregroundColor(model.sectionHeaderTitleColor)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                
                // Icon
                model.portfolioSectionIcon
                    .fittedResizableTemplateImageModifier()
                    .applyGradient(gradient: model.portfolioHeaderIconGradient)
                    .frame(width: sectionHeaderIconSize.width,
                           height: sectionHeaderIconSize.height)
                
                // Sort Toggle Button
                RectangularSortButton(model: model.portfolioSortButtonViewModel)
                
                Spacer()
            }
                   .padding(.leading,
                            sectionLeadingPadding)
        }
    }
    
    var portfolioPlaceholder: some View {
        VStack {
            HStack {
                Spacer()
                model.portfolioSectionPlaceholderImage
                    .fittedResizableTemplateImageModifier()
                    .foregroundColor(model.portfolioSectionPlaceholderImageColor)
                    .frame(width: portfolioPlaceholderImageSize.width,
                           height: portfolioPlaceholderImageSize.height)
                Spacer()
            }
            .padding(.bottom,
                     portfolioPlaceholderImageBottomPadding)
            
            // Start Portfolio Button
            StrongRectangularCTA(action: model.createPorfolioAction,
                                 backgroundColor: model.portfolioSectionPlaceholderButtonBackgroundColor,
                                 foregroundColor: model.portfolioSectionPlaceholderButtonForegroundColor,
                                 shadowColor: model.portfolioSectionPlaceholderButtonShadowColor,
                                 font: model.portfolioSectionPlaceholderButtonFont,
                                 size: portfolioPlaceholderButtonSize,
                                 message: (model.portfolioSectionPlaceholderButtonTitle, nil))
        }
        .padding(.top,
                 portfolioPlaceholderImageTopPadding)
    }
    
    var portfolioCoinContent: some View {
        ScrollView(.horizontal,
                   showsIndicators: false) {
            
            Group {
                // Placeholder for when coins are loading
                if model.portfolioIsLoading {
                    HStack(spacing: portfolioCoinGridContentItemSpacing) {
                        ForEach(model.placeholderViewRange, id: \.self)
                        { _ in
                            if let placeholderCoinData = model.placeholderCoinData {
                                CoinGridInformationView(model: .init(coinModel: placeholderCoinData))
                                    .redacted(reason: .placeholder)
                                    .shimmering(bounce: false)
                            }
                        }
                    }
                    .transition(.slideForwards)
                }
                else {
                    // The loaded coins
                    HStack(spacing: portfolioCoinGridContentItemSpacing) {
                        ForEach(model.portfolioCoins)
                        { coin in
                            CoinGridInformationView(model: .init(coinModel: coin))
                        }
                    }
                    .transition(.slideBackwards)
                }
            }
            .padding(.vertical,
                     portfolioCoinGridContentVerticalPadding)
            .padding(.horizontal,
                     portfolioCoinGridContentHorizontalPadding)
        }
                   .padding(.top,
                            portfolioCoinGridContentTopPadding)
    }
    
    var portfolioSectionFooter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: utilityButtonSpacing) {
                // Show all button
                StrongRectangularCTA(action: model.showAllPortfolioCoinsAction,
                                     backgroundColor: model.utilityButtonBackgroundColor,
                                     foregroundColor: model.utilityButtonTitleColor,
                                     shadowColor: model.shadowColor,
                                     font: model.utilityButtonTitleFont,
                                     size: showAllUtilityButtonSize,
                                     message: (model.showAllButtonTitle, nil))
                
                // Edit Button
                StrongRectangularCTA(action: model.editPortfolioAction,
                                     backgroundColor: model.utilityButtonBackgroundColor,
                                     foregroundColor: model.utilityButtonTitleColor,
                                     shadowColor: model.shadowColor,
                                     font: model.utilityButtonTitleFont,
                                     size: editUtilityButtonSize,
                                     message: (model.editButtonTitle, nil))
                
                // Maximize / Minimize Portfolio Section
                RoundedRectangularCTA(action: model.transitionPortfolioSectionAction,
                                      backgroundColor: model.specializedUtilityButtonBackgroundColor,
                                      titleGradient: model.specializedUtilityButtonTitleGradient,
                                      shadowColor: model.shadowColor,
                                      font: model.specializedUtilityButtonTitleFont,
                                      size: sectionTransitionUtilityButtonSize,
                                      message: (model.portfolioSectionTransitionButtonTitle, nil))
                
                Spacer()
            }
            // Unclip shadows
            .padding(.vertical, 5)
            .padding(.leading,
                     sectionLeadingPadding)
        }
        .padding(.top,
                 portfolioFooterTopPadding)
    }
    
    
    // Crypto News
    var cryptoNewsSectionTitle: some View {
        Text(model.cryptoNewsSectionTitle)
            .withFont(model.cryptoNewsSectionTitleFont)
            .fontWeight(model.cryptoNewsSectionTitleFontWeight)
            .applyGradient(gradient: model.cryptoNewsSectionTitleGradient)
            .minimumScaleFactor(0.5)
            .multilineTextAlignment(.center)
            .lineLimit(1)
    }
    
    var cryptoNewsSectionIcon: some View {
        model.cryptoNewsSectionIcon
            .fittedResizableTemplateImageModifier()
            .foregroundColor(model.cryptoNewsImageColor)
            .frame(width: cryptoNewsSectionIconSize.width,
                   height: cryptoNewsSectionIconSize.height)
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
