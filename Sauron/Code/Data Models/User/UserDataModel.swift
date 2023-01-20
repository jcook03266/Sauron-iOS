//
//  UserDataModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/14/23.
//

import Foundation
import SwiftUI

/// Object used to store basic offline information about a Sauron user
final class SRNUser: ObservableObject {
    /// A unique identifier used to classify the user's information, this isn't tied to an online identity, moreover it's used to encapsulate all data under one domain specific to this user
    var userID: UUID {
        get {
            guard let userID: String = dependencies.keychainManager.load(key: .userIDKey),
                  let uuid = UUID(uuidString: userID)
            else { return .init() }
            
            return uuid
        }
        set {
            dependencies.keychainManager.save(key: .userIDKey,
                                          value: newValue.uuidString)
        }
    }
    
    /// A securely encrypted optional pincode used by the user to authenticate themselves into the application
    var password: String? {
        get {
            return dependencies.keychainManager.load(key: .passcodeKey)
        }
        set {
            guard let newValue = newValue
            else { return }
            
            dependencies.keychainManager.save(key: .passcodeKey,
                                          value: newValue)
        }
    }
    
    // MARK: - Preferences
    var userPreferredAuthTokenLifeCycleDuration: SRNUserAuthenticator.AuthTokenLifeCycle {
        get {
            let rawValue = dependencies
                .userDefaultsService
                .getValueFor(type: SRNUserAuthenticator.AuthTokenLifeCycle.RawValue.self,
                             key: .userAuthTokenLifeCyclePreference())
            
            return SRNUserAuthenticator.AuthTokenLifeCycle(rawValue: rawValue) ?? SRNUserAuthenticator.defaultAuthTokenLifeCycleDuration
        }
        set {
            dependencies
                .userDefaultsService
                .setValueFor(type: SRNUserAuthenticator.AuthTokenLifeCycle.RawValue.self,
                             key: .userAuthTokenLifeCyclePreference(),
                             value: newValue.rawValue)
        }
    }
    
    var userPreferredAuthMethod: SRNUserAuthenticator.AuthMethod {
        get {
            let rawValue = dependencies
                .userDefaultsService
                .getValueFor(type: SRNUserAuthenticator.AuthMethod.RawValue.self,
                             key: .userAuthMethodPreference())
            
            return SRNUserAuthenticator.AuthMethod(rawValue: rawValue) ?? SRNUserAuthenticator.defaultAuthMethod
        }
        set {
            dependencies
                .userDefaultsService
                .setValueFor(type: SRNUserAuthenticator.AuthMethod.RawValue.self,
                             key: .userAuthMethodPreference(),
                             value: newValue.rawValue)
        }
    }
    
    // MARK: - Authentication properties
    var isAuthenticated: Bool {
        return dependencies.authService.currentAuthCredential != nil
    }
    
    var hasPasscode: Bool {
        return password != nil
    }
    
    var isNewUser: Bool = false
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        lazy var userDefaultsService: UserDefaultsService = SRNUser.Dependencies.inject()
        lazy var keychainManager: KeychainManager = SRNUser.Dependencies.inject()
        lazy var authService: SRNUserAuthenticator = SRNUser.Dependencies.inject()
    }
    var dependencies = Dependencies()
    
    init() {
        setup()
    }
    
    private func setup() {
        determineIfNewUser()
    }
    
    private func determineIfNewUser() {
        let userID: String? = dependencies
            .keychainManager
            .load(key: .userIDKey)
        
        isNewUser = userID != nil
    }
}
