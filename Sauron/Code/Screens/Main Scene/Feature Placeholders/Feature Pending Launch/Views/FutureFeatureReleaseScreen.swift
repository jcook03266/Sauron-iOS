//
//  FutureFeatureReleaseScreen.swift
//  Sauron
//
//  Created by Justin Cook on 1/23/23.
//

import SwiftUI

struct FutureFeatureReleaseScreen<HostCoordinator: Coordinator>: View {
    // MARK: - Observed
    @StateObject var model: FFRScreenViewModel<HostCoordinator>
    
    // MARK: - Dimensions
    private let coinClusterGraphicSize: CGSize = . init(width: 220,
                                                        height: 220),
                twoToneDotMatrixGraphicSize: CGSize = .init(width: 150,
                                                            height: 150),
                subscriptionPromptMaxWidth: CGFloat = 260
    
    // MARK: - Padding
    private let coinClusterGraphicLeadingPadding: CGFloat = -30,
                coinClusterGraphicTopPadding: CGFloat = 30,
                titleViewLeadingPadding: CGFloat = 70,
                twoToneDotMatrixTrailingPadding: CGFloat = 5,
                twoToneDotMatrixTopPadding: CGFloat = 15,
                titleViewBottomPadding: CGFloat = 10,
                titleViewTopPadding: CGFloat = 5
    
    private var subscriptionPromptLeadingPadding: CGFloat {
        return 10
    }
    
    var body: some View {
        mainBody
    }
}

// MARK: - View Combinations
extension FutureFeatureReleaseScreen {
    var mainBody: some View {
        GeometryReader { geom in
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    topSection
                    
                    subscriptionPromptSection
                    
                    bottomSection
                }
                .frame(minWidth: geom.size.width,
                       minHeight: geom.size.height)
            }
        }
        .animation(.spring(),
                   value: model.isUserSubscribed)
    }
    
    var topSection: some View {
        HStack {
            coinClusterBackgroundGraphicView
            Spacer()
        }
    }
    
    var bottomSection: some View {
        VStack(spacing: 0) {
            Spacer()
            
            appNameSignature
        }
    }
    
    var subscriptionPromptSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading,
                       spacing: 0) {
                    HStack {
                        titleView
                    }
                    
                    HStack(alignment: .top,
                           spacing: 0) {
                        radioButton
                        
                        VStack(alignment: .leading,
                               spacing: 0) {
                            subscriptionPromptView
                            subscriptionPromptSubtitleView
                        }
                               .transition(.asymmetric(insertion: .slideBackwards,
                                                       removal: .slideForwards))
                               .id(model.isUserSubscribed)
                               .padding(.leading,
                                        subscriptionPromptLeadingPadding)
                    }
                }
                       .padding(.leading,
                                titleViewLeadingPadding)
                
                Spacer()
            }
            
            HStack {
                Spacer()
                twoToneDotMatrixBackgroundGraphicView
            }
        }
    }
}

// MARK: - Subviews
extension FutureFeatureReleaseScreen {
    var radioButton: some View {
        RadioButton(model: model.radioButtonViewModel)
    }
    
    var coinClusterBackgroundGraphicView: some View {
        model.coinClusterBackgroundGraphic
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(.leading, coinClusterGraphicLeadingPadding)
            .padding(.top, coinClusterGraphicTopPadding)
            .frame(width: coinClusterGraphicSize.width,
                   height: coinClusterGraphicSize.height)
    }
    
    var twoToneDotMatrixBackgroundGraphicView: some View {
        model.twoToneDotMatrixBackgroundGraphic
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(.trailing,
                     twoToneDotMatrixTrailingPadding)
            .padding(.top,
                     twoToneDotMatrixTopPadding)
            .frame(width: twoToneDotMatrixGraphicSize.width,
                   height: twoToneDotMatrixGraphicSize.height)
    }
    
    var titleView: some View {
        Text(model.title)
            .withFont(model.titleFont)
            .fontWeight(model.titleFontWeight)
            .minimumScaleFactor(1)
            .foregroundColor(model.titleForegroundColor)
            .lineLimit(1)
            .multilineTextAlignment(.leading)
            .padding(.bottom,
                     titleViewBottomPadding)
            .padding(.top,
                     titleViewTopPadding)
    }
    
    var subscriptionPromptView: some View {
        HStack(spacing: 0) {
            Text(model.subscriptionPrompt)
                .withFont(model.subscriptionPromptFont)
                .fontWeight(model.subscriptionPromptFontWeight)
                .minimumScaleFactor(0.1)
                .applyGradient(gradient: model.subscriptionPromptForegroundGradient)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .frame(width: subscriptionPromptMaxWidth)
        .scaledToFill()
    }
    
    var subscriptionPromptSubtitleView: some View {
        HStack(spacing: 0) {
            Text(model.subscriptionPromptSubtitle)
                .withFont(model.subscriptionSubtitleFont)
                .minimumScaleFactor(0.1)
                .foregroundColor(model.subscriptionSubtitleForegroundColor)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .frame(width: subscriptionPromptMaxWidth)
        .scaledToFill()
    }
    
    var appNameSignature: some View {
        Text(model.appNameSignature)
            .withFont(model.appNameSignatureFont)
            .fontWeight(model.appNameSignatureFontWeight)
            .minimumScaleFactor(0.1)
            .lineLimit(1)
            .applyGradient(gradient: model.appNameSignatureGradient)
            .fixedSize()
    }
}

struct FutureFeatureReleaseScreen_Previews: PreviewProvider {
    static var previews: some View {
        FutureFeatureReleaseScreen(model: .init(coordinator: WalletTabCoordinator(parent: MainCoordinator()),
                                                targetMailingListSubscriptionType: .walletRelease))
    }
}
