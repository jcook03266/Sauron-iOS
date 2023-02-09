//
//  CoinChipletView.swift
//  Sauron
//
//  Created by Justin Cook on 2/4/23.
//

import SwiftUI

struct CoinChipletView: View {
    // MARK: - Observed
    @StateObject var model: CoinChipletViewModel
    
    // MARK: - Dimensions
    private let coinImageSize: CGSize = .init(width: 24,
                                              height: 24),
                coinImageContainerSize: CGSize = .init(width: 40,
                                                       height: 40),
                coinImageContainerShadowRadius: CGFloat = 2,
                coinImageContainerShadowOffset: CGSize = .init(width: 0,
                                                               height: 1),
                shadowRadius: CGFloat = 2,
                shadowOffset: CGSize = .init(width: 0,
                                             height: 1),
                priceChangeSignIndicatorSize: CGSize = .init(width: 20,
                                                             height: 20),
                priceChangeSignIndicatorImageSize: CGSize = .init(width: 8,
                                                                  height: 8),
                chipletCornerRadius: CGFloat = 10,
                size: CGSize = .init(width: 100,
                                     height: 80),
                borderLineWidth: CGFloat = 1
    
    // MARK: - Padding + Spacing
    private let coinImageOffset: CGSize = .init(width: -12,
                                                height: 6),
                priceChangeSignIndicatorOffset: CGSize = .init(width: 5,
                                                               height: -7),
                textSafeAreaPadding: CGFloat = 2,
                coinNameTextViewLeadingPadding: CGFloat = 2,
                metaDataLeadingPadding: CGFloat = 8,
                metaDataTopPadding: CGFloat = 5
    
    var body: some View {
        mainBody
    }
}


// MARK: - View Combinations
extension CoinChipletView {
    var mainBody: some View {
        ZStack {
            mainChiplet
        }
    }
    
    var mainChiplet: some View {
        ZStack(alignment: .top) {
            mainChipletBackground
            
            HStack {
                VStack(alignment: .leading,
                       spacing: 0) {
                    
                    HStack(alignment: .center) {
                        coinIDTextView
                        Spacer()
                        percentageChangeTextView
                    }
                    .padding(.top, metaDataTopPadding)
                    
                    priceLabel
                }
                       .padding(.leading,
                                metaDataLeadingPadding)
                       .padding(.trailing,
                                textSafeAreaPadding)
                Spacer()
            }
            
            VStack(alignment: .leading) {
                Spacer()
                
                HStack(alignment: .center, spacing: 0) {
                    coinImageView
                    coinNameTextView
                        .padding(.leading,
                                 coinNameTextViewLeadingPadding)
                    
                    Spacer()
                }
            }
            .offset(x: coinImageOffset.width,
                    y: coinImageOffset.height)
        }
        .frame(width: size.width,
               height: size.height)
        .overlay {
            VStack {
                HStack {
                    Spacer()
                    priceChangeSignIndicator
                }
                
                Spacer()
            }
            .offset(x: priceChangeSignIndicatorOffset.width,
                    y: priceChangeSignIndicatorOffset.height)
        }
    }
}


// MARK: - Subviews
extension CoinChipletView {
    var priceChangeSignIndicator: some View {
        ZStack {
            Group {
                if model.wasPriceChangePositive {
                    Circle()
                        .fill(model.priceChangeSignPositiveIndicatorGradient)
                }
                else {
                    Circle()
                        .fill(model.priceChangeSignNegativeIndicatorColor)
                }
            }
            .shadow(color: model.shadowColor,
                    radius: shadowRadius,
                    x: shadowOffset.width,
                    y: shadowOffset.height)
            .frame(width: priceChangeSignIndicatorSize.width,
                   height: priceChangeSignIndicatorSize.height)
            
            model.priceChangeSignIndicatorArrow
                .fittedResizableTemplateImageModifier()
                .foregroundColor(model.priceChangeSignIndicatorForegroundColor)
                .frame(width: priceChangeSignIndicatorImageSize.width,
                       height: priceChangeSignIndicatorImageSize.height)
        }
    }
    
    var priceLabel: some View {
        Group {
            Text(model.currencySymbol)
            +
            Text(model.trimmedPriceConvertedToCurrency)
        }
        .withFont(model.priceLabelFont)
        .fontWeight(model.priceLabelFontWeight)
        .minimumScaleFactor(0.5)
        .foregroundColor(model.priceLabelFontColor)
        .lineLimit(1)
        .multilineTextAlignment(.center)
        .padding(.all,
                 textSafeAreaPadding)
    }
    
    var percentageChangeTextView: some View {
        Text(model.priceChangePercentageFormattedText)
            .withFont(model.priceChangeFont)
            .fontWeight(model.priceChangeFontWeight)
            .minimumScaleFactor(0.5)
            .foregroundColor(model.priceChangeNegativeColor)
            .if(model.wasPriceChangePositive,
                transform: {
                $0.applyGradient(gradient: model.priceChangePositiveGradient)
            })
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding(.all,
                         textSafeAreaPadding)
                
    }
    
    var coinNameTextView: some View {
        Text(model.coinName)
            .withFont(model.coinNameFont)
            .fontWeight(model.coinNameFontWeight)
            .minimumScaleFactor(0.5)
            .foregroundColor(model.coinNameFontColor)
            .lineLimit(1)
            .multilineTextAlignment(.leading)
            .padding(.all,
                     textSafeAreaPadding)
    }
    
    var coinIDTextView: some View {
        Text(model.coinID)
            .withFont(model.coinIDFont)
            .fontWeight(model.coinIDFontWeight)
            .minimumScaleFactor(0.5)
            .foregroundColor(model.coinIDFontColor)
            .lineLimit(1)
            .multilineTextAlignment(.leading)
            .padding(.all,
                     textSafeAreaPadding)
    }
    
    var mainChipletBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: chipletCornerRadius)
                .stroke(model.borderGradient,
                        lineWidth: borderLineWidth)
            
            RoundedRectangle(cornerRadius: chipletCornerRadius)
                .fill(model.backgroundColor)
                .shadow(color: model.shadowColor,
                        radius: shadowRadius,
                        x: shadowOffset.width,
                        y: shadowOffset.height)
        }
    }
    
    var coinImageView: some View {
        ZStack {
            Circle()
                .fill(model.coinImageContainerBackgroundColor)
                .shadow(color: model.shadowColor,
                        radius: coinImageContainerShadowRadius,
                        x: coinImageContainerShadowOffset.width,
                        y: coinImageContainerShadowOffset.height)
                .overlay {
                    CoinImageView(model: model.coinImageViewModel,
                                  size: coinImageSize)
                }
        }
        .frame(width: coinImageContainerSize.width,
               height: coinImageContainerSize.height)
    }
}

struct CoinChipletView_Previews: PreviewProvider {
    static func getDevEnv() -> DevEnvironment {
        let env = DevEnvironment.shared
        env.parseJSONIntoModel()
        
        return env
    }
    
    static var previews: some View {
        let env = getDevEnv()
        let coin = env.testCoinModel!
        
        CoinChipletView(model: .init(coinModel: coin))
    }
}
