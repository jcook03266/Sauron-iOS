//
//  VOCView.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI

struct VOC: View {
    // MARK: - Observed
    @StateObject var model: VOCViewModel
    @StateObject var PBNCoordinator: ProgressBarNavigationCoordinator<VOCViewModel>
    @StateObject var progressBarModel: PartitionedProgressBarViewModel
    
    let progressBarLeadingPadding: CGFloat = 20,
        progressBarTopPadding: CGFloat  = 40,
        /// The amount of space roughly taken up by the progress bar and its safe area
        navigationButtonsLeadingPadding: CGFloat = 5,
        skipButtonTrailingPadding: CGFloat = 15,
        bottomNavigationButtonPadding: CGFloat = 0,
        lastPageCTAButtonLeadingPadding: CGFloat = 20
    
    var lastPageCTAButtonTopPadding: CGFloat {
        !DeviceConstants.isDeviceSmallFormFactor() ? -20 : 150
    }
    
    /// Used for calculating the current offset of the grid relative to the progress bar's progress
    var zeroIndexedCurrentPage: (Int, CGFloat) {
        let zeroIndex = progressBarModel.currentPage - 1
        return (zeroIndex, CGFloat(zeroIndex))
    }
    var skipAction: (() -> Void) {
        return {
            PBNCoordinator.skipToLast()
        }
    }
    var upArrowAction: (() -> Void) {
        return {
            PBNCoordinator.moveBackward()
        }
    }
    var downArrowAction: (() -> Void) {
        return {
            PBNCoordinator.moveForward()
        }
    }
    var continueCTAAction: (() -> Void) {
        return self.model.goToHomeScreen
    }
    var progressBar: PartitionedProgressView {
        let view = PartitionedProgressView(viewModel: progressBarModel,
                                           progressBarFillColor: Colors.primary_2.0,
                                           barHeight: 100,
                                           barWidth: 10)
        
        return view
    }
    
    /// To skip through the onboarding
    var skipButton: some View {
        HStack {
            Text(LocalizedStrings.getLocalizedStringKey(for: .NAVIGATION_BUTTON_SKIP))
                .foregroundColor(model.currentPage != 2 ?
                                 Colors.primary_1.0 : Colors.permanent_white.0)
                .withFont(.body_L)
                .fontWeight(.semibold)
                .onTapGesture {
                    skipAction()
                }
            
            ArrowButton(action: {
                skipAction()
            },
                        arrowDirection: .down,
                        buttonType: .skip2,
                        isEnabled: .constant(!self.model.isOnLastPage))
        }
    }
    
    /// Goes backwards from the last page
    var lastPageBackButton: some View {
        ArrowButton(action: {
            upArrowAction()
        },
                    arrowDirection: .up,
                    buttonType: .next,
                    isEnabled: .constant(self.model.isOnLastPage))
    }
    
    /// Buttons used to navigate through the onboarding screen before the last page is displayed
    var navigationButtons: some View {
        VStack(spacing: 20) {
            // Up Arrow
            ArrowButton(action: {
                upArrowAction()
            },
                        arrowDirection: .up,
                        buttonType: .next,
                        isEnabled: .constant(!self.model.isOnFirstPage))
            
            // Down Arrow
            ArrowButton(action: {
                downArrowAction()
            },
                        arrowDirection: .down,
                        buttonType: .next,
                        isEnabled: .constant(!self.model.isOnLastPage))
        }
        .padding([.bottom], bottomNavigationButtonPadding)
    }
    
    /// CTA that completes the user's onboarding experience and shifts them to the home screen
    var lastPageCTAButton: some View {
        VStack {
            StrongRectangularCTA(action: {
                continueCTAAction()
            },
                                 backgroundColor: Colors.permanent_black.0,
                                 foregroundColor: Colors.permanent_white.0,
                                 message: (nil, LocalizedStrings.getLocalizedStringKey(for: .ONBOARDING_PAGE_3_CTA)),
                                 borderEnabled: true)
        }
        .padding(.bottom, bottomNavigationButtonPadding)
    }
    
    var pageViews: some View {
        GeometryReader { geom in
            LazyVGrid(columns: OnboardingPages.gridItemLayout) {
                ForEach(model.pages, id: \.pageNumber) { pageModel in
                    
                    let page = VOCPageView(model: pageModel,
                                           manager: self.model)
                    
                    ZStack {
                        HStack {
                            VStack{
                                page
                                    .frame(width: geom.size.width,
                                           height: geom.size.height)
                            }
                        }
                    }
                }
            }
            .offset(CGSize(width: 0,
                           height: -(geom.size.height * zeroIndexedCurrentPage.1)))
            .animation(.spring(response: 1),
                       value: progressBarModel.currentPage)
        }
        .ignoresSafeArea()
    }
    
    var body: some View {
        GeometryReader { geom in
            ZStack {
                pageViews
                
                ZStack {
                    Spacer()
                    
                    if (!model.isOnLastPage) {
                        VStack {
                            HStack {
                                navigationButtons
                                Spacer()
                            }
                            .padding([.leading],
                                     navigationButtonsLeadingPadding)
                            
                            Spacer()
                        }
                        .transition(.move(edge: .leading))
                    }
                    
                    VStack {
                        if (!model.isOnLastPage) {
                            HStack {
                                Spacer()
                                skipButton
                            }
                            .padding([.trailing],
                                     skipButtonTrailingPadding)
                            .transition(.move(edge: .trailing))
                        }
                        
                        HStack {
                            Spacer()
                            progressBar
                                .padding([.trailing],
                                         progressBarLeadingPadding)
                                .padding([.top],
                                         progressBarTopPadding)
                        }
                        
                        Spacer()
                    }
                }
                
                if (model.isOnLastPage) {
                    VStack(alignment: .center) {
                        HStack {
                            lastPageBackButton
                            Spacer()
                        }
                        .padding([.leading],
                                 navigationButtonsLeadingPadding)
                        Spacer()
                    }
                    .transition(.move(edge: .leading))
                    
                    HStack {
                        lastPageCTAButton
                            .padding(.leading,
                                     lastPageCTAButtonLeadingPadding)
                            .padding(.top,
                                     lastPageCTAButtonTopPadding)
                        
                        Spacer()
                    }
                    .zIndex(1) // Set Z-index to enable removal animation here
                    .transition(
                        .asymmetric(insertion:
                                .slideForwards.animation(.easeInOut(duration: 0.1)),
                                    removal: .slideBackwards.animation(.spring()
                                        .speed(1.5)))
                    )
                }
            }
            .animation(.spring(),
                       value: PBNCoordinator.currentPage)
        }
    }
}

struct VOC_Previews: PreviewProvider {
    private static func getModels() -> (VOCViewModel, ProgressBarNavigationCoordinator<VOCViewModel>) {
        
        let model = VOCViewModel(coordinator: .init())
        let coordinator = ProgressBarNavigationCoordinator<VOCViewModel>.init(viewModel: model, progressBar: model.progressBar)
        
        coordinator.injectProgressViewOnTapActions()
        
        return (model, coordinator)
    }
    
    static var previews: some View {
        let models = getModels()
        
        VOC(model: models.0,
            PBNCoordinator: models.1,
            progressBarModel: models.0.progressBar)
    }
}
