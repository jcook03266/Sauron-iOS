//
//  CoinListInformationView.swift
//  Sauron
//
//  Created by Justin Cook on 1/30/23.
//

import SwiftUI

struct CoinListInformationView: View {
    // MARK: - Observed
    @StateObject var model: CoinListInformationViewModel
    
    // MARK: - Dimensions
    private let coinImageSize: CGSize = .init(width: 30,
                                              height: 30),
                coinImageBorderWidth: CGFloat = 2,
                coinImageContainerSize: CGSize = .init(width: 50,
                                                       height: 50),
                coinImageContainerCornerRadius: CGFloat = 10,
                coinImageContainerShadowRadius: CGFloat = 4,
                coinImageContainerShadowOffset: CGSize = .init(width: 0,
                                                               height: 4),
                graphCornerRadius: CGFloat = 10,
                chartSize: CGSize = .init(width: 100,
                                          height: 50),
                chartBorderWidth: CGFloat = 1,
                chartShadowRadius: CGFloat = 2,
                chartShadowOffset: CGSize = .init(width: 0,
                                                  height: 2),
                percentageChangeChipCornerRadius: CGFloat = 10,
                percentageChangeChipSize: CGSize = .init(width: 70,
                                                         height: 20),
                chipletShadowRadius: CGFloat = 2,
                chipletShadowOffset: CGSize = .init(width: 0,
                                                    height: 2),
                priceLabelSize: CGSize = .init(width: 90, height: 25),
                priceLabelCornerRadius: CGFloat = 20,
                priceChangeSignIndicatorSize: CGSize = .init(width: 20,
                                                             height: 20),
                priceChangeSignIndicatorImageSize: CGSize = .init(width: 8,
                                                                  height: 8),
                metaDataInformationSectionCornerRadius: CGFloat = 10,
                metaDataInformationSectionSize: CGSize = .init(width: 150,
                                                               height: 50),
                metaDataInformationSectionBorderWidth: CGFloat = 2,
                dividerWidth: CGFloat = 1
    
    // MARK: - Padding + Spacing
    private let mainBodyItemSpacing: CGFloat = 5,
                chipletPadding: CGFloat = 1,
                priceInformationSectionVerticalItemSpacing: CGFloat = 5,
                priceInformationSectionHorizontalItemSpacing: CGFloat = 2,
                metaDataInformationSectionHorizontalItemSpacing: CGFloat = 10,
                dividerVerticalPadding: CGFloat = 4.5
    
    var body: some View {
        mainBody
    }
}

// MARK: - View Combinations
extension CoinListInformationView {
    var mainBody: some View {
        HStack(spacing: mainBodyItemSpacing) {
            metaDataInformationSection
            graphSection
            priceInformationSection
        }
    }
    
    var metaDataInformationSection: some View {
        ZStack(alignment: .leading) {
            Group {
                if model.isCoinInUserPortfolio {
                    RoundedRectangle(cornerRadius: metaDataInformationSectionCornerRadius)
                        .stroke(model.metaDataInformationSectionBorderGradient,
                                lineWidth: metaDataInformationSectionBorderWidth)
                }
                
                RoundedRectangle(cornerRadius: metaDataInformationSectionCornerRadius)
                    .fill(model.metaDataInformationSectionBackgroundColor)
                    .shadow(color: model.shadowColor,
                            radius: chipletShadowRadius,
                            x: chipletShadowOffset.width,
                            y: chipletShadowOffset.height)
            }
            
            HStack(spacing: metaDataInformationSectionHorizontalItemSpacing) {
                coinImageView
                
                divider
                
                VStack(alignment: .leading,
                       spacing: 0) {
                    coinNameTextView
                        .padding(.top, chipletPadding)
                    
                    coinIDTextView
                        .padding(.bottom, chipletPadding)
                }
                       .padding(.trailing,
                                10)
            }
        }
        .frame(width: metaDataInformationSectionSize.width,
               height: metaDataInformationSectionSize.height)
    }
    
    var graphSection: some View {
        ZStack {
            chartView
        }
        .frame(width: chartSize.width,
               height: chartSize.height)
        .shadow(color: model.shadowColor,
                radius: chartShadowRadius,
                x: chartShadowOffset.width,
                y: chartShadowOffset.height)
    }
    
    var priceInformationSection: some View {
        VStack(alignment: .leading,
               spacing: priceInformationSectionVerticalItemSpacing) {
            priceLabel
            
            HStack(spacing: priceInformationSectionHorizontalItemSpacing) {
                percentageChangeChip
                priceChangeSignIndicator
            }
        }
    }
}

// MARK: - Subviews
extension CoinListInformationView {
    var divider: some View {
        GeometryReader { geom in
            Path { path in
                path.move(to: .zero)
                path.addLine(to: .init(x: 0, y: geom.size.height))
            }
            .stroke(model.dashedDividerLineColor,
                    style: .init(lineWidth: dividerWidth,
                                 lineCap: .round,
                                 lineJoin: .round,
                                 dash: [2]))
        }
        .frame(width: dividerWidth)
        .padding(.vertical,
                 dividerVerticalPadding)
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
    
    var coinNameTextView: some View {
        Text(model.coinName)
            .withFont(model.coinNameFont)
            .fontWeight(model.coinNameFontWeight)
            .minimumScaleFactor(0.6)
            .foregroundColor(model.coinNameFontColor)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
    
    var coinIDTextView: some View {
        Text(model.coinIDText)
            .withFont(model.coinIDFont)
            .fontWeight(model.coinIDFontWeight)
            .minimumScaleFactor(0.5)
            .foregroundColor(model.coinIDFontColor)
            .lineLimit(1)
            .multilineTextAlignment(.leading)
    }
    
    var chartView: some View {
        MiniHistoricalChartView(model: model.miniChartViewModel,
                                size: chartSize,
                                verticalPadding: 15,
                                useBackground: false,
                                animationsEnabled: false,
                                glowEnabled: true)
        .cornerRadius(graphCornerRadius,
                      corners: .allCorners)
    }
    
    var priceChangeSignIndicator: some View {
        ZStack {
            Circle()
                .fill(model.priceChangeSignIndicatorBackgroundColor)
                .shadow(color: model.shadowColor,
                        radius: chipletShadowRadius,
                        x: chipletShadowOffset.width,
                        y: chipletShadowOffset.height)
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
            RoundedRectangle(cornerRadius: percentageChangeChipCornerRadius)
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
}

struct CoinListInformationView_Previews: PreviewProvider {
    static func getDevEnv() -> DevEnvironment {
        let env = DevEnvironment.shared
        env.parseJSONIntoModel()
        
        return env
    }
    
    static var previews: some View {
        let env = getDevEnv()
        let coin = env.testCoinModel!
        
        CoinListInformationView(model: .init(coinModel: coin))
    }
}
