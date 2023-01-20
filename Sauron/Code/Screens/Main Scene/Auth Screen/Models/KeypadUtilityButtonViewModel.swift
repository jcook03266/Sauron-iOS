//
//  KeypadUtilityButtonViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/17/23.
//

import SwiftUI

class PasscodeKeyPadUtilityButtonViewModel: GenericViewModel {
    // MARK: - Observed
    @ObservedObject var authScreenViewModel: AuthScreenViewModel
    
    // MARK: - Properties
    let utilityType: UtilityType
    
    /// This button is only enabled when the user needs it / has access to it, an authenticated user has no use for it therefore its locked immediately upon auth
    var isEnabled: Bool {
        return !authScreenViewModel.shouldDisableButtons
    }
    
    // MARK: - Assets
    private let faceIDIcon: Image = Icons.getIconImage(named: .faceid),
        backspaceButtonIcon: Image = Icons.getIconImage(named: .delete_backward_fill)
    
    var buttonIcon: Image {
        switch utilityType {
        case .faceID:
            return faceIDIcon
        case .deletion:
            return backspaceButtonIcon
        }
    }
    
    // MARK: - Styling
    // Colors
    let backgroundColor: Color = Colors.neutral_200.0,
        foregroundColor: Color = Colors.black.0,
        shadowColor: Color = Colors.shadow_1.0
    
    // MARK: - Actions
    /// Triggers the required action on button press
    var action: (() -> Void) {
        HapticFeedbackDispatcher.keyPadButtonPressed()
        
        switch utilityType {
        case .faceID:
            return { [weak self] in
                guard let self = self
                else { return }
                
                // Authenticate with faceID if available
                self.authScreenViewModel.useFaceIDToAuthenticate()
            }
        case .deletion:
            return { [weak self] in
                guard let self = self
                else { return }
                
                self.authScreenViewModel
                    .clearLast()
            }
        }
    }
    
    /// Active this functionality when the user long presses the button
    var longPressAction: (() -> Void) {
        HapticFeedbackDispatcher.genericButtonPress()
        
        switch utilityType {
        case .faceID:
            return action
        case .deletion:
            return { [weak self] in
                guard let self = self
                else { return }
                
                self.authScreenViewModel
                    .clearAll()
            }
        }
    }
    
    init(authScreenViewModel: AuthScreenViewModel,
         utilityType: UtilityType)
    {
        self.authScreenViewModel = authScreenViewModel
        self.utilityType = utilityType
    }
    
    enum UtilityType: String, CaseIterable {
        case faceID, deletion
    }
}

