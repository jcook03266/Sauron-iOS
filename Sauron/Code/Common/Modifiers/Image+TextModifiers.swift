//
//  Image+TextModifiers.swift
//  Sauron
//
//  Created by Justin Cook on 1/24/23.
//

import SwiftUI

// MARK: - Description
/// Some general modifiers that centralize a lot of the modification patterns
/// present across the application for image and text views

// MARK: - Type Specific View Modifier Protocol
protocol ImageModifier {
    /// `Body` is derived from `View`
    associatedtype Body : View

    /// Modify an image by applying any modifications into `some View`
    func body(content: Image) -> Self.Body
}

extension Image {
    func modifier<M>(_ modifier: M) -> some View where M: ImageModifier {
        modifier.body(content: self)
    }
}

private struct FittedResizableTemplateImage: ImageModifier {
    func body(content: Image) -> some View {
        content
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
    }
}

private struct FittedResizableOriginalImage: ImageModifier {
    func body(content: Image) -> some View {
        content
            .resizable()
            .renderingMode(.original)
            .aspectRatio(contentMode: .fit)
    }
}

extension Image {
    /// - Properties: Resizable + .template rendering mode + .fit aspect ratio
    func fittedResizableTemplateImageModifier() -> some View {
        self
            .modifier(FittedResizableTemplateImage())
    }
    
    /// - Properties: Resizable + .original rendering mode + .fit aspect ratio
    func fittedResizableOriginalImageModifier() -> some View {
        self
            .modifier(FittedResizableOriginalImage())
    }
}

