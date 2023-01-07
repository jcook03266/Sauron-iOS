//
//  HalfRoundedRectangularCTA.swift
//  Inspec
//
//  Created by Justin Cook on 11/18/22.
//

import SwiftUI

struct HalfRoundedRectangularCTA: View {
    var action: (() -> Void)
    var backgroundColor: Color = Colors.primary_1.0,
        foregroundColor: Color = Colors.permanent_white.0,
        shadowColor: Color = Colors.shadow_1.0,
        font: FontRepository = .body_S_Bold,
        size: CGSize = CGSize(width: 350, height: 60),
        padding: CGFloat = 0,
        message: (String?, LocalizedStringKey?) = ("I'm half rounded!", nil),
        anchor: anchoredEdge = .leading
    
    let cornerRadius: CGFloat = 40,
        shadowCoordinates: CGPoint = CGPoint(x: 0, y: 2),
        shadowRadius: CGFloat = 2
    
    var rectCorners: UIRectCorner {
        switch anchor {
        case .leading:
            return [.topRight, .bottomRight]
        case .trailing:
            return [.topLeft, .bottomLeft]
        }
    }
    
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
                .background(backgroundColor)
                .cornerRadius(cornerRadius,
                              corners: rectCorners)
                .shadow(color: shadowColor,
                        radius: shadowRadius,
                        x: shadowCoordinates.x,
                        y: shadowCoordinates.y)
        }
    }
    
    /// The edge of the screen where this button will be anchored to
    enum anchoredEdge: String, CaseIterable, Hashable {
        case leading, // Left
        trailing // Right
    }
}

struct HalfRoundedRectangularCTA_Previews: PreviewProvider {
    static var previews: some View {
        HalfRoundedRectangularCTA(action: {})
    }
}
