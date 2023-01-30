//
//  CoinGridInformationView.swift
//  Sauron
//
//  Created by Justin Cook on 1/29/23.
//

import SwiftUI

struct CoinGridInformationView: View {
    // MARK: - Observed
    @StateObject var model: CoinGridInformationViewModel
    
    // MARK: - Dimensions
    var size: CGSize = .init(width: 200,
                             height: 170)
    
    private let coinImageSize: CGSize = .init(width: 18,
                                              height: 18),
                coinImageBorderWidth: CGFloat = 5,
                coinImageContainerSize: CGSize = .init(width: 30,
                                                       height: 30),
                coinImageContainerCornerRadius: CGFloat = 10,
                coinImageContainerShadowRadius: CGFloat = 4,
                coinImageContainerShadowOffset: CGSize = .init(width: 0,
                                                               height: 4),
                timeScaleSelectorButtonSize: CGSize = .init(width: 50,
                                                            height: 20),
                graphCornerRadius: CGFloat = 10,
                chartSize: CGSize = .init(width: 175,
                                          height: 125),
                chartBorderWidth: CGFloat = 1,
                chartBorderCornerRadius: CGFloat = 10,
                chartShadowRadius: CGFloat = 2,
                chartShadowOffset: CGSize = .init(width: 0,
                                                  height: 2),
                coinIDTextViewCornerRadius: CGFloat = 5,
                coinIDTextViewSize: CGSize = .init(width: 50,
                                                   height: 30),
                percentageChangeChipCornerRadius: CGFloat = 5,
                percentageChangeChipSize: CGSize = .init(width: 70,
                                                         height: 30),
                chipletShadowRadius: CGFloat = 2,
                chipletShadowOffset: CGSize = .init(width: 0,
                                                    height: 2),
                coinNameTextViewWidth: CGFloat = 110,
                priceLabelCornerRadius: CGFloat = 5,
                priceLabelSize: CGSize = .init(width: 90, height: 25)
    
    // MARK: - Padding + Spacing
    private let bottomSectionHorizontalPadding: CGFloat = 5,
                bottomSectionTopPadding: CGFloat = 10,
                coinNameBottomPadding: CGFloat = 5,
                chipletSectionTopPadding: CGFloat = 2,
                chipletSectionItemSpacing: CGFloat = 5,
                chipletPadding: CGFloat = 2.5
    
    var body: some View {
        mainBody
            .animation(.spring(),
                       value: model.selectedTimeScale)
    }
}

// MARK: - View Combinations
extension CoinGridInformationView {
    var mainBody: some View {
        VStack(spacing: 0) {
            midSection
            bottomSection
        }
        .frame(width: size.width,
               height: size.height)
    }
    
    var midSection: some View {
        ZStack {
            chartView
            chipletSection
        }
    }
    
    var chipletSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: chipletSectionItemSpacing) {
                coinIDTextView
                percentageChangeChip
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                priceLabel
            }
        }
        .padding(.top,
                 chipletSectionTopPadding)
    }
    
    var bottomSection: some View {
        HStack(spacing: bottomSectionHorizontalPadding) {
            coinImageView
            
            VStack(alignment: .leading,
                   spacing: 0) {
                coinNameTextView
                pageBarView
            }
            
            timeScaleSelectorButton
        }
        .padding(.top,
                 bottomSectionTopPadding)
    }
}

// MARK: - Subviews
extension CoinGridInformationView {
    var chartView: some View {
        ZStack {
            HStack(spacing: 0) {
                Spacer()
                
                graphSupplementaryBackgroundView
            }
            
            HStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: chartBorderCornerRadius)
                        .stroke(model.graphBorderGradient,
                                lineWidth: chartBorderWidth)
                    
                    MiniHistoricalChartView(model: model.miniChartViewModel,
                                            size: chartSize,
                                            verticalPadding: 40,
                                            animationsEnabled: false,
                                            glowEnabled: true)
                    .cornerRadius(chartBorderCornerRadius,
                                  corners: .allCorners)
                }
                .frame(width: chartSize.width,
                       height: chartSize.height)
                .id(model.selectedTimeScale)
                .transition(.scale
                    .animation(.spring()))
                
