//
//  CustomContextMenuModifiers.swift
//  Sauron
//
//  Created by Justin Cook on 1/11/23.
//

import SwiftUI

/// Modifier that simplifies the presentation of a custom context menu. This modifier does not anchor the context menu to any view element, this must be done manually by setting the model's anchor to a specific position
private struct FloatingContextMenuModifier: ViewModifier {
    var model: FloatingContextMenuViewModel
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            FloatingContextMenu(model: model)
        }
    }
}

extension View {
    func presentContextMenu(with model: FloatingContextMenuViewModel) -> some View {
        modifier(FloatingContextMenuModifier(model: model))
    }
}
