//
//  Colors.swift
//  Inspec
//
//  Created by Justin Cook on 10/28/22.
//

import Foundation
import SwiftUI
import UIKit

/// Simplified and organized way of referencing the colors stored in the Colors assets directory.
/// Note: If a new color is added, update the respective test in ResourcesTests.swift
// MARK: - Structs
struct Colors {
    static func getColor(named colorName: ColorRepository) -> Color {
        let color = Color(getUIColor(named: colorName))
        
        return color
    }
    
    static func getUIColor(named colorName: ColorRepository) -> UIColor {
        guard let uiColor = UIColor(named: colorName.rawValue) else {
            preconditionFailure("Error: The color named \(colorName) was not found, Function: \(#function)")
        }
        
        return uiColor
    }
    
    static func getUIColors(named color1: ColorRepository, color2: ColorRepository) -> (UIColor, UIColor) {
        guard let uiColor1 = UIColor(named: color1.rawValue),
                let uiColor2 = UIColor(named: color2.rawValue) else {
            preconditionFailure("Error: One of the colors named [\(color1), \(color2)] were not found, Function: \(#function)")
        }

        return (uiColor1, uiColor2)
    }
    
    static func getColors(named color1: ColorRepository, color2: ColorRepository) -> (Color, Color) {
        let uiColors = getUIColors(named: color1, color2: color2)

        return (Color(uiColors.0), Color(uiColors.1))
    }
    
    static func getColors(named colors: [ColorRepository]) -> [Color] {
        var uiColors: [Color] = [Color]()
        
        for color in colors {
            let color = Color(getUIColor(named: color))
            uiColors.append(color)
        }

        return uiColors
    }
    
    static func getLinearGradient(named gradientName: GradientRepository) -> LinearGradient {
        switch gradientName {
        case .gradient_1:
            let colors = getColors(named: .primary_2,
                                   color2: .secondary_1)
            let startPoint = UnitPoint(x: 0, y: 1)
            let endPoint = UnitPoint(x: 1, y: 0)
            
            return LinearGradient(colors: [colors.0, colors.1],
                                  startPoint: startPoint,
                                  endPoint: endPoint)
        case .gradient_2:
            let colors = getColors(named: .white, color2: .secondary_2)
            let startPoint = UnitPoint(x: 0.25, y: 0)
            let endPoint = UnitPoint(x: 0.75, y: 0.5)
            
            let colorStops: [Gradient.Stop] = [
                .init(color: colors.0,
                      location: 0.0),
                .init(color: colors.1,
                      location: 0.45)
            ]

            
            return LinearGradient(stops: colorStops,
                                  startPoint: startPoint,
                                  endPoint: endPoint)
        case .gradient_3:
            let colors = getColors(named: [.white, .secondary_1, .primary_3])
            let startPoint = UnitPoint(x: 0.05, y: 0.48)
            let endPoint = UnitPoint(x: 1, y: 0.80)
            
            let colorStops: [Gradient.Stop] = [
                .init(color: colors[0],
                      location: 0.8),
                .init(color: colors[1],
                      location: 0.8),
                .init(color: colors[2],
                      location: 1)
            ]

            
            return LinearGradient(stops: colorStops,
                                  startPoint: startPoint,
                                  endPoint: endPoint)
        case .gradient_4:
            let colors = getColors(named: [.primary_3, .secondary_3, .white])
            let startPoint = UnitPoint(x: 0.4, y: 0.1)
            let endPoint = UnitPoint(x: 0.7, y: 0.65)
            
            let colorStops: [Gradient.Stop] = [
                .init(color: colors[0],
                      location: 0),
                .init(color: colors[1],
                      location: 0.17),
                .init(color: colors[2],
                      location: 0.17)
            ]
            
            return LinearGradient(stops: colorStops,
                                  startPoint: startPoint,
                                  endPoint: endPoint)
        case .gradient_5:
            let colors = getColors(named: [.white, .secondary_2, .primary_3])
            let startPoint = UnitPoint(x: 0.2, y: 0.4)
            let endPoint = UnitPoint(x: 0.5, y: 0.7)
            
            let colorStops: [Gradient.Stop] = [
                .init(color: colors[0],
                      location: 0.8),
                .init(color: colors[1],
                      location: 0.8),
                .init(color: colors[2],
                      location: 1)
            ]

            
            return LinearGradient(stops: colorStops,
                                  startPoint: startPoint,
                                  endPoint: endPoint)
        case .gradient_6:
            /// This is what gradient 1 should look like according to the design specs, but the current gradient 1 looks best as is for its usage case, this is used for the main content screens background
            let colors = getColors(named: .primary_3,
                                   color2: .secondary_1)
            let startPoint = UnitPoint(x: 0, y: 0)
            let endPoint = UnitPoint(x: 0, y: 1)
            
            return LinearGradient(colors: [colors.0, colors.1.opacity(0.7)],
                                  startPoint: startPoint,
                                  endPoint: endPoint)
        }
    }
    
