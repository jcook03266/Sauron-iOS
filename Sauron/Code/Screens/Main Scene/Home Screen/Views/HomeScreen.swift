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
    private let foregroundContainerCornerRadius: CGFloat = 60
    
    // MARK: - Padding + Spacing
    
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
                
            HStack {
                Spacer()
                
                foregroundContainer
                    .frame(width: geom.size.width * 0.975,
                           height: geom.size.height * 0.8)
            }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Subviews
extension HomeScreen {
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
    }
}
