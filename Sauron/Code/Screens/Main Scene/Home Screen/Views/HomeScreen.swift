//
//  HomeScreen.swift
//  Sauron
//
//  Created by Justin Cook on 1/21/23.
//

import SwiftUI

struct HomeScreen: View {
    // MARK: - Observed
    @StateObject var model: HomeScreenViewModel
    
    // MARK: - Dimensions
    private let foregroundContainerCornerRadius: CGFloat = 60,
                titleHeight: CGFloat = 40
    
    // MARK: - Padding + Spacing
    private let titleSectionBottomPadding: CGFloat = 10,
                titleSectionLeadingPadding: CGFloat = 10
    
    var body: some View {
        contentContainer
    }
}

// MARK: - View Combinations
extension HomeScreen {
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
            Spacer()
        }
        .padding(.bottom,
                 titleSectionBottomPadding)
        .padding(.leading,
                 titleSectionLeadingPadding)
    }
}

// MARK: - Subviews
extension HomeScreen {
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

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(model: .init(coordinator: .init(parent: MainCoordinator())))
            .background(Colors.gradient_6)
            .ignoresSafeArea()
    }
}
