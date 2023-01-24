//
//  GetStartedScreen.swift
//  Sauron
//
//  Created by Justin Cook on 11/18/22.
//

import SwiftUI

struct GetStartedScreen: View {
    // MARK: - Observed
    @StateObject var model: GetStartedScreenViewModel
    
    // MARK: - States
    @State private var didAppear: Bool = false
    
    // MARK: - Padding + Dimensions
    private let topBarCornerRadius: CGFloat = 40,
        topBarHeight: CGFloat = 100,
        sideVerticalDividerWidth: CGFloat = 3,
        sideVerticalDividerLeadingPadding: CGFloat = 30,
        lottieAnimationSize: CGFloat = 290,
        appIconSize: CGFloat = 100,
        appIconShadowRadius: CGFloat = 5,
        topSectionTopPadding: CGFloat = 40,
        sideVerticalDividerDotSize: CGFloat = 20,
        forkPromptDotSize: CGFloat = 40,
        bottomSectionLeadingPadding: CGFloat = 22,
        portfolioActionButtonsTrailingPadding: CGFloat = 15,
        learnMorePromptLeadingPadding: CGFloat = -10,
        curatePortfolioButtonWidth: CGFloat = 370,
        autoGenPortfolioButtonWidth: CGFloat = 270,
        portfolioCurationButtonsHeight: CGFloat = 60,
        ctaButtonsSpacing: CGFloat = 20,
        learnMorePromptTopPadding: CGFloat = 40,
        getStartedPromptTopPadding: CGFloat = -20,
        tosPPPortalTopPadding: CGFloat = 50
    
    // MARK: - Assets
    var lottieAnimationView: some View {
        HStack {
            if didAppear {
                Spacer()
                
                if let animation = model.lottieAnimation {
                    let lottieView = LottieViewUIViewRepresentable(animationName: animation, shouldPlay: .constant(true))
                    
                    lottieView
                        .frame(width: lottieAnimationSize,
                               height: lottieAnimationSize)
                        .padding(.top,
                                 0)
                        .scaledToFit()
                        .transition(.scale)
                }
                
                Spacer()
            }
        }
        .animation(
            .spring()
            .speed(0.7)
            .delay(1),
            value: didAppear)
    }
    
