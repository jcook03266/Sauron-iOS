//
//  HomeScreen+PortfolioSectionExtension.swift
//  Sauron
//
//  Created by Justin Cook on 2/1/23.
//

import SwiftUI

/// An extension of the home screen | User Portfolio Coins Section
// MARK: - View Combinations
extension HomeScreen {
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
}

// MARK: - Subviews
extension HomeScreen {
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
    
    var portfolioGridView: some View {
        Group {
            // Placeholder for when coins are loading
            if model.portfolioIsLoading {
                HStack(spacing: portfolioCoinContentItemSpacing) {
                    ForEach(model.placeholderViewRange, id: \.self)
                    { _ in
                        if let placeholderCoinData = model.placeholderCoinData {
                            CoinGridInformationView(model: .init(coinModel: placeholderCoinData))
                                .redacted(reason: .placeholder)
                                .shimmering(bounce: false)
                        }
                    }
                }
            }
            else {
                // The loaded coins
                HStack(spacing: portfolioCoinContentItemSpacing) {
                    ForEach(model.portfolioCoins)
                    { coin in
                        CoinGridInformationView(model: .init(coinModel: coin))
                    }
                }
            }
        }
        .transition(.opacity
            .animation(.easeInOut))
        .matchedGeometryEffect(id: "portfolioCoinSection",
                               in: homeScreenNameSpace)
    }
    
    var portfolioListView: some View {
        Group {
            // Placeholder for when coins are loading
            if model.portfolioIsLoading {
                VStack(spacing: portfolioCoinContentItemSpacing) {
                    ForEach(model.placeholderViewRange, id: \.self)
                    { _ in
                        if let placeholderCoinData = model.placeholderCoinData {
                            CoinListInformationView(model: .init(coinModel: placeholderCoinData))
                                .redacted(reason: .placeholder)
                                .shimmering(bounce: false)
                        }
                    }
                }
            }
            else {
                // The loaded coins
                VStack(spacing: portfolioCoinContentItemSpacing) {
                    ForEach(model.portfolioCoins)
                    { coin in
                        CoinListInformationView(model: .init(coinModel: coin))
                    }
                }
            }
        }
        .transition(.opacity
            .animation(.easeInOut))
        .matchedGeometryEffect(id: "portfolioCoinSection",
                               in: homeScreenNameSpace)
    }
    
    var portfolioCoinContent: some View {
        ScrollView(model.portfolioSectionMaximized ? .horizontal : .vertical,
                   showsIndicators: false) {
            
            Group {
                if model.portfolioSectionMaximized {
                    portfolioGridView
                }
                else {
                    portfolioListView
                }
            }
            .animation(.spring(),
                       value: model.portfolioSectionMaximized)
            .padding(.vertical,
                     portfolioCoinContentVerticalPadding)
            .padding(.horizontal,
                     portfolioCoinContentHorizontalPadding)
        }
                   .padding(.top,
                            portfolioCoinContentTopPadding)
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
}
