//
//  PCCoinRowView.swift
//  Sauron
//
//  Created by Justin Cook on 12/31/22.
//

import SwiftUI

/// Row that displays general information about the target crypto coin
struct PCCoinRowView: View {
    // MARK: - Observed Objects
    @StateObject var model: PCCoinRowViewModel
    
    // MARK: - States
    @State var didAppear: Bool = false
    
    // MARK: - Dimensions + Padding
    private var imageViewTrailingPadding: CGFloat {
        return DeviceConstants.isDeviceSmallFormFactor() ? 10 : 20
    }
    private var radioButtonTrailingPadding: CGFloat {
        return DeviceConstants.isDeviceSmallFormFactor() ? 20 : 20
    }
  
    private let imageViewDiameter: CGFloat = 50,
                inscribedImageSize: CGSize = .init(width: 30,
                                                   height: 30),
                imageViewLeadingPadding: CGFloat = 0,
                textBackgroundRectangleCornerRadius: CGFloat = 10,
                textBackgroundRectangleBorderWidth: CGFloat = 1,
                textBackgroundRectangleHeight: CGFloat = 50,
                assetIdentifierChipWidth: CGFloat = 110,
                assetPriceChipWidth: CGFloat = 110,
                textBackgroundShadowOffset: CGSize = .init(width: 0, height: 2),
                textBackgroundShadowRadius: CGFloat = 1,
                assetIdentifierChipTrailingPadding: CGFloat = 10,
                assetIdentifierChipLeadingPadding: CGFloat = 0,
                priceChipLeadingPadding: CGFloat = 0,
                priceChipTrailingPadding: CGFloat = 10,
                radioButtonDiameter: CGFloat = 30,
                radioButtonInscribedCircleDiameter: CGFloat = 20,
                radioButtonLeadingPadding: CGFloat = 0,
                radioButtonShadowRadius: CGFloat = 3,
                radioButtonShadowOffset: CGSize = .init(width: 0, height: 1),
                rankLeadingPadding: CGFloat = 10,
                rankTrailingPadding: CGFloat = 5,
rankSize: CGSize = .init(width: 30, height: 30),
                textSidePadding: CGFloat = 10 // To prevent long text from hugging the container
    
    // MARK: - Colors
    private let imageViewBackgroundColor: Color = Colors.permanent_white.0,
                assetIdentifierTextColor: Color = Colors.black.0,
                textBackgroundColor: Color = Colors.white.0,
                textBackgroundBorderGradient: LinearGradient = Colors.gradient_1,
                textBackgroundShadowColor: Color = Colors.shadow_1.0,
                assetIdentifierTextGradient: LinearGradient = Colors.gradient_1,
                assetPriceTextColor: Color = Colors.neutral_700.0,
                currencySymbolTextColor: Color = Colors.black.0,
                radioButtonBackgroundGradient: LinearGradient = Colors.gradient_1,
                radioButtonShadowColor: Color = Colors.shadow_2.0,
radioButtonBackgroundFillGradient: LinearGradient = Colors.gradient_1,
                radioButtonBackgroundFillColor: Color = Colors.white.0,
                rankTextColor: Color = Colors.neutral_600.0
    
    // MARK: - Subviews
    var imageView: some View {
        Circle()
            .overlay {
                CoinImageView(model: model.coinImageViewModel,
                              size: inscribedImageSize)
            }
            .foregroundColor(imageViewBackgroundColor)
            .frame(width: imageViewDiameter)
            .padding(.trailing, imageViewTrailingPadding)
            .padding(.leading, imageViewLeadingPadding)
    }
    
    var marketCapRankView: some View {
        Text(model.assetMarketCapRank)
            .foregroundColor(rankTextColor)
            .withFont(model.rankTextFont)
            .fontWeight(model.rankTextFontWeight)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .multilineTextAlignment(.center)
            .padding(.leading, rankLeadingPadding)
            .padding(.trailing, rankTrailingPadding)
            .frame(width: rankSize.width,
                   height: rankSize.height)
            .fixedSize()
    }
    
