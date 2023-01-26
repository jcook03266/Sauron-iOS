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
    
    var radioButtonSize: CGFloat {
        return 20
    }
    
    // MARK: - Padding
    private let coinClusterGraphicLeadingPadding: CGFloat = -30,
                coinClusterGraphicTopPadding: CGFloat = 30,
                twoToneDotMatrixTrailingPadding: CGFloat = 5,
                twoToneDotMatrixTopPadding: CGFloat = 15,
                titleViewBottomPadding: CGFloat = 10,
                titleViewTopPadding: CGFloat = 5
    
    private var subscriptionPromptLeadingPadding: CGFloat {
        return 10
    }
    
    private var subscriptionPromptSubtitleLeadingPadding: CGFloat {
        return radioButtonSize + subscriptionPromptLeadingPadding
    }
    
    var body: some View {
        mainBody
    }
}

// MARK: - View Combinations
extension FutureFeatureReleaseScreen {
    var mainBody: some View {
        Group {
            if model.useLongFormat {
               longFormattedBody
            }
            else {
                shortFormattedBody
            }
        }
        .animation(.spring(),
                   value: model.isUserSubscribed)
    }
    
    var shortFormattedBody: some View {
        VStack(alignment: .leading,
               spacing: 0) {
            titleView
            
            subscriptionPromptTextStack
        }
    }
    
    var longFormattedBody: some View {
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
    
    var subscriptionPromptTextStack: some View {
        VStack(alignment: .leading,
               spacing: 0) {
  
                VStack(alignment: .leading,
                       spacing: 0) {
                    
                    HStack {
                        radioButton
                        
                        subscriptionPromptView
                    }
                    
                    subscriptionPromptSubtitleView
                        .padding(.leading,
                                 subscriptionPromptSubtitleLeadingPadding)
                }
                       .transition(.asymmetric(insertion: .slideBackwards,
                                               removal: .offset(x: 400)))
                       .id(model.isUserSubscribed)
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
                    
                    subscriptionPromptTextStack
                }
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
        RadioButton(model: model.radioButtonViewModel, outerDiameter: radioButtonSize)
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
