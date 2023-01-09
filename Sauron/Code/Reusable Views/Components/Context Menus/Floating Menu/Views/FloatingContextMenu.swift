//
//  FloatingContextMenu.swift
//  Sauron
//
//  Created by Justin Cook on 1/8/23.
//

import SwiftUI

/// A dynamic drop down menu that overlays some context and provides additional utility when a button is pressed
struct FloatingContextMenu: View {
    // MARK: - Observed
    @StateObject var model: FloatingContextMenuViewModel
    
    // MARK: - Dimensions + Padding
    private let titleViewSize: CGSize = .init(width: 120,
                                              height: 40),
titleViewHorizontalPadding: CGFloat = 0,
titleViewVerticalPadding: CGFloat = 10,
titleViewCornerRadius: CGFloat = 10,
titleViewSpacingFromMenuBody: CGFloat = 5,
menuBodyCornerRadius: CGFloat = 10,
    /// Max height is 200, after that the scrollview kicks in
menuBodySize: CGSize = .init(width: 200,
                             height: 200),
menuBodySideBarCornerRadius: CGFloat = 10,
menuBodySideBarWidth: CGFloat = 40,
scrollViewVerticalInset: CGFloat = 10,
sortIconViewSize: CGSize = .init(width: 15, height: 15),
sortIconHorizontalPadding: CGFloat = 10,
shadowRadius: CGFloat = 2,
shadowOffset: CGSize = .init(width: 0, height: 1)
    
    /// Where the top right corner of the context menu's content will sit
    private var anchorPoint: CGPoint {
        return CGPoint(x: model.anchorPoint.x - (menuBodySize.width/4 + 10),
                       y: model.anchorPoint.y + (menuBodySize.height/5))
    }
    
    // MARK: - View Combinations
    var contextMenuBody: some View {
        VStack(spacing: titleViewSpacingFromMenuBody) {
            HStack {
                Spacer()
                titleView
            }
            
            menuBody
        }
        .frame(width: menuBodySize.width)
        .shadow(color: model.shadowColor,
                radius: shadowRadius,
                x: shadowOffset.width,
                y: shadowOffset.height)
    }
    
    var body: some View {
        ZStack {
            backdrop
            
            contextMenuBody
                .position(anchorPoint)
        }
        .zIndex(10)
        .opacity(model.shouldDisplay ? 1 : 0)
        .animation(.easeIn,
                   value: model.shouldDisplay)
        .animation(.easeInOut,
                   value: model.selectedRow)
    }
}

extension FloatingContextMenu {
    // MARK: - Subviews
    var menuBody: some View {
        ZStack {
            RoundedRectangle(cornerRadius: menuBodyCornerRadius)
                .fill(model.menuBodyBackgroundColor)
                .frame(width: menuBodySize.width)
            
            HStack {
                menuBodySideBar
                Spacer()
            }
            
            ScrollView(.vertical,
                       showsIndicators: true) {
                Spacer(minLength: scrollViewVerticalInset)
                
                LazyVStack(alignment: .center,
                           spacing: 5) {
                    ForEach(model.rows,
                            id: \.id) {
                        
                        FloatingContextMenuRowView(model: $0,
                                                   parentModel: model)
                    }
                }
                
                Spacer(minLength: scrollViewVerticalInset)
            }
        }
        .frame(maxHeight: menuBodySize.height)
        .scaledToFit()
    }
    
    var menuBodySideBar: some View {
        Rectangle()
            .fill(model.sideBarGradient)
            .cornerRadius(10,
                          corners: [.bottomLeft, .topLeft])
            .frame(width: menuBodySideBarWidth)
    }
    
    var titleView: some View {
        Button {
            model.toggleSortingOrder()
            model.selectedRow?.action()
        } label: {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: titleViewCornerRadius)
                    .fill(model.menuTitleBackgroundColor)
                
                HStack(spacing: 0) {
                    model.sortIcon
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(model.menuTitleForegroundColor)
                        .frame(width: sortIconViewSize.width,
                               height: sortIconViewSize.height)
                        .padding([.leading, .trailing],
                                 sortIconHorizontalPadding)
                        .transition(.scale
                            .animation(.spring()))
                        .id(model.sortInAscendingOrder)
                    
                    Text(model.menuTitle)
                        .withFont(model.menuTitleFont)
                        .fontWeight(model.menuTitleFontWeight)
                        .foregroundColor(model.menuTitleForegroundColor)
                        .minimumScaleFactor(0.1)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .padding([.top, .bottom],
                                 titleViewVerticalPadding)
                        .padding([.leading, .trailing],
                                 titleViewHorizontalPadding)
                    
                    Spacer()
                }
            }
            .frame(width: titleViewSize.width,
                   height: titleViewSize.height)
        }
        .buttonStyle(.offsettableShrinkButtonStyle)
    }
}

/// Greyed out background to emphasize the current content in the context menu
extension FloatingContextMenu {
    var backdrop: some View {
        GeometryReader { geom in
            Rectangle()
                .fill(model.contextBackdropColor)
                .frame(minWidth: geom.size.width,
                       minHeight: geom.size.height)
        }
        .ignoresSafeArea()
        .onTapGesture {
            model.dismissOnTapOutside()
        }
    }
}

struct FloatingContextMenu_Previews: PreviewProvider {
    static func getModel() -> FloatingContextMenuViewModel {
        
        let rows: [FloatingContextMenuViewModel.FloatingContextMenuRow] = [.init(action: {},
                                                                                 label: "Name", sideBarIcon: Icons.getIconImage(named: .textformat_abc),
                                                                                 isSelected: true), .init(action: {},
                                                                                                          label: "ID", sideBarIcon: Icons.getIconImage(named: .tag_fill),
                                                                                                          isSelected: false),.init(action: {},
                                                                                                                                   label: "Price", sideBarIcon: Icons.getIconImage(named: .dollarsign_square_fill),
                                                                                                                                   isSelected: false)]
        
        let vm: FloatingContextMenuViewModel = .init(rows: rows,
                                                     menuTitle: "Sort by:",
                                                     anchorPoint: .init(x: 300,
                                                                        y: 300))
        
        return vm
    }
    
    static var previews: some View {
        FloatingContextMenu(model: getModel())
    }
}
