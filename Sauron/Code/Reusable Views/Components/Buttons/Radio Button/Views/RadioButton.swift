//
//  RadioButton.swift
//  Sauron
//
//  Created by Justin Cook on 1/24/23.
//

import SwiftUI

struct RadioButton: View {
    // MARK: - Observed
    @StateObject var model: RadioButtonViewModel
    
    // MARK: - Dimensions
    // Public
    var outerDiameter: CGFloat = 30
    
    // Private
    private var innerDiameter: CGFloat {
        return outerDiameter * 0.66
    }
    private let shadowOffset: CGSize = .init(width: 0, height: 1),
                shadowRadius: CGFloat = 3,
                outerBorderLineWidth: CGFloat = 1,
                innerBorderLineWidth: CGFloat = 1
    
    var body: some View {
        mainBody
    }
}

// MARK: - View Combinations
extension RadioButton {
    var buttonBody: some View {
        ZStack {
            outterRadioCircle
            
            inscribedCircles
        }
    }
    
    var inscribedCircles: some View {
        Group {
            if model.isSelected {
                innerRadioFilledCircle
                    .transition(.scale)
            }
            else {
                innerRadioBackgroundCircle
                    .transition(.scale)
            }
        }
        .overlay {
            Circle()
                .stroke(model.innerBorderGradient,
                        lineWidth: innerBorderLineWidth)
        }
        .frame(width: innerDiameter,
               height: innerDiameter)
        .zIndex(1)
        .transition(.scale)
    }
    
    var mainBody: some View {
        Button {
            model.didSelectAction()
        } label: {
            buttonBody
        }
        .buttonStyle(.genericSpringyShrink)
        .animation(.spring(),
                   value: model.isSelected)
    }
}

// MARK: - Subviews
extension RadioButton {
    var innerRadioFilledCircle: some View {
        Group {
            if let fillGradient = model.fillGradient,
               model.shouldUseGradientFillColor {
                Circle()
                    .fill(fillGradient)
            }
            else {
                Circle()
                    .fill(model.fillColor)
            }
        }
    }
    
    var innerRadioBackgroundCircle: some View {
        Circle()
            .fill(model.backgroundColor)
    }
    
    var outterRadioCircle: some View {
        Circle()
            .fill(model.innerRegionColor)
            .frame(width: outerDiameter,
                   height: outerDiameter)
            .shadow(color: model.shadowColor,
                    radius: shadowRadius,
                    x: shadowOffset.width,
                    y: shadowOffset.height)
            .overlay {
                Circle()
                    .strokeBorder(model.outerBorderGradient,
                                  lineWidth: outerBorderLineWidth)
            }
    }
}

struct RadioButton_Previews: PreviewProvider {
    static var previews: some View {
        RadioButton(model: .init(onSelectAction: true,
                                 isSelected: false))
        .previewLayout(.sizeThatFits)
        .padding(.all, 20)
    }
}
