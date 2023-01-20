//
//  PasscodeValidator.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import Foundation
 
/// A static object that validates the passcode for the auth screen
/// Note: This is not used to match the passcode with its expected value, rather it's used to force the conformance of the entered text to the required criteria, authentication is done separately
struct PasscodeValidator: Validator {
    typealias CriteriaKeysEnumType = CriteriaKeys
    
    // MARK: - Validation Criteria
    /// Important: This is also defined by the validator and should not be changed unless all other implicit references to this value are updated
    static let maxPasscodeLength: Int = 4
    
    /// The user's entered passcode must contain a four digit combination
    var validationCriteria: [String : Any] {
        return [CriteriaKeys.regex.rawValue : "^[0-9]{4}$"]
    }
    
    func validate(_ input: String) -> Bool {
        guard let regex = getCriteriaFor(key: .regex) as? String
        else { return false }
        
       return executeRegex(input: input, expression: regex)
    }
    
    func getCriteriaFor(key: CriteriaKeys) -> Any? {
        return validationCriteria[key.rawValue]
    }
    
    enum CriteriaKeys: String, CaseIterable {
        case regex
    }
}
