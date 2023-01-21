//
//  PreferenceBottomSheet.swift
//  Sauron
//
//  Created by Justin Cook on 1/8/23.
//

import SwiftUI

/// Notice: This view must only be presented as a sheet in order to render the content as intended
struct PreferenceBottomSheet<T: Coordinator>: View {
    // MARK: - Observed
    @StateObject var model: PreferenceBottomSheetViewModel<T>
    
    // MARK: - Dimensions
    private let maxHeight: CGFloat = 375,
                minHeight: CGFloat = 350,
                horizontalDividerHeight: CGFloat = 1,
                previewContainerCornerRadius: CGFloat = 20,
                previewContainerSize: CGSize = .init(width: 180,
                                                     height: 40),
                informationSectionHeight: CGFloat = 40,
                dismissButtonSize: CGSize = .init(width: 260, height: 50),
                selectionChipsHeight: CGFloat = 40,
                selectionChipsScrollViewHorizontalInset: CGFloat = 20
    
    // Detents for sheet presentation
    private var bottomSheetMaxDetent: PresentationDetent {
        return .height(maxHeight)
    }
    private var bottomSheetMinDetent: PresentationDetent {
        return .height(minHeight)
    }
    private var bottomSheetDetents: Set<PresentationDetent> {
        return [bottomSheetMaxDetent]
    }
    
    // MARK: - Padding
    private let topPadding: CGFloat = 20,
                bottomPadding: CGFloat = 0,
                titleViewLeadingPadding: CGFloat = 30,
                titleViewHeight: CGFloat = 60,
                previewContainerTrailingPadding: CGFloat = 15,
                searchBarLeadingPadding: CGFloat = 15,
                searchBarBottomPadding: CGFloat = 10,
                searchBarTopPadding: CGFloat = 5,
                horizontalDividerBottomPadding: CGFloat = 10,
                informationSectionTopPadding: CGFloat = 10,
                informationSectionBottomPadding: CGFloat = 15,
                informationSectionLeadingPadding: CGFloat = 20,
                informationSectionTrailingPadding: CGFloat = 20,
                selectionChipsItemSpacing: CGFloat = 10
    
    var body: some View {
        sheetBody
            .presentationDetents(bottomSheetDetents)
            .presentationDragIndicator(.visible)
            .animation(.spring(),
                       value: model.selectionChips)
    }
}

extension PreferenceBottomSheet {
    // MARK: - Sections
    var topSection: some View {
        VStack {
            HStack {
                titleView
                Spacer()
                previewContentView
            }
            
            HStack {
                searchBar
                Spacer()
            }
            
            horizontalDivider
        }
    }
    
    var bottomSection: some View {
        VStack {
            HStack {
                selectionChips
            }
            
            HStack {
                informationSection
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                dismissButton
                Spacer()
            }
            
            Spacer()
        }
    }
    
    var sheetBody: some View {
        VStack {
            topSection
            bottomSection
            Spacer()
        }
        .frame(maxHeight: maxHeight)
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
    }
}

extension PreferenceBottomSheet {
    // MARK: - Subviews
    var selectionChips: some View {
        GeometryReader { geom in
            ScrollView(.horizontal,
                       showsIndicators: false) {
                
                HStack {
                    Spacer(minLength: selectionChipsScrollViewHorizontalInset)
                    
                    LazyHStack(alignment: .center,
                               spacing: selectionChipsItemSpacing) {
                        ForEach(model.selectionChips,
                                id: \.id) {
                            PreferenceBottomSheetSelectionChipView(model: $0,
                                                                   parentModel: self.model)
                        }
                                .transition(.scale.animation(.spring()))
                    }
                    
                    Spacer(minLength: selectionChipsScrollViewHorizontalInset)
                }
            }
                       .frame(width: geom.size.width,
                              height: selectionChipsHeight)
        }
        .frame(height: selectionChipsHeight)
    }
    
    var horizontalDivider: some View {
        GeometryReader { geom in
            StraightSolidDividingLine(width: geom.size.width,
                                      height: horizontalDividerHeight,
                                      gradient: model.horizontalDividerGradient)
        }
        .frame(height: horizontalDividerHeight)
        .padding(.bottom, horizontalDividerBottomPadding)
    }
    
    var dismissButton: some View {
        StrongRectangularCTA(action: {
            model.dismissAction()
        },
                             isEnabled: true,
                             backgroundColor: model.dismissButtonBackgroundColor,
                             foregroundColor: model.dismissButtonForegroundColor,
                             font: model.dismissButtonFont,
                             size: dismissButtonSize,
                             message: (model.dismissButtonTitle, nil),
                             borderEnabled: true)
    }
    
    var titleView: some View {
        Text(model.title)
            .withFont(model.titleFont)
            .fontWeight(model.titleFontWeight)
            .multilineTextAlignment(.leading)
            .foregroundColor(model.titleForegroundColor)
            .lineLimit(2)
            .minimumScaleFactor(0.1)
            .padding(.leading, titleViewLeadingPadding)
            .frame(height: titleViewHeight)
    }
    
    var searchBar: some View {
        SatelliteTextField(model: model.searchBarTextFieldModel)
            .padding(.leading, searchBarLeadingPadding)
            .padding(.bottom, searchBarBottomPadding)
            .padding(.top, searchBarTopPadding)
    }
    
    var informationSection: some View {
        InformationSectionView(informationCopy:
                                (model.optionalAdvisoryText, nil),
                               iconGradient: model.informationSectionIndicatorGradient,
                               textColor: model.informationSectionForegroundColor,
                               textFont: model.informationSectionFont,
                               height: informationSectionHeight)
        .padding(.top, informationSectionTopPadding)
        .padding(.bottom, informationSectionBottomPadding)
        .padding(.leading, informationSectionLeadingPadding)
        .padding(.trailing, informationSectionTrailingPadding)
    }
    
    var previewContentView: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: previewContainerCornerRadius)
                .fill(model.previewTextBackgroundGradient)
                .frame(width: previewContainerSize.width,
                       height: previewContainerSize.height)
            
            Text(model.previewContent())
                .withFont(model.previewTextFont)
                .fontWeight(model.previewTextFontWeight)
                .multilineTextAlignment(.center)
                .foregroundColor(model.previewTextForegroundColor)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
        }
        .padding(.trailing, previewContainerTrailingPadding)
    }
}

struct PreferenceBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceBottomSheet(model: BottomSheetDispatcher.getCurrencyPreferenceModel(using: OnboardingCoordinator()))
    }
}
