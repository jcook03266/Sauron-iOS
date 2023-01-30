//
//  RoundedRectangularCTA.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI

struct RoundedRectangularCTA: View {
    // MARK: - Properties: Action - Color - Padding - Dimensions - Font
    var action: (() -> Void),
        backgroundColor: Color = Colors.primary_1.0,
        foregroundColor: Color = Colors.permanent_white.0,
        titleGradient: LinearGradient? = nil,
        shadowColor: Color = Colors.shadow_1.0,
        font: FontRepository = .body_S_Bold,
        size: CGSize = CGSize(width: 350, height: 60),
        padding: CGFloat = 0,
        message: (String?, LocalizedStringKey?) = ("Let's Go!", nil),
        borderEnabled: Bool = false,
        borderColor: Color = Colors.black.0,
        borderWidth: CGFloat = 2
    
    let cornerRadius: CGFloat = 40,
        shadowCoordinates: CGPoint = CGPoint(x: 0, y: 2),
        shadowRadius: CGFloat = 2
    
    // MARK: - Subviews
    var textBody: some View {
        Group {
            if let message = message.0 {
                Text(message)
            }
            else if let message = message.1 {
                Text(message)
            }
        }
    }
    
    var body: some View {
        Button(action: {
            HapticFeedbackDispatcher.interstitialCTAButtonPress()
            action()
        }) {
            textBody
                .frame(width: size.width, height: size.height)
                .withFont(font)
                .padding([.all], padding)
                .foregroundColor(foregroundColor)
                .if(titleGradient != nil, transform: {
                    $0.applyGradient(gradient: titleGradient!)
                })
                .background(backgroundColor)
                .overlay(
                    ShapeBorderModifier<RoundedRectangle>(
                        content: {
                            RoundedRectangle(cornerRadius: cornerRadius)
                        },
                        borderColor: borderColor,
                        borderWidth: borderWidth,
                        borderEnabled: borderEnabled
                    )
                )
                .cornerRadius(cornerRadius)
                .shadow(color: shadowColor,
                        radius: shadowRadius,
                        x: shadowCoordinates.x,
                        y: shadowCoordinates.y)
        }
        .buttonStyle(.genericSpringyShrink)
    }
}

struct RoundedRectangularCTA_Previews: PreviewProvider {
    static var previews: some View {
        RoundedRectangularCTA(action: {})
    }
}
