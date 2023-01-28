//
//  RectangularSortButton.swift
//  Sauron
//
//  Created by Justin Cook on 1/28/23.
//

import SwiftUI

struct RectangularSortButton: View {
    // MARK: - Observed
    @StateObject var model: RectangularSortButtonViewModel
    
    // MARK: - Dimensions
    var mainSize: CGSize = .init(width: 135, height: 30)
    private let iconSize: CGSize = .init(width: 15,
                                         height: 15),
                borderWidth: CGFloat = 3
    
    // MARK: - Padding + Spacing
    var cornerRadius: CGFloat = 10
    private let titleTrailingPadding: CGFloat = 10
    
    var body: some View {
        mainBody
            .animation(.spring(),
                       value: model.sortOrderIsDescending)
    }
}

// MARK: - View Combinations
extension RectangularSortButton {
    var mainBody: some View {
        Button {
            model.buttonSortActionPassthrough()
        } label: {
            buttonBody
        }
        .buttonStyle(.genericSpringyShrink)
        .frame(width: mainSize.width,
               height: mainSize.height)
    }
    
    var buttonBody: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(model.borderGradient,
                        lineWidth: borderWidth)
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(model.backgroundColor)
            
            HStack(spacing: 0) {
                Spacer()
                title
                    .padding(.trailing,
                             titleTrailingPadding)
                
                icon
                Spacer()
            }
        }
    }
}

// MARK: - Subviews
extension RectangularSortButton {
    var title: some View {
        Text(model.title)
            .withFont(model.titleFont)
            .minimumScaleFactor(0.5)
            .foregroundColor(model.fontColor)
            .lineLimit(1)
            .multilineTextAlignment(.center)
    }
    
    var icon: some View {
        model.currentArrowIcon
            .fittedResizableTemplateImageModifier()
            .applyGradient(gradient: model.iconGradient)
            .frame(width: iconSize.width,
                   height: iconSize.height)
            .id(model.sortOrderIsDescending)
            .if(model.sortOrderIsDescending) {
                $0.transition(.push(from: .top))
            }
            .if(!model.sortOrderIsDescending) {
                $0.transition(.push(from: .bottom))
            }
    }
}

struct RectangularSortButton_Previews: PreviewProvider {
    static var previews: some View {
        RectangularSortButton(model: .init(sortIconType: .pointer,
                                           sortOrderIsDescending: false,
                                           userTriggeredDescendingSortOrderToggleAction: .random(),
                                           title: LocalizedStrings.getLocalizedString(for: .PERFORMANCE)))
    }
}
