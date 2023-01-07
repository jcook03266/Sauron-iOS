//
//  LaunchScreenBridgeViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI
import Lottie

class LaunchScreenBridgeViewModel: ObservableObject {
    // MARK: - Assets
    var launchScreenImage: Image = Icons.getIconImage(named: .app_icon_transparent)
    
    // MARK: Styling
    // Color
    var backgroundGradient: LinearGradient = Colors.gradient_1
    var foregroundColor: Color = Colors.permanent_white.0
    var textColor: Color = Colors.permanent_white.0
    // Font
    var appNameTextFont: Font = Fonts.getFont(named: .heading_1,
                                              with: .semibold,
                                              size: 40)
    var appNameTextFontName: FontRepository = .heading_1
    
    // MARK: - Localized Text
    var appNameText: String = LocalizedStrings.getLocalizedString(for: .APP_NAME).localizedUppercase
    
    // MARK: - Dimensions
    var launchScreenImageSize: CGSize = CGSize(width: 150, height: 150)
    
    // MARK: - Animation
    var lottieAnimation: LottieAnimationRepository = .loading_animation_circles
    
    init() {}
}