    var radioButton: some View {
        Button(action: {
            model.selectedAction()
        }) {
            Circle()
                .fill(radioButtonBackgroundGradient)
                .overlay {
                    Group {
                        if model.isSelected {
                            Circle()
                                .fill(radioButtonBackgroundFillGradient)
                                .transition(.scale)
                        }
                        else {
                            Circle()
                                .fill(radioButtonBackgroundFillColor)
                                .transition(.scale)
                        }
                    }
                    .frame(width: radioButtonInscribedCircleDiameter)
                }
                .frame(width: radioButtonDiameter)
                .shadow(color: radioButtonShadowColor,
                        radius: radioButtonShadowRadius,
                        x: radioButtonShadowOffset.width,
                        y: radioButtonShadowOffset.height)
                .animation(.spring(),
                           value: model.isSelected)
                .padding(.leading, radioButtonLeadingPadding)
                .padding(.trailing, radioButtonTrailingPadding)
        }
        .buttonStyle(.genericSpringyShrink)
    }
    
    /// Reflects the current identifier for the asset (symbol or name)
    var assetIdentifierChip: some View {
        Text(model.assetIdentifier)
            .foregroundColor(assetIdentifierTextColor)
            .withFont(model.assetIdentifierTextFont)
            .fontWeight(model.assetIdentifierTextFontWeight)
            .lineLimit(2)
            .minimumScaleFactor(0.1)
            .multilineTextAlignment(.center)
            .padding([.leading, .trailing], textSidePadding)
            .padding([.top, .bottom],
                     textSidePadding/2)
            .background {
                gradientBorderedRectangularBackground
                    .frame(width: assetIdentifierChipWidth)
            }
            .frame(width: assetIdentifierChipWidth,
                   height: textBackgroundRectangleHeight)
            .padding(.trailing, assetIdentifierChipTrailingPadding)
            .id(model.assetIdentifier) /// Treats each id as a new view thus enabling transitions
            .transition(.scale.animation(.spring()))
    }
    
    /// Reflects the latest price for the asset using the currently selected currency preference
    var assetPriceChip: some View {
        Group {
            Text(model.currencySymbol)
                .foregroundColor(currencySymbolTextColor)
            +
            Text(model.trimmedPriceConvertedToCurrency)
        }
        .foregroundColor(assetPriceTextColor)
        .withFont(model.assetPriceTextFont)
        .fontWeight(model.assetPriceTextFontWeight)
        .lineLimit(1)
        .minimumScaleFactor(0.1)
        .multilineTextAlignment(.center)
        .padding([.leading, .trailing], textSidePadding)
        .background {
            gradientBorderedRectangularBackground
                .frame(width: assetPriceChipWidth)
        }
        .frame(width: assetPriceChipWidth,
               height: textBackgroundRectangleHeight)
    }
    
    var gradientBorderedRectangularBackground: some View {
        RoundedRectangle(cornerRadius: textBackgroundRectangleCornerRadius)
            .stroke(
                textBackgroundBorderGradient,
                lineWidth: textBackgroundRectangleBorderWidth)
            .overlay {
                RoundedRectangle(cornerRadius: textBackgroundRectangleCornerRadius)
                    .fill(textBackgroundColor)
            }
            .shadow(color: textBackgroundShadowColor,
                    radius: textBackgroundShadowRadius,
                    x: textBackgroundShadowOffset.width,
                    y: textBackgroundShadowOffset.height)
            .frame(height: textBackgroundRectangleHeight)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            marketCapRankView
            
            radioButton
            
            imageView
            
            Spacer()
            
            assetIdentifierChip
            
            Spacer()
            
            assetPriceChip
        }
        .onTapGesture {
            model.selectedAction()
        }
    }
}

struct PCCoinRowView_Previews: PreviewProvider {
    static func getDevEnv() -> DevEnvironment {
        let env = DevEnvironment.shared
        env.parseJSONIntoModel()
        
        return env
    }
    
    static var previews: some View {
        let env = getDevEnv()
        let coin = env.testCoinModel!
        
        PCCoinRowView(model: .init(parentViewModel:
                .init(coordinator: .init()),
                                   coinModel: coin))
    }
}
