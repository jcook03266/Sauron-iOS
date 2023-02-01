//
//  HomeScreen+CryptoNewsSectionExtension.swift
//  Sauron
//
//  Created by Justin Cook on 2/1/23.
//

import SwiftUI

/// An extension of the home screen | Crypto News Section
// MARK: - View Combinations
extension HomeScreen {
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
