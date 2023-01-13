//
//  PortfolioCurationView.swift
//  Sauron
//
//  Created by Justin Cook on 12/29/22.
//

import SwiftUI

struct PortfolioCurationView: View {
    // MARK: - Observed
    @StateObject var model: PortfolioCurationViewModel
    
    // MARK: - States
    @State var didAppear: Bool = false
    @State var displayBottomSection: Bool = true
    @State var scrollViewContentOffset: CGPoint = .zero
    @State var lastScrollViewContentOffset: CGPoint = .zero
    
    // MARK: - Dimensions + Padding
    private let backButtonTrailingPadding: CGFloat = 20,
                backButtonLeadingPadding: CGFloat = 7,
                bottomSectionToggleButtonTrailingPadding: CGFloat = 10,
                bottomSectionToggleButtonBottomPadding: CGFloat = 10,
                titleViewLeadingPadding: CGFloat = 90,
                titleViewTrailingPadding: CGFloat = 20,
                titleViewHeight: CGFloat = 100,
                sideVerticalDividerWidth: CGFloat = 3,
                sideVerticalDividerLeadingPadding: CGFloat = 35,
                searchBarTopPadding: CGFloat = 20,
                searchBarBottomPadding: CGFloat = 10,
                searchBarLeadingPadding: CGFloat = 12,
                assetPropertiesHeaderHeight: CGFloat = 35,
                assetPropertiesHeaderDividerWidth: CGFloat = 2,
                assetPropertiesHeaderLeadingPadding: CGFloat = 60,
                assetPropertiesHeaderTopPadding: CGFloat = 5,
                assetPropertiesHeaderTrailingPadding: CGFloat = 10,
                assetsListViewItemSpacing: CGFloat = 10,
                assetsListViewTopPadding: CGFloat = 10,
                assetsListViewTrailingPadding: CGFloat = 5,
                assetsListScrollViewVerticalPadding: CGFloat = 25,
                scrollViewBottomPadding: CGFloat = 200,
                assetSymbolContainerBorderWidth: CGFloat = 1,
                assetSymbolContainerWidth: CGFloat = 75,
                assetSymbolContainerLeadingPadding: CGFloat = 60,
                assetSymbolContainerBottomPadding: CGFloat = -15,
                assetSymbolContainerCornerRadius: CGFloat = 10,
                infoSectionLeadingPadding: CGFloat = 10,
                infoSectionTrailingPadding: CGFloat = 40,
                infoSectionTopPadding: CGFloat = 10,
                continueCTAButtonLeadingPadding: CGFloat = 10,
                continueCTAButtonSize: CGSize = .init(width: 260,
                                                      height: 60),
                preferenceChipletButtonSize: CGSize = .init(width: 200,
                                                            height: 40),
                preferenceChipletButtonContainerPadding: CGFloat = 5,
                preferenceChipletButtonShadowOffset: CGSize = .init(width: 0,
                                                                    height: 1),
                preferenceChipletButtonBorderWidth: CGFloat = 1,
                preferenceChipletButtonShadowRadius: CGFloat = 4,
                preferenceChipletButtonCornerRadius: CGFloat = 10,
                preferenceButtonsInsetPadding: CGFloat = 10,
                preferenceButtonsItemSpacing: CGFloat = 10,
                bottomSectionBackgroundTopPadding: CGFloat = -15,
                bottomSectionBackgroundBottomPadding: CGFloat = -60,
                bottomSectionCornerRadius: CGFloat = 30,
                bottomSectionShadowOffset: CGSize = .init(width: 0,
                                                          height: -2),
                bottomSectionShadowRadius: CGFloat = 2,
                bottomSectionHideVerticalOffset: CGFloat = 400,
                contextPropertiesHeaderBorderWidth: CGFloat = 1,
                contextPropertiesHeaderVerticalPadding: CGFloat = 10,
                contextPropertiesHeaderHorizontalPadding: CGFloat = 10,
                contextPropertiesHeaderSize: CGSize = CGSize(width: 160, height: 40),
                noSearchResultsTextLeadingPadding: CGFloat = 30,
                noSearchResultsTextTrailingPadding: CGFloat = 40,
                sortButtonIconSize: CGSize = .init(width: 30,
                                                   height: 30),
                sortButtonLeadingPadding: CGFloat = 10
    
    var assetsListViewLeadingPadding: CGFloat {
        return DeviceConstants.isDeviceSmallFormFactor() ? 0 : -8
    }
    
