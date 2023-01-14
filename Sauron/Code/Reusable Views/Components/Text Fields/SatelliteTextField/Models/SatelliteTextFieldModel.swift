//
//  SatelliteTextFieldModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/5/23.
//

import SwiftUI

class SatelliteTextFieldModel: SatelliteTextFieldModelProtocol {    
    // MARK: - Properties
    let id: UUID = .init()
    
    var keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        textInputAutocapitalization: TextInputAutocapitalization = .never,
        submitLabel: SubmitLabel = .search,
        autoCorrectionDisabled: Bool = true,
        
        // Labels and initial text to be displayed
        title: String,
        placeholderText: String,
        
        // MARK: - Actions
        onSubmitAction: (() -> Void)? = nil
    
    // MARK: - Binding (Non-property wrapper)
    var boundTextEntry: Binding<String> {
        .init {
            return self.textEntry
        } set: {
            self.textEntry = $0
        }
    }
    
    // MARK: - Published
    @Published var textEntry: String
    @Published var enabled: Bool = true
    @Published var focused: Bool = false
    @Published var clearButtonEnabled: Bool = true
    
    // MARK: - General Properties
    // Interior
    var fieldBackgroundColor: Color = Colors.white.0,
        textFieldTextColor: Color = Colors.black.0,
        textColor: Color = Colors.permanent_white.0,
        borderColor: Color = Colors.primary_1.0,
        borderGradient: LinearGradient? = Colors.gradient_1,
        sheatheColor: Color = Colors.primary_1.0,
        textFont: FontRepository = .body_S,
        fontWeight: Font.Weight = .semibold,
        
        // Exterior / Shadow
        invalidEntryGlow: Color? = Colors.attention.0,
        validEntryGlow: Color? = Colors.primary_2.0,
        defaultShadowColor: Color? = Colors.shadow_1.0,
        shadowRadius: CGFloat? = 4,
        shadowOffset: CGSize? = CGSize(width: 0, height: 4),
        shadowColor: Color = Colors.shadow_1.0
    
    // MARK: - Satellite Button properties
    var satelliteButtonActiveIcon: Image = Icons.getIconImage(named: .magnifyingglass), // Not Focused
        satelliteButtonInActiveIcon: Image = Icons.getIconImage(named: .xmark), // Focused
        satelliteButtonAction: (() -> Void) = {},
satelliteButtonIconTint: Color = Colors.white.0,
satelliteButtonBackgroundColor: Color = Colors.black.0,
satelliteButtonShadowColor: Color = Colors.shadow_1.0
    
    // MARK: - Clear textfield button properties
    var clearTextFieldButtonIcon: Image = Icons.getIconImage(named: .arrow_clockwise),
clearTextFieldButtonGradient: LinearGradient? = Colors.gradient_1,
clearTextFieldButtonIconTintColor: Color = Colors.permanent_white.0,
clearTextFieldButtonBackgroundColor: Color = Colors.permanent_black.0,
clearTextFieldButtonShadowColor: Color = Colors.shadow_1.0
    
    /// Clears the textfield's current text entry
    var clearTextFieldButtonAction: (() -> Void) {
        return { [weak self] in
            guard let self = self else { return }
            self.textEntry.clear()
        }
    }
    
    var activeIcon: Image {
        return focused ? satelliteButtonActiveIcon : satelliteButtonInActiveIcon
    }
    
    init(title: String = "",
         placeholderText: String = "",
         textEntry: String = "")
    {
        self.title = title
        self.placeholderText = placeholderText
        self.textEntry = textEntry
    }
    
    func isEmpty() -> Bool {
        return self.textEntry.isEmpty
    }
    
    func configurator(configuration: @escaping ((SatelliteTextFieldModel)-> Void)) {
        configuration(self)
    }
}
