//
//  Fonts.swift
//  Inspec
//
//  Created by Justin Cook on 10/28/22.
//

import Foundation
import UIKit
import SwiftUI

/// SwiftUI Font view modifier, makes using specific fonts easier in SwiftUI
// MARK: - Structs and extensions
extension View {
    func fontWithLineHeight(font: UIFont, lineHeight: CGFloat) -> some View {
        ModifiedContent(content: self, modifier: FontWithLineHeight(font: font,
                                                                    lineHeight: lineHeight))
    }
    
    func withFont(_ fontName: FontRepository) -> some View {
        let attributes = Fonts.getAttributes(for: fontName),
            font = Fonts.getUIFont(named: fontName)
        
        return ModifiedContent(content: self, modifier: FontModifier(font: font,
                                                              letterSpacing: attributes.1,
                                                              lineHeight: attributes.2))
    }
}

private struct FontModifier: ViewModifier {
    let font: UIFont,
        letterSpacing: CGFloat,
        lineHeight: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(Font(font))
            .fontWithLineHeight(font: font, lineHeight: lineHeight)
            .tracking(letterSpacing)
    }
}

private struct FontWithLineHeight: ViewModifier {
    let font: UIFont
    let lineHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .font(Font(font))
            .lineSpacing(lineHeight - font.lineHeight)
            .padding(.vertical, (lineHeight - font.lineHeight) / 2)
    }
}

/** Best suited for use with UIKit, use this whenever because UIFonts don't support the extra attributes enabled by the attributed String object*/
extension String {
    func getAttributedString(for font: FontRepository) -> NSAttributedString{
        let attributedString = NSMutableAttributedString(string: self)
        
        guard !self.isEmpty else { return attributedString}
        
        let fontAttributes = Fonts.getAttributes(for: font),
            style = NSMutableParagraphStyle(),
            font = fontAttributes.0,
            letterSpacing = fontAttributes.1,
            lineHeight = fontAttributes.2,
            range = NSRange(location: 0, length: self.count)
        
        var attributes = [NSAttributedString.Key: Any]()
        
        style.lineSpacing = lineHeight
        attributes[.font] = font
        attributes[.paragraphStyle] =  style
        attributes[.tracking] = letterSpacing
        
        attributedString.addAttributes(attributes, range: range)
        
        return attributedString
    }
}

/// Struct for easily accessing enumerated font types for specific text styles
/// This struct uses the system font, no custom fonts are enabled / used as of now
/// No testing is required for this because the default system font is used
struct Fonts {
    static func getFont(named fontName: FontRepository) -> Font {
        return Font(getUIFont(named: fontName))
    }
    
    static func getFont(named fontName: FontRepository,
                        with weight: UIFont.Weight) -> Font
    {
        return Font(getUIFont(named: fontName,
                              with: weight))
    }
    
    static func getFont(named fontName: FontRepository,
                        with weight: UIFont.Weight,
                        size: CGFloat) -> Font {
        return Font(getUIFont(named: fontName,
                              with: weight,
                              size: size))
    }
    
    static func getUIFont(named fontName: FontRepository) -> UIFont {
        let attributes = getAttributes(for: fontName),
            size = attributes.0,
            weight = attributes.3
        
        return (UIFont.systemFont(ofSize: size,
                                  weight: weight))
    }
    
    /** Polymorphism for specifying a custom weight for a given font name*/
    static func getUIFont(named fontName: FontRepository,
                          with weight: UIFont.Weight) -> UIFont
    {
        let attributes = getAttributes(for: fontName),
            size = attributes.0
        
        return (UIFont.systemFont(ofSize: size,
                                  weight: weight))
    }
    
    static func getUIFont(named fontName: FontRepository,
                          with weight: UIFont.Weight,
                          size: CGFloat) -> UIFont {
        
        return (UIFont.systemFont(ofSize: size,
                                  weight: weight))
    }
    
    /// Note: Line height can't be explicitly set for UIFonts, so they must be used via Font modifiers or modification of labels
    /// Letter spacing must be used w/ attributed strings for UIFonts, Fonts use it normally via modifier
    /** - Returns: (Font Size, Letter Spacing [When using attributed strings w/ UIFonts] (tracking [do not use kerning], LineHeight, Font Weight)*/
    static func getAttributes(for fontName: FontRepository) -> (CGFloat, CGFloat, CGFloat, UIFont.Weight) {
        
        switch fontName {
        case .heading_0:
            return (55, -0.3, 50, .bold)
        case .heading_1:
            return (44, -0.3, 52.8, .bold)
        case .heading_2:
            return (36, -0.3, 43.2, .bold)
        case .heading_3:
            return (28, -0.3, 33.6, .bold)
        case .heading_4:
            return (22, -0.3, 26.4, .bold)
        case .heading_5:
            return (18, -0.3, 21.6, .bold)
        case .heading_6:
            return (16, -0.3, 19.2, .bold)
        case .special_heading_1:
            return (14, 0.2, 21, .bold)
        case .special_heading_2:
            return (17, 0.2, 18, .bold)
        case .special_heading_3:
            return (10, 0.2, 15, .bold)
        case .body_XL:
            return (22, -0.3, 33, .regular)
        case .body_L:
            return (20, -0.3, 30, .regular)
        case .body_M:
            return (18, -0.3, 27, .regular)
        case .body_S:
            return (16, -0.3, 17, .regular)
        case .body_XS:
            return (14, -0.3, 21, .regular)
        case .body_2XS:
            return (12, -0.3, 18, .regular)
        case .body_3XS:
            return (10, -0.3, 15, .regular)
        case .body_XL_Bold:
            return (22, -0.3, 33, .bold)
        case .body_L_Bold:
            return (20, -0.3, 30, .bold)
        case .body_M_Bold:
            return (18, -0.3, 27, .bold)
        case .body_S_Bold:
            return (16, -0.3, 24, .bold)
        case .body_XS_Bold:
            return (14, -0.3, 21, .bold)
        case .body_2XS_Bold:
            return (12, -0.3, 18, .bold)
        case .body_3XS_Bold:
            return (10, -0.3, 15, .bold)
        }
    }
}

// MARK: Fonts Enum
enum FontRepository: String, CaseIterable, Codable, Hashable {
    case heading_0, heading_1, heading_2, heading_3, heading_4, heading_5, heading_6, special_heading_1, special_heading_2, special_heading_3, body_XL, body_L, body_M, body_S, body_XS, body_2XS, body_3XS, body_XL_Bold, body_L_Bold, body_M_Bold, body_S_Bold, body_XS_Bold, body_2XS_Bold, body_3XS_Bold
}