    var contextPropertiesHeaderChipSize: CGSize {
        return CGSize(width: contextPropertiesHeaderSize.width/2,
                      height: contextPropertiesHeaderSize.height)
    }
    
    private var preferenceButtonsBottomPadding: CGFloat {
        return -(bottomSectionBackgroundTopPadding) + 5
    }
    
    // MARK: - Subviews
    var selectedCoinsCounterView: some View {
        Text("")
    }
    
    var searchResultsCounterView: some View {
        Text("")
    }
    
    var titleView: some View {
        Text(model.title)
            .withFont(model.titleFont)
            .multilineTextAlignment(.leading)
            .fontWeight(model.titleFontWeight)
            .applyGradient(gradient: model.titleGradient)
            .lineLimit(2)
            .minimumScaleFactor(0.1)
            .frame(height: titleViewHeight)
            .padding(.trailing, titleViewTrailingPadding)
            .padding(.leading, titleViewLeadingPadding)
    }
    
    var backButton: some View {
        ArrowButton(action: {
            model.goBackAction()
        },
                    backgroundColor: model.backButtonBackgroundColor,
                    arrowDirection: .left,
                    buttonType: .skip,
                    isEnabled: .constant(true))
        .padding(.leading, backButtonLeadingPadding)
        .padding(.trailing, backButtonTrailingPadding)
    }
    
