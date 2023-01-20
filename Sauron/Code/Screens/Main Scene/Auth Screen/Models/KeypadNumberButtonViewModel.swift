//
//  KeypadNumberButtonViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/17/23.
//

import SwiftUI

class PasscodeKeyPadNumberButtonViewModel: GenericViewModel {
    // MARK: - Observed
    @ObservedObject var authScreenViewModel: AuthScreenViewModel
    
    // MARK: - Properties
    let assignedNumber: Numbers
    
    /// This button is only enabled when the user needs it / has access to it, an authenticated user has no use for it therefore its locked immediately upon auth
    var isEnabled: Bool {
        return !authScreenViewModel.shouldDisableButtons
    }
    
    // MARK: - Styling
    // Colors
    let backgroundColor: Color = Colors.neutral_200.0,
        foregroundGradient: LinearGradient = Colors.gradient_1,
        shadowColor: Color = Colors.shadow_1.0
    
    // Fonts
    let numberFont: FontRepository = .heading_2
    
    // MARK: - Actions
    var action: (() -> Void) {
        return { [weak self] in
            guard let self = self
            else { return }
            
            HapticFeedbackDispatcher.genericButtonPress()
            
            self.authScreenViewModel
                .addDigit(digit: self.assignedNumber)
        }
    }
    
    var longPressAction: (() -> Void) {
        return action
    }
    
    init(authScreenViewModel: AuthScreenViewModel,
         assignedNumber: Numbers)
    {
        self.authScreenViewModel = authScreenViewModel
        self.assignedNumber = assignedNumber
    }
    
    enum Numbers: String, CaseIterable {
        case one = "1",
             two = "2",
             three = "3",
             four = "4",
             five = "5",
             six = "6",
             seven = "7",
             eight = "8",
             nine = "9",
             zero = "0"
    }
}