    var appIcon: some View {
        HStack {
            if didAppear {
                Spacer()
                
                model.appIcon
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: appIconSize,
                           height: appIconSize)
                    .shadow(color: model.appIconShadowColor,
                            radius: appIconShadowRadius)
                    .scaledToFit()
                    .transition(.scale)
                
                Spacer()
            }
        }
        .animation(
            .spring()
            .speed(0.7)
            .delay(1.25),
            value: didAppear)
    }
    
    // MARK: - Background
    var topBar: some View {
        GeometryReader { geom in
            HStack {
                Spacer()
                
                Rectangle()
                    .applyGradient(gradient: model.roundedTopBarBackgroundGradient)
                    .cornerRadius(topBarCornerRadius,
                                  corners: .bottomLeft)
                    .frame(width: geom.size.width * 0.9,
                           height: topBarHeight)
                    .shadow(color: Colors.shadow_1.0,
                            radius: 4)
            }
        }
        .ignoresSafeArea()
    }
    
    
    // MARK: - Foreground
    var getStartedPrompt: some View {
        Text(model.getStartedPrompt)
            .font(model.titleFont)
            .withFont(model.titleFontName)
            .minimumScaleFactor(0.1)
            .scaledToFit()
            .applyGradient(gradient: model.titleGradient)
            .fixedSize()
    }
    
    var sideVerticalDivider: some View {
        GeometryReader { geom in
            StraightSolidDividingLine(width: sideVerticalDividerWidth,
                                      height: geom.size.height,
                                      gradient: model.verticalDividerGradient)
            .padding(.leading,
                     sideVerticalDividerLeadingPadding)
        }
        .ignoresSafeArea()
    }
    
    var sideVerticalDividerDot: some View {
        Circle()
            .frame(width: sideVerticalDividerDotSize,
                   height: sideVerticalDividerDotSize)
            .foregroundColor(model.verticalDividerDotColor)
            .shadow(color: Colors.shadow_1.0,
                    radius: 4)
    }
    
    var curatePortfolioButton: some View {
        GeometryReader { geom in
            HStack {
                Spacer()
                
                StrongRectangularCTA(action: {
                    model.curatePortfolioAction()
                },
                                     backgroundColor: model.autoGenButtonBackgroundColor,
                                     foregroundColor: model.curateButtonForegroundColor,
                                     font: model.ctaButtonFonts,
                                     size: CGSize(width: geom.size.width * 0.95,
                                                  height: portfolioCurationButtonsHeight),
                                     message: (nil, model.curatePortfolioButtonText),
                                     borderEnabled: false,
                                     gradient: model.curateButtonBackgroundGradient)
            }
        }
        .frame(height: portfolioCurationButtonsHeight)
    }
    
    var autoGenPortfolioButton: some View {
        GeometryReader { geom in
            HStack {
                Spacer()
                
                StrongRectangularCTA(action: {
                    model.autoGeneratePortfolioAction()
                },
                                     backgroundColor: model.autoGenButtonBackgroundColor,
                                     foregroundColor: model.autoGenButtonForegroundColor,
                                     font: model.ctaButtonFonts,
                                     size: CGSize(width: geom.size.width * 0.75,
                                                  height: portfolioCurationButtonsHeight),
                                     message: (nil, model.autoGenPortfolioButtonText),
                                     borderEnabled: true)
            }
        }
        .frame(height: portfolioCurationButtonsHeight)
    }
    
    var orForkPrompt: some View {
        ZStack {
            Circle()
                .frame(width: forkPromptDotSize,
                       height: forkPromptDotSize)
                .foregroundColor(model.forkPromptBackgroundColor)
            
            Text(model.orForkPrompt)
                .withFont(model.forkPromptFont)
                .minimumScaleFactor(0.1)
                .scaledToFit()
                .foregroundColor(model.forkPromptForegroundColor)
                .fixedSize()
        }
        .shadow(color: Colors.shadow_1.0,
                radius: 4)
    }
    
    var learnMoreButton: some View {
        Button(action: {
            model.learnMoreAboutCryptoAction()
        }) {
            Text(model.learnMoreButtonText)
                .withFont(model.learnMoreButtonFont)
                .minimumScaleFactor(0.1)
                .scaledToFit()
                .applyGradient(gradient: model.learnMoreButtonGradient)
                .fixedSize()
        }
        .buttonStyle(OffsettableShrinkButtonStyle(offset: CGSize(width: -10, height: 0)))
    }
    
    var appNameSignature: some View {
        Text(model.appNameSignature)
            .withFont(model.appNameSignatureFont)
            .fontWeight(model.appNameSignatureFontWeight)
            .minimumScaleFactor(0.1)
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .applyGradient(gradient: model.appNameSignatureGradient)
            .fixedSize()
    }
    
    // MARK: - View Combinations
    var topSection: some View {
            ZStack {
                lottieAnimationView
                appIcon
            }
            .scaledToFit()
        .padding(.top,
                 topSectionTopPadding)
    }
    
    var getStartedPromptSection: some View {
        HStack {
            if didAppear {
                sideVerticalDividerDot
                    .transition(.offset(y: -1000))
                
                getStartedPrompt
                    .transition(.offset(x: 1000))
                
                Spacer()
            }
        }
        .animation(
            .spring()
            .speed(0.7),
            value: didAppear)
    }
    
    var orForkPromptSection: some View {
        HStack {
            if didAppear {
                orForkPrompt
                    .transition(.offset(y: 1000))
                
                learnMoreButton
                    .transition(.offset(x: 1000))
                
                Spacer()
            }
        }
        .animation(
            .spring()
            .speed(0.7)
            .delay(0.5),
            value: didAppear)
    }
    
    var ctaButtons: some View {
        VStack(spacing: ctaButtonsSpacing) {
            HStack {
                Spacer()
                curatePortfolioButton
            }
            
            HStack {
                Spacer()
                autoGenPortfolioButton
            }
        }
    }
    
    var tosPPPortalSection: some View {
        HStack {
            // Terms of Service
            Button(action: {
                model.termsOfServiceAction()
            }) {
                Text(model.termsOfServicePortalText)
                    .withFont(model.tosPPPortalFont)
                    .fontWeight(.medium)
                    .minimumScaleFactor(0.1)
                    .scaledToFit()
                    .foregroundColor(model.tosPPPortalForegroundColor)
                    .fixedSize()
            }
            .buttonStyle(.genericSpringyShrink)
            
            Text(model.tosPPPortalDivider)
                .withFont(model.tosPPPortalFont)
                .fontWeight(.medium)
                .minimumScaleFactor(0.1)
                .scaledToFit()
                .foregroundColor(model.tosPPPortalForegroundColor)
                .fixedSize()
            
            // Privacy Policy
            Button(action: {
                model.privacyPolicyAction()
            }) {
                Text(model.privacyPolicyPortalText)
                    .withFont(model.tosPPPortalFont)
                    .fontWeight(.medium)
                    .minimumScaleFactor(0.1)
                    .scaledToFit()
                    .foregroundColor(model.tosPPPortalForegroundColor)
                    .fixedSize()
            }
            .buttonStyle(.genericSpringyShrink)
        }
    }
    
    var bottomSection: some View {
        VStack {
            getStartedPromptSection
                .padding(.top,
                         getStartedPromptTopPadding)
            
            ctaButtons
                .padding(.trailing,
                         portfolioActionButtonsTrailingPadding)
            
            orForkPromptSection
                .padding(.leading,
                         learnMorePromptLeadingPadding)
                .padding(.top,
                         learnMorePromptTopPadding)
            
            Spacer()
            
            if didAppear {
                VStack {
                    appNameSignature
                    
                    tosPPPortalSection
                }
                .transition(.push(from: .bottom))
                .padding(.top,
                         tosPPPortalTopPadding)
                .animation(
                    .spring()
                    .speed(0.7),
                    value: didAppear)
            }
        }
        .padding(.leading,
                 bottomSectionLeadingPadding)
    }
    
    var body: some View {
        ZStack {
            sideVerticalDivider
            
            GeometryReader { geom in
                ScrollView {
                    VStack {
                        topSection
                        
                        bottomSection
                    }
                    .frame(minHeight: geom.size.height)
                }
            }
            
            topBar
        }
        .presentationDetents([.height(400)])
        .onAppear {
            didAppear = true
        }
    }
}

struct GetStartedScreen_Previews: PreviewProvider {
    static func getModel() -> GetStartedScreenViewModel {
        return .init(coordinator: .init())
    }
    
    static var previews: some View {
        GetStartedScreen(model: .init(coordinator: .init()))
    }
}
