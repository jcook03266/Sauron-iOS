//
//  ValidatorManager.swift
//  Sauron
//
//  Created by Justin Cook on 1/14/23.
//

import Foundation

/// Validation manager that encapsulates all supported validators
struct ValidatorManager {
    // MARK: - Properties
    var validators: [any Validator] {
        return [passcodeValidator]
    }
    
    // MARK: - Singleton
    static let shared: ValidatorManager = .init()
    
    // Initializing validators
    let passcodeValidator: PasscodeValidator = .init()
    
    private init() {}
    
    func getValidator(for validatorType: SupportedValidators) -> any Validator {
        switch validatorType {
        case .passcodeValidator:
            return passcodeValidator
        }
    }
    
    enum SupportedValidators: String, CaseIterable {
        case passcodeValidator
    }
}
