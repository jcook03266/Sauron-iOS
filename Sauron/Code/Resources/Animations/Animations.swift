//
//  Animations.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI
import UIKit
import Lottie

// MARK: - Structs
struct LottieAnimations {
    static func getAnimation(named animationName: LottieAnimationRepository) -> LottieAnimation {
        guard let animation = LottieAnimation.named(animationName.rawValue) else {
            ErrorCodeDispatcher.ResourceErrors.triggerPreconditionFailure(for: .lottieAnimationNotFound,
                                                                     using: "The lottie animation JSON file named \(animationName) was not found, Function: \(#function)")()
        }
        
        return animation
    }
    
    static var loading_animation_circles: LottieAnimation {
        return getAnimation(named: .loading_animation_circles)
    }
    
    static var crypto_orbital: LottieAnimation {
        return getAnimation(named: .crypto_orbital)
    }
    
    static var dashboard_graph: LottieAnimation {
        return getAnimation(named: .dashboard_graph)
    }
    
    static var wifi_test_animation: LottieAnimation {
        return getAnimation(named: .wifi_test_animation)
    }
    
    static var radial_grid: LottieAnimation {
        return getAnimation(named: .radial_grid)
    }
}

// MARK: - Animation JSON File Enumerations
// Please update this repo whenever any new animations are added
enum LottieAnimationRepository: String, CaseIterable {
    case crypto_orbital,
         dashboard_graph,
         loading_animation_circles,
         wifi_test_animation,
         radial_grid
}