    var bottomSectionToggleButton: some View {
        ArrowButton(action: {
            HapticFeedbackDispatcher.genericButtonPress()
            toggleBottomSection()
        },
                    backgroundColor: model.backButtonBackgroundColor,
                    arrowDirection: displayBottomSection ? .down : .up,
                    buttonType: .next,
                    isEnabled: .constant(true))
        .padding(.trailing, bottomSectionToggleButtonTrailingPadding)
        .padding(.bottom, bottomSectionToggleButtonBottomPadding)
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
    
    var searchBar: some View {
        SatelliteTextField(model: model.searchBarTextFieldModel)
            .padding(.top, searchBarTopPadding)
            .padding(.bottom, searchBarBottomPadding)
            .padding(.leading, searchBarLeadingPadding)
    }
    
    var contextPropertiesHeaderView: some View {
        HStack {
            Spacer()
            Group {
                // Search Results Counter
                if model.isSearchBarActive && model.isUserSearching {
                    CounterRectangularButton(font: model.contextPropertiesHeaderFont,
                                             fontWeight: model.contextPropertiesHeaderFontWeight,
                                             borderGradient: model.contextPropertiesHeaderMessageBorderGradient,
                                             backgroundColor: model.contextPropertiesHeaderBackgroundColor,
                                             messageTextColor: model.contextPropertiesHeaderMessageTextColor,
                                             counterTextGradient: model.contextPropertiesHeaderCounterTextGradient,
                                             action: {},
                                             message: (model.searchResultsCounter, nil),
                                             borderEnabled: true,
                                             counter: UInt(model.searchResultsCount),
                                             hideCounterWhenItReaches: 0,
                                             isSelected: false)
                }
                
                // Coin Counter
                if model.userHasSelectedCoins {
                    CounterRectangularButton(font: model.contextPropertiesHeaderFont,
                                             fontWeight: model.contextPropertiesHeaderFontWeight,
                                             borderGradient: model.contextPropertiesHeaderMessageBorderGradient,
                                             backgroundColor: model.contextPropertiesHeaderBackgroundColor,
                                             messageTextColor: model.contextPropertiesHeaderMessageTextColor,
                                             counterTextGradient: model.contextPropertiesHeaderCounterTextGradient,
                                             action: model.toggleFilterPortfolioCoins,
                                             message: (model.coinSelectionCounter, nil),
                                             borderEnabled: true,
                                             counter: UInt(model.portfolioCoins.count),
                                             hideCounterWhenItReaches: 0,
                                             isSelected: model.filterPortfolioCoins)
                }
            }
            .padding([.bottom], contextPropertiesHeaderVerticalPadding)
            .transition(.scale
                .animation(.spring()))
        }
        .padding([.leading, .trailing], contextPropertiesHeaderHorizontalPadding)
    }
    
    var assetPropertiesHeaderDivider: some View {
        GeometryReader { geom in
            StraightSolidDividingLine(width: assetPropertiesHeaderDividerWidth,
                                      height: geom.size.height,
                                      gradient: model.verticalDividerGradient)
        }
        .frame(width: assetPropertiesHeaderDividerWidth)
    }
    
    var assetPropertiesHeader: some View {
        HStack {
            Spacer()
            
            HStack(alignment: .center, spacing: 0) {
                // Symbol Header
                Group {
                    Text(model.symbolHeader)
                    
                    Spacer()
                    
                    assetPropertiesHeaderDivider
                    
                    Spacer()
                }
                
                // Asset Identifier Header
                Group {
                    Button(action: {
                        model.assetIdentifierHeaderTappedAction()
                    }) {
                        Text(model.assetIdentifierHeader)
                    }
                    .id(model.assetIdentifierDisplayType.hashValue)
                    .transition(.scale.animation(.spring()))
                    .buttonStyle(.offsettableButtonStyle)
                }
                
                // Latest Price Header
                Group {
                    Spacer()
                    
                    assetPropertiesHeaderDivider
                    
                    Spacer()
                    
                    Text(model.priceHeader)
                }
            }
            .withFont(model.assetPropertiesHeaderFont)
            .fontWeight(model.assetPropertiesHeaderFontWeight)
            .multilineTextAlignment(.leading)
            .foregroundColor(model.assetPropertiesHeaderTextColor)
            .lineLimit(2)
            .minimumScaleFactor(0.1)
            .frame(height: assetPropertiesHeaderHeight)
            
            Spacer()
        }
        .padding(.leading, assetPropertiesHeaderLeadingPadding)
        .padding(.top, assetPropertiesHeaderTopPadding)
        .padding(.trailing, assetPropertiesHeaderTrailingPadding)
        .animation(.spring(), value:
                    model.assetIdentifierDisplayType)
    }
    
    var sortCoinsButton: some View {
        GeometryReader { geom in
            Button {
                model.sortButtonPressedAction()
            } label: {
                model.sortButtonIcon
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .applyGradient(gradient: model.sortButtonGradient)
                    .frame(width: sortButtonIconSize.width,
                           height: sortButtonIconSize.height)
            }
            .preference(key: PositionPreferenceKey.self,
                        value: CGPoint(x: geom.frame(in: .global).minX,
                                       y: geom.frame(in: .global).maxY))
            .buttonStyle(.genericSpringyShrink)
            .padding(.leading, sortButtonLeadingPadding)
        }
        .onPreferenceChange(PositionPreferenceKey.self) { preferences in
            model.anchorContextMenuTo(anchor: preferences)
        }
        .frame(width: sortButtonIconSize.width,
               height: sortButtonIconSize.height)
    }
    
    var noSearchResultsTextView: some View {
        Text(model.noSearchResultsText)
            .withFont(model.noSearchResultsTextFont)
            .fontWeight(model.noSearchResultsTextFontWeight)
            .applyGradient(gradient: model.noSearchResultsTextGradient)
            .minimumScaleFactor(0.1)
            .multilineTextAlignment(.leading)
            .lineLimit(2)
            .padding(.leading, noSearchResultsTextLeadingPadding)
            .padding(.trailing, noSearchResultsTextTrailingPadding)
            .transition(.offset(x: 500))
    }
    
    /// Displayed when no data is available
    var placeholderListView: some View {
        ForEach(model.placeholderViewRange, id: \.self) { _ in
            if let placeholderCoinData = model.placeholderCoinData {
                PCCoinRowView(model: .init(parentViewModel: model,
                                           coinModel: placeholderCoinData))
                .redacted(reason: .placeholder)
                .shimmering(bounce: true)
            }
        }
    }
    
    var assetsListView: some View {
        VStack {
            assetPropertiesHeader
            
            LazyVStack(spacing: assetsListViewItemSpacing) {
                if !model.isCoinsEmpty {
                    ForEach(model.coins) {
                        PCCoinRowView(model: .init(parentViewModel: model,
                                                   coinModel: $0,
                                                   isSelected: model.doesCoinExistInPortfolio(coin: $0)))
                        
                        .id($0.hashValue)
                        .transition(.slideBackwards)
                    }
                    .animation(.spring(),
                               value: model.isReloading)
                }
                else if model.shouldDisplayNoSearchResultsText {
                    noSearchResultsTextView
                }
                else {
                    placeholderListView
                        .transition(.slideForwards)
                }
            }
            .animation(.spring(),
                       value: model.coins.count)
            .padding(.top, assetsListViewTopPadding)
            .padding(.leading, assetsListViewLeadingPadding)
            .padding(.trailing, assetsListViewTrailingPadding)
            .background(
                model.shouldDisplayNoSearchResultsText ? nil : assetSymbolContainer
            )
            .scaledToFill()
        }
        .padding(.bottom, assetsListScrollViewVerticalPadding)
    }
    
    var assetSymbolContainer: some View {
        HStack {
            RoundedRectangle(cornerRadius: assetSymbolContainerCornerRadius)
                .stroke(model.assetSymbolContainerBorderGradient,
                        lineWidth: assetSymbolContainerBorderWidth)
                .overlay {
                    RoundedRectangle(cornerRadius: assetSymbolContainerCornerRadius)
                        .fill(model.assetSymbolContainerBackgroundGradient)
                }
                .frame(width: assetSymbolContainerWidth)
                .fixedSize(horizontal: true,
                           vertical: false)
                .padding(.bottom, assetSymbolContainerBottomPadding)
            
            Spacer()
        }
        .padding(.leading, assetSymbolContainerLeadingPadding)
        .animation(.spring(response: 0.4, dampingFraction: 1),
                   value: model.coins.count)
    }
    
    var preferenceButtons: some View {
        ScrollView(.horizontal,
                   showsIndicators: false)
        {
            // Currency Preference Button
            HStack(spacing: preferenceButtonsItemSpacing) {
                preferenceButton(action: model.currencyPreferenceAction,
                                 title: (nil,
                                         model.currencyPreferencesButtonText),
                                 cornerRadius: preferenceChipletButtonCornerRadius,
                                 borderGradient: model.currencyPreferencesChipletBorderGradient,
                                 borderWidth: preferenceChipletButtonBorderWidth,
                                 backgroundColor: model.preferencesChipletBackgroundColor,
                                 shadowColor: model.shadowColor,
                                 shadowRadius: preferenceChipletButtonShadowRadius,
                                 shadowOffset: preferenceChipletButtonShadowOffset,
                                 containerPadding: preferenceChipletButtonContainerPadding,
                                 size: preferenceChipletButtonSize,
                                 textColor: model.preferencesChipletTextColor,
                                 fontWeight: model.preferencesChipletFontWeight,
                                 font: model.preferencesChipletFont)
                
                // Language Preference Button
                preferenceButton(action: model.languagePreferenceAction,
                                 title: (nil,
                                         model.languagePreferencesButtonText),
                                 cornerRadius: preferenceChipletButtonCornerRadius,
                                 borderGradient: model.languagesPreferencesChipletBorderGradient,
                                 borderWidth: preferenceChipletButtonBorderWidth,
                                 backgroundColor: model.preferencesChipletBackgroundColor,
                                 shadowColor: model.shadowColor,
                                 shadowRadius: preferenceChipletButtonShadowRadius,
                                 shadowOffset: preferenceChipletButtonShadowOffset,
                                 containerPadding: preferenceChipletButtonContainerPadding,
                                 size: preferenceChipletButtonSize,
                                 textColor: model.preferencesChipletTextColor,
                                 fontWeight: model.preferencesChipletFontWeight,
                                 font: model.preferencesChipletFont)
            }
            .padding([.leading, .trailing], preferenceButtonsInsetPadding)
        }
        .padding(.bottom, preferenceButtonsBottomPadding)
    }
    
    var continueCTAButton: some View {
        HStack {
            if model.canContinue {
                StrongRectangularCTA(action: {
                    model.continueAction()
                },
                                     isEnabled: model.canContinue,
                                     backgroundColor: model.continueButtonBackgroundColor,
                                     foregroundColor: model.continueButtonForegroundColor,
                                     font: model.continueCTAFont,
                                     size: continueCTAButtonSize,
                                     message: (nil, model.continueButtonText),
                                     borderEnabled: true)
                .padding(.leading, continueCTAButtonLeadingPadding)
                .zIndex(0)
                .transition(
                    .offset(x: 500)
                    .combined(with: .opacity)
                    .animation(.spring()))
            }
            
            Spacer()
        }
    }
    
    var informationSection: some View {
        InformationSectionView(informationCopy:
                                (nil, model.makeChangesLaterPrompt))
        .padding(.leading, infoSectionLeadingPadding)
        .padding(.trailing, infoSectionTrailingPadding)
        .padding(.top, infoSectionTopPadding)
    }
    
    // MARK: - Subview Combinations
    var counterTabsDisplayView: some View {
        HStack {
            searchResultsCounterView
            selectedCoinsCounterView
        }
    }
    
    var searchBarSection: some View {
        VStack {
            HStack(spacing: 0) {
                searchBar
                
                sortCoinsButton
                
                Spacer()
            }
            
            contextPropertiesHeaderView
        }
    }
    
    var topSection: some View {
        ZStack {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        titleView
                        
                        Spacer()
                    }
                    searchBarSection
                    
                    assetsListView
                }
                
                Spacer(minLength: scrollViewBottomPadding)
            }
            .scrollDismissesKeyboard(.automatic)
            .refreshable(action: {
                model.refresh()
            })
            
