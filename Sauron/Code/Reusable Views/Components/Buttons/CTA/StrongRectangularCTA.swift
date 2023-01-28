//
//  StrongRectangularCTA.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI

struct StrongRectangularCTA: View {
    var action: (() -> Void),
        isEnabled: Bool = true,
        backgroundColor: Color = Colors.black.0,
        foregroundColor: Color = Colors.white.0,
        shadowColor: Color = Colors.shadow_1.0,
        font: FontRepository = .body_M_Bold,
        size: CGSize = CGSize(width: 270, height: 60),
        padding: CGFloat = 0,
        message: (String?, LocalizedStringKey?) = ("Get Decentralized", nil),
        borderEnabled: Bool = false,
        borderColor: Color = Colors.black.0,
        borderWidth: CGFloat = 2,
        gradient: LinearGradient? = nil
    
    let cornerRadius: CGFloat = 10,
        shadowCoordinates: CGPoint = CGPoint(x: 0, y: 4),
        shadowRadius: CGFloat = 2
    
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
                .frame(width: size.width,
                       height: size.height)
                .withFont(font)
                .padding([.all], padding)
                .foregroundColor(foregroundColor)
                .if(gradient != nil,
                    transform: {
                    $0.background(
                        gradient
                    )
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
        .disabled(!isEnabled)
        .buttonStyle(.genericSpringyShrink)
    }
}

struct StrongRectangularCTA_Previews: PreviewProvider {
    static var previews: some View {
        StrongRectangularCTA(action: {})
    }
}
