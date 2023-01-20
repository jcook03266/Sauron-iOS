//
//  PasscodeAuthCredentialModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/14/23.
//

import Foundation

/// A token used to prove a user has the authorization to access the app's main content given some criteria such as a passcode validation or no validation as per user request / by default for new users
struct PasscodeAuthToken: Identifiable, Hashable {
    // Conformance
    var id: UUID = .init()
    
    // MARK: - Life Cycle properties
    let creationDate: Date = .now,
        expirationDate: Date
    
    var isValid: Bool {
        return Date.now < expirationDate
    }
    
    init(expirationDate: Date) {
        self.expirationDate = expirationDate
    }
}
