//
//  HomeScreen.swift
//  Sauron
//
//  Created by Justin Cook on 1/21/23.
//

import SwiftUI

struct HomeScreen: View {
    // MARK: - Observed
    @StateObject var model: HomeScreenViewModel
    
    // MARK: - Dimensions
    private let foregroundContainerCornerRadius: CGFloat = 40,
                titleHeight: CGFloat = 40,
                sectionDividerHeight: CGFloat = 1,
    // Crypto News
cryptoNewsSectionIconSize: CGSize = .init(width: 35,
                                          height: 35)
    
    // MARK: - Padding + Spacing
    private let titleSectionBottomPadding: CGFloat = 10,
                titleSectionLeadingPadding: CGFloat = 10,
                sectionDividerVerticalPadding: CGFloat = 10,
                // Crypto News
                cryptoNewsSectionHeaderItemSpacing: CGFloat = 10,
                cryptoNewsSectionHeaderBottomPadding: CGFloat = 50,
                cryptoNewsSectionHeaderLeadingPadding: CGFloat = 40
    
    var body: some View {
        contentContainer
            .animation(.spring(),
                       value: model.selectedSection)
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
    }
    
    private func performOnDisappearTasks() {
        model
            .eventBannerCarouselViewModel
            .stopAutoScroll()
    }
}

// MARK: - View Combinations
extension HomeScreen {
    // Title
    var titleSection: some View {
        HStack(spacing: 0) {
            titleView
            Spacer()
        }
        .padding(.bottom,
                 titleSectionBottomPadding)
        .padding(.leading,
                 titleSectionLeadingPadding)
    }
    
    // Main Content
    var contentContainer: some View {
        GeometryReader { geom in
            ZStack(alignment: .bottom) {
                background
                
                VStack(spacing: 0) {
                    titleSection
                    
                    HStack {
                        Spacer()
                        
                        ZStack(alignment: .bottom) {
                            foregroundContainer
                                .ignoresSafeArea()
                            
                            foregroundContent
                        }
                        .frame(width: geom.size.width * 0.975,
                               height: geom.size.height * 0.84)
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
                            .id(HomeScreenViewModel.Sections.eventBanner)
                        
                        cryptoNewsSection
                            .id(HomeScreenViewModel.Sections.news)
                    }
                    .onChange(of: model.selectedSection) {
                        guard $0 != nil
                        else { return }
                        
                        withAnimation(.spring()) {
                            model.scrollToSelectedSection(with: reader)
                        }
                    }
                }
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
    
    // Crypto News
    var cryptoNewsSection: some View {
        VStack {
            sectionDivider
            
            cryptoNewsSectionHeader
                .padding(.bottom, cryptoNewsSectionHeaderBottomPadding)
            
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
    
    // Greeting Section
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
