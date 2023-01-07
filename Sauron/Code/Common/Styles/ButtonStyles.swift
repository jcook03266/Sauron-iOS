//
//  ButtonStyles.swift
//  Inspec
//
//  Created by Justin Cook on 11/1/22.
//

import SwiftUI
import UIKit

/// Shrinks the button by the specified amount
struct GenericSpringyShrink: ButtonStyle {
    var springResponse: CGFloat = 1.2
    var scaleAmount: CGFloat = 0.8
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.75 : 1)
            .scaleEffect(configuration.isPressed ? scaleAmount : 1)
            .animation(.spring(response: 1.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GenericSpringyShrink {
    static var genericSpringyShrink: Self {
        return .init()
    }
}

/// Offsets the button depending on the specified CGSize
struct OffsettableButtonStyle: ButtonStyle {
    var springResponse: CGFloat = 1.2
    var offset: CGSize = CGSize(width: -20, height: 0)
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.75 : 1)
            .offset(configuration.isPressed ? offset : .zero)
            .animation(.spring(response: 1.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == OffsettableButtonStyle {
    static var offsettableButtonStyle: Self {
        return .init()
    }
}

/// Offsets and shrinks the button in parallel
struct OffsettableShrinkButtonStyle: ButtonStyle {
    var springResponse: CGFloat = 1.2
    var offset: CGSize = CGSize(width: -20, height: 0)
    var scaleAmount: CGFloat = 0.95
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.75 : 1)
            .offset(configuration.isPressed ? offset : .zero)
            .scaleEffect(configuration.isPressed ? scaleAmount : 1)
            .animation(.spring(response: 1.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == OffsettableShrinkButtonStyle {
    static var offsettableShrinkButtonStyle: Self {
        return .init()
    }
}
