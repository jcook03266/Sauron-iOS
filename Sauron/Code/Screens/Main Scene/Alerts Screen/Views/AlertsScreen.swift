//
//  AlertsScreen.swift
//  Sauron
//
//  Created by Justin Cook on 1/22/23.
//

import SwiftUI

struct AlertsScreen: View {
    // MARK: - Observed
    @StateObject var model: AlertsScreenViewModel
    
    // MARK: - Dimensions
    private let foregroundContainerCornerRadius: CGFloat = 60,
                titleIconSize: CGSize = .init(width: 40,
                                              height: 40),
                titleHeight: CGFloat = 40
    
    // MARK: - Padding + Spacing
    private let titleIconLeadingPadding: CGFloat = 10,
                titleSectionBottomPadding: CGFloat = 10,
                titleSectionLeadingPadding: CGFloat = 10
    
    var body: some View {
        contentContainer
    }
}

// MARK: - View Combinations
extension AlertsScreen {
    var featureReleaseScreen: some View {
        FutureFeatureReleaseScreen(model: model.FFRScreenViewModel)
    }
    
    var contentContainer: some View {
        GeometryReader { geom in
            ZStack(alignment: .bottom) {
                background
                
                VStack(spacing: 0) {
                    titleSection
                    
                    HStack {
                        Spacer()
                        
                        ZStack {
                            foregroundContainer
                                .ignoresSafeArea()
                            
                            featureReleaseScreen
                        }
                        .frame(width: geom.size.width * 0.975,
                               height: geom.size.height * 0.84)
                    }
                }
            }
        }
    }
    
    var titleSection: some View {
        HStack(spacing: 0) {
            titleView
            titleIconView
            Spacer()
        }
        .padding(.bottom,
                 titleSectionBottomPadding)
        .padding(.leading,
                 titleSectionLeadingPadding)
    }
}

// MARK: - Subviews
extension AlertsScreen {
    var titleView: some View {
        Text(model.title)
            .withFont(model.titleFont)
            .fontWeight(model.titleFontWeight)
            .minimumScaleFactor(0.5)
            .foregroundColor(model.titleForegroundColor)
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .frame(height: titleHeight)
    }
    
    var titleIconView: some View {
        model.titleIcon
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(model.titleIconForegroundColor)
            .frame(width: titleIconSize.width,
                   height: titleIconSize.height)
            .padding(.leading,
                     titleIconLeadingPadding)
    }
    
    var background: some View {
        Rectangle()
            .fill(model.backgroundColor)
            .ignoresSafeArea()
    }
    
    var foregroundContainer: some View {
        Rectangle()
            .fill(model.foregroundContainerColor)
            .cornerRadius(foregroundContainerCornerRadius,
                          corners: [.topLeft,
                                    .bottomLeft])
    }
}

struct AlertsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlertsScreen(model: .init(coordinator: .init(parent: MainCoordinator())))
            .background(Colors.gradient_6)
            .ignoresSafeArea()
    }
}