    // Colors
    static var primary_1: (Color, UIColor) {
        return (getColor(named: .primary_1), getUIColor(named: .primary_1))
    }
    static var primary_2: (Color, UIColor) {
        return (getColor(named: .primary_2), getUIColor(named: .primary_2))
    }
    static var primary_3: (Color, UIColor) {
        return (getColor(named: .primary_3), getUIColor(named: .primary_3))
    }
    static var secondary_1: (Color, UIColor) {
        return (getColor(named: .secondary_1), getUIColor(named: .secondary_1))
    }
    static var secondary_2: (Color, UIColor) {
        return (getColor(named: .secondary_2), getUIColor(named: .secondary_2))
    }
    static var secondary_3: (Color, UIColor) {
        return (getColor(named: .secondary_3), getUIColor(named: .secondary_3))
    }
    static var black: (Color, UIColor) {
        return (getColor(named: .black), getUIColor(named: .black))
    }
    static var neutral_900: (Color, UIColor) {
        return (getColor(named: .neutral_900), getUIColor(named: .neutral_900))
    }
    static var neutral_800: (Color, UIColor) {
        return (getColor(named: .neutral_800), getUIColor(named: .neutral_800))
    }
    static var neutral_700: (Color, UIColor) {
        return (getColor(named: .neutral_700), getUIColor(named: .neutral_700))
    }
    static var neutral_600: (Color, UIColor) {
        return (getColor(named: .neutral_600), getUIColor(named: .neutral_600))
    }
    static var neutral_500: (Color, UIColor) {
        return (getColor(named: .neutral_500), getUIColor(named: .neutral_500))
    }
    static var neutral_400: (Color, UIColor) {
        return (getColor(named: .neutral_400), getUIColor(named: .neutral_400))
    }
    static var neutral_300: (Color, UIColor) {
        return (getColor(named: .neutral_300), getUIColor(named: .neutral_300))
    }
    static var neutral_200: (Color, UIColor) {
        return (getColor(named: .neutral_200), getUIColor(named: .neutral_200))
    }
    static var neutral_100: (Color, UIColor) {
        return (getColor(named: .neutral_100), getUIColor(named: .neutral_100))
    }
    static var white: (Color, UIColor) {
        return (getColor(named: .white), getUIColor(named: .white))
    }
    static var attention: (Color, UIColor) {
        return (getColor(named: .attention), getUIColor(named: .attention))
    }
    static var shadow_1: (Color, UIColor) {
        return (getColor(named: .shadow_1), getUIColor(named: .shadow_1))
    }
    static var shadow_2: (Color, UIColor) {
        return (getColor(named: .shadow_2), getUIColor(named: .shadow_2))
    }
    
    // Opaque Colors
    // Black with an opacity of 45%
    static var black_45: (Color, UIColor) {
        return (getColor(named: .black_45), getUIColor(named: .black_45))
    }
    static var backdrop: (Color, UIColor) {
        return (getColor(named: .backdrop), getUIColor(named: .backdrop))
    }
    
    // Permanent Colors (Don't change w/ environment attributes)
    static var permanent_white: (Color, UIColor) {
        return (getColor(named: .permanent_white), getUIColor(named: .permanent_white))
    }
    static var permanent_black: (Color, UIColor) {
        return (getColor(named: .permanent_black), getUIColor(named: .permanent_black))
    }

    // Gradients
    static var gradient_1: LinearGradient {
        return getLinearGradient(named: .gradient_1)
    }
    static var gradient_2: LinearGradient {
        return getLinearGradient(named: .gradient_2)
    }
    static var gradient_3: LinearGradient {
        return getLinearGradient(named: .gradient_3)
    }
    static var gradient_4: LinearGradient {
        return getLinearGradient(named: .gradient_4)
    }
    static var gradient_5: LinearGradient {
        return getLinearGradient(named: .gradient_5)
    }
    static var gradient_6: LinearGradient {
        return getLinearGradient(named: .gradient_6)
    }
}

// MARK: Colors Enum
enum ColorRepository: String, CaseIterable, Codable, Hashable {
    case primary_1, primary_2, primary_3, secondary_1, secondary_2, secondary_3, black, neutral_900, neutral_800, neutral_700, neutral_600, neutral_500, neutral_400, neutral_300, neutral_200, neutral_100, white, attention, shadow_1, shadow_2, text_black, text_white, permanent_white, permanent_black, black_45, backdrop
}

// MARK: Gradients Enum
enum GradientRepository: String, CaseIterable, Codable, Hashable {
    case gradient_1, gradient_2, gradient_3, gradient_4, gradient_5, gradient_6
}
