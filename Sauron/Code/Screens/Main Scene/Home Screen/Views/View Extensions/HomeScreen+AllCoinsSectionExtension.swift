//
//  HomeScreen+AllCoinsSectionExtension.swift
//  Sauron
//
//  Created by Justin Cook on 2/1/23.
//

import SwiftUI

/// An extension of the home screen | All Assets / Coins Section
// MARK: - View Combinations
extension HomeScreen {
    // All Assets
    var allAssetsSection: some View {
        VStack(spacing: 0) {
            sectionDivider
                .padding(.top,
                         -sectionDividerVerticalPadding)
            
            allAssetsSectionHeader
            allAssetsCoinContent
            allAssetsSectionFooter
        }
    }
}

// MARK: - Subviews
extension HomeScreen {
    // All Assets
    var allAssetsSectionHeader: some View {
        ScrollView (.horizontal,
                    showsIndicators: false)
        {
            HStack(alignment: .center,
                   spacing: sectionHeaderItemSpacing) {
                // Title
                Text(model.allAssetsSectionTitle)
                    .withFont(model.allAssetsSectionHeaderTitleFont)
                    .fontWeight(model.sectionHeaderTitleFontWeight)
                    .foregroundColor(model.sectionHeaderTitleColor)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                
                // Icon
                model.allAssetsSectionIcon
                    .fittedResizableTemplateImageModifier()
                    .applyGradient(gradient: model.allAssetsHeaderIconGradient)
                    .frame(width: sectionHeaderIconSize.width,
                           height: sectionHeaderIconSize.height)
                
                Spacer()
            }
                   .padding(.leading,
                            sectionLeadingPadding)
        }
    }
    
    var allAssetsGridView: some View {
        Group {
            // Placeholder for when coins are loading
            if model.allAssetsIsLoading {
                HStack(spacing: allAssetsCoinContentItemSpacing) {
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
                HStack(spacing: allAssetsCoinContentItemSpacing) {
                    ForEach(model.allCoins)
                    { coin in
                        CoinGridInformationView(model: .init(coinModel: coin))
                    }
                }
            }
        }
        .transition(.opacity
            .animation(.easeInOut))
        .matchedGeometryEffect(id: "allAssetsCoinSection",
                               in: homeScreenNameSpace)
    }
    
    var allAsssetsListView: some View {
        Group {
            // Placeholder for when coins are loading
            if model.allAssetsIsLoading {
                VStack(alignment: .leading,
                       spacing: allAssetsCoinContentItemSpacing) {
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
                VStack(alignment: .leading,
                       spacing: allAssetsCoinContentItemSpacing) {
                    ForEach(model.allCoins)
                    { coin in
                        CoinListInformationView(model: .init(coinModel: coin))
                    }
                }
            }
        }
        .transition(.opacity
            .animation(.easeInOut))
        .matchedGeometryEffect(id: "allAssetsCoinSection",
                               in: homeScreenNameSpace)
    }
    
    var allAssetsCoinContent: some View {
        ScrollView(model
            .homeScreenUserPreferences
            .allAssetsSectionMaximized ? .horizontal : .vertical,
                   showsIndicators: false) {
            Group {
                if model
                    .homeScreenUserPreferences
                    .allAssetsSectionMaximized {
                    allAssetsGridView
                }
                else {
                    allAsssetsListView
                }
            }
            .padding(.bottom,
                     allAssetsCoinContentPadding)
            .padding(.horizontal,
                     allAssetsContentHorizontalPadding)
        }
                   .padding(.top,
                            allAssetsCoinContentPadding)
    }
    
    var allAssetsSectionFooter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: utilityButtonSpacing) {
                // Show all button
                StrongRectangularCTA(action: model.transitionAllAssetsSectionAction,
                                     backgroundColor: model.utilityButtonBackgroundColor,
                                     foregroundColor: model.utilityButtonTitleColor,
                                     shadowColor: model.shadowColor,
                                     font: model.utilityButtonTitleFont,
                                     size: showAllUtilityButtonSize,
                                     message: (model.showAllButtonTitle, nil))
                
                // Maximize / Minimize All Assets Section
                RoundedRectangularCTA(action: model.transitionAllAssetsSectionAction,
                                      backgroundColor: model.specializedUtilityButtonBackgroundColor,
                                      titleGradient: model.specializedUtilityButtonTitleGradient,
                                      shadowColor: model.shadowColor,
                                      font: model.specializedUtilityButtonTitleFont,
                                      size: sectionTransitionUtilityButtonSize,
                                      message: (model.allAssetsSectionTransitionButtonTitle, nil))
                
                Spacer()
            }
            // Unclip shadows
            .padding(.vertical,
                     sectionFooterVerticalPadding)
            .padding(.leading,
                     sectionLeadingPadding)
        }
        .padding(.top,
                 sectionFooterTopPadding)
    }
}
