//
//  HomeScreen+TrendingSectionExtension.swift
//  Sauron
//
//  Created by Justin Cook on 2/4/23.
//

import SwiftUI

/// An extension of the home screen | Trending Coins Section
// MARK: - View Combinations
extension HomeScreen {
    // Trending
    var trendingSection: some View {
        VStack(spacing: 0) {
            sectionDivider
                .padding(.top,
                         -sectionDividerVerticalPadding)
            
            trendingSectionHeader
            trendingCoinsContent
        }
    }
}

// MARK: - Subviews
extension HomeScreen {
    var trendingSectionHeader: some View {
        ScrollView(.horizontal,
                   showsIndicators: false) {
            HStack(alignment: .center,
                   spacing: sectionHeaderItemSpacing) {
                // Title
                Text(model.trendingSectionTitle)
                    .withFont(model.sectionHeaderTitleFont)
                    .fontWeight(model.sectionHeaderTitleFontWeight)
                    .foregroundColor(model.sectionHeaderTitleColor)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                
                // Icon
                model.trendingSectionIcon
                    .fittedResizableTemplateImageModifier()
                    .applyGradient(gradient: model.trendingHeaderIconGradient)
                    .frame(width: sectionHeaderIconSize.width,
                           height: sectionHeaderIconSize.height)
                
                Spacer()
            }
                   .padding(.leading,
                            sectionLeadingPadding)
        }
    }
    
    var trendingCoinsGridView: some View {
        Group {
            // Placeholder for when coins are loading
            if model.allAssetsIsLoading {
                HStack(spacing: trendingCoinContentItemSpacing) {
                    ForEach(model.placeholderViewRange, id: \.self)
                    { _ in
                        if let placeholderCoinData = model.placeholderCoinData {
                            CoinChipletView(model:  .init(coinModel: placeholderCoinData))
                                .redacted(reason: .placeholder)
                                .shimmering(bounce: false)
                        }
                    }
                }
            }
            else {
                // The loaded coins
                HStack(spacing: trendingCoinContentItemSpacing) {
                    ForEach(model.trendingCoins)
                    { coin in
                        CoinChipletView(model: .init(coinModel: coin))
                    }
                }
            }
        }
        .transition(.opacity
            .animation(.easeInOut))
        .matchedGeometryEffect(id: "trendingCoinSection",
                               in: homeScreenNameSpace)
    }
    
    var trendingCoinsContent: some View {
        ScrollView(model
            .homeScreenUserPreferences
            .portfolioSectionMaximized ? .horizontal : .vertical,
                   showsIndicators: false) {
            
            trendingCoinsGridView
                .padding(.bottom,
                         trendingCoinsContentPadding)
                .padding(.horizontal,
                         trendingCoinsContentHorizontalPadding)
        }
                   .padding(.top,
                            trendingCoinsContentPadding)
    }
}
