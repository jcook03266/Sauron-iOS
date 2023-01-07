//
//  SheathedTextFieldModel.swift
//  Inspec
//
//  Created by Justin Cook on 11/23/22.
//

import SwiftUI

class SheathedTextFieldModel: SheathedTextFieldModelProtocol {
    // MARK: - Properties
    let id: UUID = .init()
    
    var keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = .username,
        textInputAutocapitalization: TextInputAutocapitalization = .never,
        submitLabel: SubmitLabel = .done,
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
    @Published var textEntry: String {
        didSet {
            guard entryValidationEnabled else { return }
            
            shouldValidateEntry = !textEntry.isEmpty
            executeValidationCondition()
        }
    }
    @Published var enabled: Bool = true
    @Published var focused: Bool = false
    @Published var unsheathed: Bool = false
    @Published var protected: Bool = false
    
    // Entry validation
    @Published var validEntry: Bool = false
    @Published var shouldValidateEntry: Bool = false
    /// Set this to enable or disable entry validation visual indication entirely
    @Published var entryValidationEnabled: Bool = false
    var validationCondition: ((String) -> Bool)? = nil
    
    // MARK: - Styling
    // Main Icon
    var icon: Image?,
        iconColor: Color? = Colors.permanent_white.0,
        
        // MARK: - General Properties
        // Interior
        fieldBackgroundColor: Color = Colors.white.0,
        textFieldTextColor: Color = Colors.black.0,
        textColor: Color = Colors.permanent_white.0,
        borderColor: Color = Colors.primary_1.0,
        sheatheColor: Color = Colors.primary_1.0,
        textFont: FontRepository = .body_S,
        fontWeight: Font.Weight = .semibold,
        
        // Exterior / Shadow
        invalidEntryGlow: Color? = Colors.attention.0,
        validEntryGlow: Color? = Colors.primary_2.0,
        defaultShadowColor: Color? = Colors.shadow_1.0,
        shadowRadius: CGFloat? = 0,
        shadowOffset: CGSize? = CGSize(width: 0, height: 6)
    
    var shadowColor: Color? {
        return entryValidationEnabled && shouldValidateEntry ? (validEntry ? validEntryGlow : invalidEntryGlow) : defaultShadowColor
    }
    
    // MARK: - Optional in-field button properties
    var inFieldButtonIcon: Image? = nil,
        inFieldButtonAction: (() -> Void)? = nil,
        inFieldButtonIconTint: Color? = Colors.neutral_500.0
    
    init(title: String = "",
         placeholderText: String = "",
         textEntry: String = "")
    {
        self.title = title
        self.placeholderText = placeholderText
        self.textEntry = textEntry
    }
    
    func configurator(configuration: @escaping ((SheathedTextFieldModel)-> Void)) {
        configuration(self)
    }
}