            VStack {
                HStack(alignment: .top, spacing: 0) {
                    backButton
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
    
    var bottomSection: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack {
                Spacer()
                bottomSectionToggleButton
            }
                
            if displayBottomSection {
                preferenceButtons
                
                VStack(spacing: 0) {
                    continueCTAButton
                    
                    informationSection
                }
                .background(
                    Rectangle()
                        .cornerRadius(bottomSectionCornerRadius, corners: [.topLeft])
                        .shadow(color: model.shadowColor,
                                radius: bottomSectionShadowRadius,
                                x: bottomSectionShadowOffset.width,
                                y: bottomSectionShadowOffset.height)
                        .ignoresSafeArea()
                        .foregroundColor(model.bottomSectionBackgroundColor)
                        .padding(.top, bottomSectionBackgroundTopPadding)
                        .padding(.bottom, bottomSectionBackgroundBottomPadding)
                )
            }
        }
        .ignoresSafeArea(.keyboard)
        .id(displayBottomSection)
        .zIndex(1)
        .transition(.offset(y: bottomSectionHideVerticalOffset))
        .animation(.spring()
            .speed(0.75),
                   value: displayBottomSection)
        .animation(.spring(),
                   value: model.canContinue)
    }

    var body: some View {
        GeometryReader { geom in
            ZStack {
                sideVerticalDivider
                
                topSection
                
                bottomSection
            }
        }
        .presentContextMenu(with: model.contextMenuModel)
        .animation(.spring(),
                   value: model.contextPropertiesHasChanged)
        .animation(.spring(), value: model.dependencies.fiatCurrencyManager.displayedCurrency)
        .onAppear {
            performOnAppearTasks()
        }
    }
    