                Spacer()
            }
        }
        .shadow(color: model.shadowColor,
                radius: chartShadowRadius,
                x: chartShadowOffset.width,
                y: chartShadowOffset.height)
    }
    
    var priceLabel: some View {
        ZStack {
            RoundedRectangle(cornerRadius: priceLabelCornerRadius)
                .fill(model.priceLabelBackgroundColor)
                .shadow(color: model.shadowColor,
                        radius: chipletShadowRadius,
                        x: chipletShadowOffset.width,
                        y: chipletShadowOffset.height)
            
            
            Group {
                Text(model.currencySymbol)
                    .foregroundColor(model.priceLabelCurrencySymbolFontColor)
                +
                Text(model.trimmedPriceConvertedToCurrency)
            }
            .withFont(model.priceLabelFont)
            .fontWeight(model.priceLabelFontWeight)
            .minimumScaleFactor(0.5)
            .foregroundColor(model.priceLabelNumericalFontColor)
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .padding(.all,
                     chipletPadding)
        }
        .frame(width: priceLabelSize.width,
               height: priceLabelSize.height)
    }
    
    var percentageChangeChip: some View {
        ZStack {
            Rectangle()
                .cornerRadius(coinIDTextViewCornerRadius,
                              corners: [.bottomLeft, .bottomRight])
                .foregroundColor(model.percentageChangeChipBackgroundColor)
                .shadow(color: model.shadowColor,
                        radius: chipletShadowRadius,
                        x: chipletShadowOffset.width,
                        y: chipletShadowOffset.height)
            
            Text(model.priceChangePercentageFormattedText)
                .withFont(model.percentageChangeChipFont)
                .fontWeight(model.percentageChangeChipFontWeight)
                .minimumScaleFactor(0.5)
                .foregroundColor(model.percentageChangeChipFontColor)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding(.all,
                         chipletPadding)
        }
        .frame(width: percentageChangeChipSize.width,
               height: percentageChangeChipSize.height)
    }
    
    var coinIDTextView: some View {
        ZStack {
            Rectangle()
                .cornerRadius(coinIDTextViewCornerRadius,
                              corners: [.bottomRight, .topRight, .topLeft])
                .foregroundColor(model.coinIDBackgroundColor)
                .shadow(color: model.shadowColor,
                        radius: chipletShadowRadius,
                        x: chipletShadowOffset.width,
                        y: chipletShadowOffset.height)
            
            Text(model.coinID)
                .withFont(model.coinIDFont)
                .fontWeight(model.coinIDFontWeight)
                .minimumScaleFactor(0.5)
                .foregroundColor(model.coinIDFontColor)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding(.all,
                         chipletPadding)
        }
        .frame(width: coinIDTextViewSize.width,
               height: coinIDTextViewSize.height)
    }
    
    var graphSupplementaryBackgroundView: some View {
        RoundedRectangle(cornerRadius: graphCornerRadius)
            .fill(model.graphSupplementaryBackgroundViewColor)
            .frame(height: chartSize.height)
    }
    
    var timeScaleSelectorButton: some View {
        StrongRectangularCTA(action: model.timeScaleSelectorButtonAction,
                             backgroundColor: model.timeScaleSelectorButtonBackgroundColor,
                             foregroundColor: model.timeScaleSelectorButtonFontColor,
                             shadowColor: model.shadowColor,
                             font: model.timeScaleSelectorButtonFont,
                             size: timeScaleSelectorButtonSize,
                             message: (model.selectedTimeScaleStringLiteral, nil))
    }
    
    var coinNameTextView: some View {
        HStack(spacing: 0) {
            Text(model.coinName)
                .withFont(model.coinNameFont)
                .fontWeight(model.coinNameFontWeight)
                .minimumScaleFactor(0.5)
                .foregroundColor(model.coinNameFontColor)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .padding(.bottom,
                         coinNameBottomPadding)
            
            Spacer()
        }
        .frame(width: coinNameTextViewWidth)
    }
    
    var coinImageView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: coinImageContainerCornerRadius)
                .stroke(model.coinImageContainerBorderGradient,
                        lineWidth: coinImageBorderWidth)
            
            RoundedRectangle(cornerRadius: coinImageContainerCornerRadius)
                .fill(model.coinImageContainerBackgroundColor)
                .overlay {
                    CoinImageView(model: model.coinImageViewModel,
                                  size: coinImageSize)
                }
        }
        .shadow(color: model.shadowColor,
                radius: coinImageContainerShadowRadius,
                x: coinImageContainerShadowOffset.width,
                y: coinImageContainerShadowOffset.height)
        .frame(width: coinImageContainerSize.width,
               height: coinImageContainerSize.height)
    }
    
    var pageBarView: some View {
        PageBarView(model: model.pageBarViewModel)
    }
}

struct CoinGridInformationView_Previews: PreviewProvider {
    static func getDevEnv() -> DevEnvironment {
        let env = DevEnvironment.shared
        env.parseJSONIntoModel()
        
        return env
    }
    
    static var previews: some View {
        let env = getDevEnv()
        let coin = env.testCoinModel!
        
        CoinGridInformationView(model: .init(coinModel: coin))
    }
}
