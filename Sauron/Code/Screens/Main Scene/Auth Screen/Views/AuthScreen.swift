//
//  AuthScreen.swift
//  Sauron
//
//  Created by Justin Cook on 1/17/23.
//

import SwiftUI
import Shimmer

struct AuthScreen: View {
    // MARK: - Observed
    @StateObject var model: AuthScreenViewModel
    
    // MARK: - Dimensions
    private let bottomCTAButtonCornerRadius: CGFloat = 60,
                bottomCTAButtonHeight: CGFloat = 80,
                topSectionVerticalDividerWidth: CGFloat = 3,
                topSectionVerticalDividerHeight: CGFloat = 100
    
    // MARK: - Padding
    private let ospItemSpacing: CGFloat = 20,
                keypadButtonHorizontalSpacing: CGFloat = 40,
                keypadButtonVerticalSpacing: CGFloat = 40,
                bottomCTAButtonHorizontalPadding: CGFloat = 40,
                topSectionTopPadding: CGFloat = 20,
                topSectionVerticalDividerLeadingPadding: CGFloat = 20,
                topSectionVerticalDividerTrailingPadding: CGFloat = 15,
                CounterSectionBottomPadding: CGFloat = 40,
                scrollViewBottomPadding: CGFloat = 100
    
    private var obfuscatedSegmentedPasscodeTopPadding: CGFloat {
        return model.shouldDisplayAuthAttempts || model.shouldDisplayRetryCountDown ? 40 : 60
    }
    
    private var obfuscatedSegmentedPasscodeBottomPadding: CGFloat {
        return model.shouldDisplayAuthAttempts || model.shouldDisplayRetryCountDown ? 30 : 60
    }
    
    var body: some View {
        mainBody
            .animation(.spring(),
                       value: model.shouldDisplayAuthAttempts
                       || model.shouldDisplayRetryCountDown
                       || model.userEnteredIncorrectPasscode)
            .animation(.easeInOut,
                       value: model.passcodeResetInProgress)
            .animation(.easeInOut,
                       value: model.title)
            .animation(.spring(),
                       value: model.passcodeTextEntry)
            .onAppear {
                model.determineAuthVector()
            }
    }
}

// MARK: - View Combinations
extension AuthScreen {
    var mainBody: some View {
        GeometryReader { geom in
            ZStack {
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        topSection
                            .padding(.top, topSectionTopPadding)
                        
                        keypadSection
                    }
                    .padding(.bottom, scrollViewBottomPadding)
                }
                .frame(minWidth: geom.size.width,
                       minHeight: geom.size.height)
                
                VStack(spacing: 0) {
                    Spacer()
                    bottomSection
                }
            }
        }
    }
    
    var topSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                topSectionVerticalDivider
                
                titleView
                
                Spacer()
            }
            .id(model.title)
            .transition(.asymmetric(insertion: .slideForwards,
                                    removal: .slideBackwards))
            
            obfuscatedSegmentedPasscode
                .shimmering(active: model.disableUserEntry,
                            bounce: true)
            
            counterSection
        }
    }
    
    var keypadSection: some View {
        Grid(horizontalSpacing: keypadButtonHorizontalSpacing,
             verticalSpacing: keypadButtonVerticalSpacing) {
            GridRow {
                ForEach(0..<3) {
                    KeypadNumberButton(model: model
                        .keyPadNumberKeys[$0])
                }
            }
            
            GridRow {
                ForEach(3..<6) {
                    KeypadNumberButton(model: model
                        .keyPadNumberKeys[$0])
                }
            }
            
            GridRow {
                ForEach(6..<9) {
                    KeypadNumberButton(model: model
                        .keyPadNumberKeys[$0])
                }
            }
            
            GridRow {
                KeypadUtilityButton(model: model.keyPadUtilityKeys[0])
                
                KeypadNumberButton(model: model
                    .keyPadNumberKeys[9])
                
                KeypadUtilityButton(model: model.keyPadUtilityKeys[1])
            }
        }
    }
    
    var bottomSection: some View {
        VStack(spacing: 0) {
            Spacer()
            
            bottomCTAButton
        }
        .frame(height: bottomCTAButtonHeight)
    }
    
    var counterSection: some View {
        Group {
                if model.shouldDisplayAuthAttempts {
                    attemptsRemainingCounter
                }
                
                if model.shouldDisplayRetryCountDown {
                    retryCountDown
                }
        }
        .transition(.offset(x: -300))
        .withFont(model.counterLabelFont)
        .minimumScaleFactor(0.1)
        .lineLimit(1)
        .multilineTextAlignment(.center)
    }
}

// MARK: - Subviews
extension AuthScreen {
    var titleView: some View {
        Text(model.title)
            .withFont(model.titleFont)
            .foregroundColor(model.titleColor)
            .minimumScaleFactor(0.1)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
    
    var topSectionVerticalDivider: some View {
        StraightSolidDividingLine(color: model.verticalDividerColor,
                                  width: topSectionVerticalDividerWidth,
                                  height: topSectionVerticalDividerHeight)
        
        
        .padding(.leading,
                 topSectionVerticalDividerLeadingPadding)
        .padding(.trailing,
                 topSectionVerticalDividerTrailingPadding)
    }
    
    var retryCountDown: some View {
                Text(model.retryCounterLabelText)
                    .foregroundColor(model.retryCoolDownTextColor)
                    .padding(.bottom,
                             CounterSectionBottomPadding)
    }
    
    var attemptsRemainingCounter: some View {
                Text(model.attemptsRemainingCounterLabelText)
                    .foregroundColor(model.attemptsRemainingTextColor)
                    .padding(.bottom,
                             CounterSectionBottomPadding)
    }
    
    var obfuscatedSegmentedPasscode: some View {
        HStack(alignment: .center,
               spacing: ospItemSpacing) {
            ObfuscatedPasscodeSegment(model: model.obfuscatedPasscodeSegmentModels[0])
            ObfuscatedPasscodeSegment(model: model.obfuscatedPasscodeSegmentModels[1])
            ObfuscatedPasscodeSegment(model: model.obfuscatedPasscodeSegmentModels[2])
            ObfuscatedPasscodeSegment(model: model.obfuscatedPasscodeSegmentModels[3])
        }
               .padding(.top, obfuscatedSegmentedPasscodeTopPadding)
               .padding(.bottom, obfuscatedSegmentedPasscodeBottomPadding)
    }
    
    var bottomCTAButton: some View {
        Button {
            model.bottomCTAButtonPressed()
        } label: {
            ZStack(alignment: .center) {
                Rectangle()
                    .fill(model.bottomCTAButtonBackgroundGradient)
                    .cornerRadius(bottomCTAButtonCornerRadius,
                                  corners: .topLeft)
                    .ignoresSafeArea()
                    .frame(height: bottomCTAButtonHeight)
                
                VStack(spacing: 0) {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Text(model.bottomCTAButtonTitle)
                            .withFont(model.bottomCTAButtonFont)
                            .foregroundColor(model.bottomCTAButtonTextColor)
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal,
                                     bottomCTAButtonHorizontalPadding)
                            .id(model.bottomCTAButtonTitle)
                            .transition(.scale
                                .animation(.spring()))
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
            .ignoresSafeArea()
        }
        .buttonStyle(OffsettableButtonStyle(offset: .init(width: 10,
                                                          height: 0)))
        .opacity(!model.shouldDisableButtons ? 1 : 0.5)
        .disabled(model.shouldDisableButtons)
    }
}

struct AuthScreen_Previews: PreviewProvider {
    static var previews: some View {
        AuthScreen(model: .init(coordinator: .init()))
    }
}