    /// Refresh data whenever this view reappears
    private func performOnAppearTasks() {
        model.refresh()
        model.contextMenuModel.shouldDisplay = false
    }
}

// MARK: - Functions
extension PortfolioCurationView {
    /// Hides and reveals the bottom section unconditionally
    private func toggleBottomSection() {
        displayBottomSection.toggle()
    }
}

// MARK: - Custom Subview
extension PortfolioCurationView {
    struct preferenceButton: View {
        // MARK: - Passed in properties
        let action: (() -> Void),
            title: (String?, LocalizedStringKey?),
            cornerRadius: CGFloat,
            borderGradient: LinearGradient,
            borderWidth: CGFloat,
            backgroundColor: Color,
            shadowColor: Color,
            shadowRadius: CGFloat,
            shadowOffset: CGSize,
            containerPadding: CGFloat,
            size: CGSize,
            textColor: Color,
            fontWeight: Font.Weight,
            font: FontRepository
        
        var body: some View {
            Button(action: {
                action()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderGradient,
                                lineWidth: borderWidth)
                        .overlay {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(backgroundColor)
                        }
                        .shadow(color: shadowColor,
                                radius: shadowRadius,
                                x: shadowOffset.width,
                                y: shadowOffset.height)
                    
                    if let string = title.0 {
                        Text(string)
                    }
                    else if let stringKey = title.1 {
                        Text(stringKey)
                    }
                }
                .withFont(font)
                .fontWeight(fontWeight)
                .multilineTextAlignment(.center)
                .foregroundColor(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .frame(width: size.width,
                       height: size.height)
            }
            .padding([.top, .bottom], containerPadding)
            .buttonStyle(.genericSpringyShrink)
        }
    }
}

struct PortfolioCurationView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioCurationView(model: .init(coordinator: .init(),
                                           router: .init(coordinator: .init())))
    }
}
