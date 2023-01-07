//
//  SwiftUIAnimationTransitions.swift
//  Inspec
//
//  Created by Justin Cook on 11/13/22.
//

import SwiftUI

extension AnyTransition {
    static var slideBackwards: AnyTransition {
        AnyTransition.asymmetric(insertion: .move(edge: .trailing),
                                 removal: .move(edge: .leading))
    }
    static var slideForwards: AnyTransition {
        AnyTransition.slide
    }
}
