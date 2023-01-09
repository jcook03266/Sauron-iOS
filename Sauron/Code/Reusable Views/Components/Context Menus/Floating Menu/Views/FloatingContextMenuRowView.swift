//
//  FloatingContextMenuRowView.swift
//  Sauron
//
//  Created by Justin Cook on 1/8/23.
//

import SwiftUI

struct FloatingContextMenuRowView: View {
    // MARK: - Observed
    @StateObject var model: FloatingContextMenuViewModel.FloatingContextMenuRow
    @ObservedObject var parentModel: FloatingContextMenuViewModel
    
    // MARK: - Dimensions + Padding
    private let iconViewSize: CGSize = .init(width: 40,
                                             height: 30),
                iconHorizontalPadding: CGFloat = 10,
                rowTrailingPadding: CGFloat = 10,
                labelViewLeadingPadding: CGFloat = 5,
                rowHeight: CGFloat = 30
    
    // MARK: - Styling
    // Shadow
    private var shadowOffset: CGSize {
        return model.isSelected ? .init(width: 0, height: 1) : .zero
    }
    private var shadowRadius: CGFloat {
        return model.isSelected ? 3 : 0
    }
    
    // MARK: - Subviews
    var labelView: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(model.backgroundColor)
                .cornerRadius(9, corners:
                                [.topRight, .bottomRight])
                .shadow(color: model.shadowColor,
                        radius: shadowRadius,
                        x: shadowOffset.width,
                        y: shadowOffset.height)
                .transition(.push(from: parentModel.doesRowPrecedeSelectedRow(row: model) ? .top : .bottom ))
                .opacity(model.isSelected ? 1 : 0)
            
            Text(model.label)
                .withFont(model.font)
                .fontWeight(model.fontWeight)
                .foregroundColor(model.foregroundColor)
                .minimumScaleFactor(0.1)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .padding(.leading, labelViewLeadingPadding)
        }
    }
    
    var iconView: some View {
        model.sideBarIcon?
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .foregroundColor(model.iconForegroundColor)
            .padding([.leading, .trailing],
                     iconHorizontalPadding)
            .frame(width: iconViewSize.width,
                   height: iconViewSize.height)
    }
    
    // MARK: - View Combinations
    var labelButton: some View {
        Button {
            HapticFeedbackDispatcher.genericButtonPress()
            model.action()
            
            parentModel.selectedRow = model
        } label: {
            labelView
        }
    }
    
    var rowBody: some View {
        HStack(spacing: 0) {
            iconView
            
            labelButton
            
            Spacer()
        }
        .padding(.trailing, rowTrailingPadding)
    }
    
    var body: some View {
        rowBody
            .frame(height: rowHeight)
            .onChange(of: parentModel.selectedRow) { newRow in
                
                /// Updates all rows depending on the newest selected row
                if newRow != model {
                    model.isSelected = false
                }
                else {
                    model.isSelected = true
                }
            }
    }
}

struct FloatingContextMenuRowView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingContextMenuRowView(model: .init(action: {},
                                                label: "Name",
                                                sideBarIcon: Icons.getIconImage(named: .textformat_abc),            isSelected: false), parentModel: .init(menuTitle: "Sort by:", anchorPoint: .init(x: 300,
                                                                                                                                                                                                     y: 300)))
    }
}
