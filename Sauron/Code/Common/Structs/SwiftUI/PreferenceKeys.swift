//
//  PreferenceKeys.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI
import UIKit

/// A collection of reusable preference keys used when listening for specific changes inside of a view
struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct PositionPreferenceKey: PreferenceKey {
        typealias Value = CGPoint
    static var defaultValue: Value = .zero

        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = nextValue()
        }
}
