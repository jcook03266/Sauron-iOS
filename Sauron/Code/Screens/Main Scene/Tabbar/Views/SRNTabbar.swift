//
//  SRNTabbar.swift
//  Sauron
//
//  Created by Justin Cook on 1/21/23.
//

import SwiftUI

struct SRNTabbar: View {
    @Namespace private var tabbarSelectionAnimation
    
    // MARK: - Observed
    @StateObject var model: SRNTabbarViewModel
    
    // MARK: - Dimensions
    private let selectedTabUnderlineHeight: CGFloat = 3,
                selectedTabUnderlineRadius: CGFloat = 40,
                iconViewDiameter: CGFloat = 40,
                iconShadowRadius: CGFloat = 4,
                containerRadius: CGFloat = 40,
                containerShadowRadius: CGFloat = 2,
                containerHeight: CGFloat = 50,
                containerWidth: CGFloat = 320
    
    private var iconImageDiameter: CGFloat {
        return iconViewDiameter/(1.5)
    }
    
    // MARK: - Padding / Spacing
    private let tabbarItemSpacing: CGFloat = 20,
                iconShadowOffset: CGSize = .init(width: 0,
                                                 height: 1),
                containerShadowOffset: CGSize = .init(width: 0,
                                                      height: 2),
                iconViewLeadingPadding: CGFloat = 10,
                tabsTrailingPadding: CGFloat = 15,
                tabsLeadingPadding: CGFloat = 15
    
    
    var body: some View {
        tabbarBody
            .animation(.spring(),
                       value: model.currentTab)
    }
}

// MARK: - View Combinations
extension SRNTabbar {
    var tabbarBody: some View {
            ZStack(alignment: .center) {
                tabbarContainer
                
                HStack(alignment: .center,
                       spacing: 0) {
                    iconButton
                    tabs
                    
                    Spacer()
                }
            }
            .frame(width: containerWidth)
        .frame(height: containerHeight)
    }
    
    var iconButton: some View {
        Button {
            model.iconButtonPressed()
        } label: {
            iconView
        }
        .buttonStyle(.genericSpringyShrink)
    }
}

// MARK: - Subviews
extension SRNTabbar {
    var tabbarContainer: some View {
        Rectangle()
            .fill(model.containerBackgroundColor)
            .cornerRadius(containerRadius,
                          corners: [.topLeft, .bottomLeft])
            .shadow(color: model.shadowColor,
                    radius: containerShadowRadius,
                    x: containerShadowOffset.width,
                    y: containerShadowOffset.height)
            .frame(height: containerHeight)
    }
    
    var iconView: some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(model.tabbarIconBackgroundGradient)
                .frame(width: iconViewDiameter)
            
            model.currentIcon
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(model.tabbarIconForegroundColor)
                .frame(width: iconImageDiameter,
                       height: iconImageDiameter)
        }
        .shadow(color: model.shadowColor,
                radius: iconShadowRadius,
                x: iconShadowOffset.width,
                y: iconShadowOffset.height)
        .padding(.leading,
                 iconViewLeadingPadding)
        .id(model.currentTab)
        .transition(.scale)
        .rotation3DEffect(.degrees(model.icon3DRotationAngle), axis: (x: 2, y: 2, z: 1))
        .animation(.easeInOut(duration: 0.75),
                   value: model.iconTapped)
    }
    
    var tabs: some View {
        HStack(alignment: .top,
               spacing: tabbarItemSpacing) {
            
            ForEach(model.tabModels,
                    id: \.id) { tab in
                VStack(spacing: 0) {
                    Spacer()
                    
                    SRNTabbarTab(model: tab)

                    Spacer()
                    
                    if tab.isSelected {
                        selectedTabUnderline
                    }
                    else {
                        unselectedTabUnderline
                    }
                }
                .frame(height: containerHeight)
                .fixedSize()
            }
        }
               .padding(.leading,
                        tabsLeadingPadding)
               .padding(.trailing,
                        tabsTrailingPadding)
    }
    
    var selectedTabUnderline: some View {
        RoundedRectangle(cornerRadius: selectedTabUnderlineRadius)
            .frame(height: selectedTabUnderlineHeight)
            .applyGradient(gradient: model.tabbarActiveButtonUnderlineGradient)
            .matchedGeometryEffect(id: "selectedTab",
                                   in: tabbarSelectionAnimation)
    }
    
    /// This is just a padding view placed underneath the non selected views to keep them evened out with the selected tab
    var unselectedTabUnderline: some View {
        RoundedRectangle(cornerRadius: selectedTabUnderlineRadius)
            .fill(Color.clear)
            .frame(height: selectedTabUnderlineHeight)
    }
}

struct SRNTabbar_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Spacer()
            VStack {
                SRNTabbar(model: .init(coordinator: .init(),
                                       router: .init(coordinator: .init()),
                                       currentTab: .home))
                
                Spacer()
            }
        }
    }
}
