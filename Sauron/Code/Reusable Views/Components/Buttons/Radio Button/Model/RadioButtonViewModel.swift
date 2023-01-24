//
//  RadioButtonViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/24/23.
//

import SwiftUI

class RadioButtonViewModel: GenericViewModel {
    // MARK: - Published
    @Published var isSelected: Bool = false
    
    // MARK: - Styling
    // Colors
    var fillColor: Color,
        fillGradient: LinearGradient?,
        backgroundColor: Color = Colors.white.0,
        innerRegionColor: Color = Colors.primary_2.0,
        outerBorderGradient: LinearGradient = Colors.gradient_6,
        innerBorderGradient: LinearGradient = Colors.gradient_6,
        shadowColor: Color = Colors.shadow_2.0
    
    // MARK: - Actions
    /// The custom logic that runs and spits out a boolean that will determine if the radio button should be toggled or not
    private var onSelectAction: () -> Bool
    
    /// Fired when the user selects the radio button
    var didSelectAction: (() -> Void) {
        return { [weak self] in
            guard let self = self
            else { return }
            HapticFeedbackDispatcher.radioButtonPress()
            
            self.isSelected =  self.onSelectAction()
        }
    }
    
    // MARK: - Convenience
    /// Informs the view that it should use the provided gradient to fill in the radio button instead of the color based fill
    var currentFillColor: Color {
        return isSelected ? fillColor : backgroundColor
    }
    
    /// Informs the view that it should use the provided gradient to fill in the radio button instead of the color based fill
    var shouldUseGradientFillColor: Bool {
        return fillGradient != nil
    }
    
    init(onSelectAction: @autoclosure @escaping () -> Bool = false,
         fillColor: Color = Colors.black.0,
         fillGradient: LinearGradient? = Colors.gradient_1,
         isSelected: Bool = false)
    {
        self.onSelectAction = onSelectAction
        self.fillColor = fillColor
        self.fillGradient = fillGradient
        self.isSelected = isSelected
    }
}
