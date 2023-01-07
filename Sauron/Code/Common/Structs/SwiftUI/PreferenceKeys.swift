//
//  PreferenceKeys.swift
//  Inspec
//
//  Created by Justin Cook on 11/9/22.
//

import SwiftUI
import UIKit

struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
