//
//  GradientModifiers.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI

extension View {
    func applyGradient(gradient: LinearGradient) -> some View {
        self
            .overlay(gradient)
            .mask(
                self
            )
    }
}
