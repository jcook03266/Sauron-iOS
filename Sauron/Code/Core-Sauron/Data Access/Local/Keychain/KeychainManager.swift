//
//  KeychainManager.swift
//  Sauron
//
//  Created by Justin Cook on 1/14/23.
//

import Security
import Foundation

/// Manager used to manage keychain API operations and all possible key -> value pairs for secure sensitive user data storage
final class KeychainManager {
    // MARK: - All usable secure keys
    enum secureKeys: String, CaseIterable {
        case userIDKey, passcodeKey, lastUsedSaltKey
    }
    
    // MARK: - Mutation Methods
    /// Strings
    @discardableResult
    func save(key: secureKeys, value: String) -> Bool {
        guard let data = value.data(using: .utf8,
                                    allowLossyConversion: true)
        else { return false }
        
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ] as CFDictionary
        
        // Remove an old version of this key, if any exists
        remove(key: key)
        
        // Add key value pair to keychain
        let status: OSStatus = SecItemAdd(query, nil)
        let operationSuccessful = (status == noErr)
        
        guard operationSuccessful
        else {
            // Save unsuccessful
            ErrorCodeDispatcher.KeychainErrors.printErrorCode(for: .saveFailed(key: key.rawValue,
                                                                               value: value))
            
            return operationSuccessful
        }
        
        return operationSuccessful
    }
    
    /// Data
    @discardableResult
    func save(key: secureKeys, data: Data) -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ] as CFDictionary
        
        // Remove an old version of this key, if any exists
        remove(key: key)
        
        // Add key value pair to keychain
        let status: OSStatus = SecItemAdd(query, nil)
        let operationSuccessful = (status == noErr)
        
        guard operationSuccessful
        else {
            // Save unsuccessful
            ErrorCodeDispatcher.KeychainErrors.printErrorCode(for: .saveFailed(key: key.rawValue,
                                                                               value: data.debugDescription))
            
            return operationSuccessful
        }
        
        return operationSuccessful
    }
    
    @discardableResult
    /// All data types
    func remove(key: secureKeys) -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue
        ] as CFDictionary
        
        let status = SecItemDelete(query)
        let operationSuccessful = (status == noErr)
        
        guard operationSuccessful
        else {
            // Deletion Unsuccessful
            ErrorCodeDispatcher.KeychainErrors.printErrorCode(for: .deletionFailed(key: key.rawValue))
            
            return operationSuccessful
        }
        
        return operationSuccessful
    }
    
    /// Strings
    @discardableResult
    func update(key: secureKeys, newValue: String) -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue
        ] as CFDictionary
        
        // Set attributes for new password
        let attributes = [kSecValueData : newValue] as CFDictionary
        let status = SecItemUpdate(query, attributes)
        let operationSuccessful = (status == noErr)
        
        guard operationSuccessful
        else {
            // Update Unsuccessful
            ErrorCodeDispatcher.KeychainErrors.printErrorCode(for: .updateFailed(key: key.rawValue,
                                                                                 value: newValue))
            
            return operationSuccessful
        }
        
        return operationSuccessful
    }
    
    /// Data
    @discardableResult
    func update(key: secureKeys, newData: Data) -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue
        ] as CFDictionary
        
        // Set attributes for new password
        let attributes = [kSecValueData : newData] as CFDictionary
        let status = SecItemUpdate(query, attributes)
        let operationSuccessful = (status == noErr)
        
        guard operationSuccessful
        else {
            // Update Unsuccessful
            ErrorCodeDispatcher.KeychainErrors.printErrorCode(for: .updateFailed(key: key.rawValue,
                                                                                 value: newData.debugDescription))
            
            return operationSuccessful
        }
        
        return operationSuccessful
    }
    
    // MARK: - Data retrieval
    /// String
    func load(key: secureKeys) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var fetchedData: AnyObject?
        let status = SecItemCopyMatching(query, &fetchedData)
        
        guard status == noErr,
              let data = fetchedData as? Data,
              let string = NSString(data: data,
                                    encoding: String.Encoding.utf8.rawValue)
        else {
            // Load unsuccessful
            ErrorCodeDispatcher.KeychainErrors.printErrorCode(for: .loadFailed(key: key.rawValue))
            
            return nil
        }
        
        return string as String
    }
    
    /// Data
    func load(key: secureKeys) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var fetchedData: AnyObject?
        let status = SecItemCopyMatching(query, &fetchedData)
        
        guard status == noErr,
              let data = fetchedData as? Data
        else {
            // Load unsuccessful
            ErrorCodeDispatcher.KeychainErrors.printErrorCode(for: .loadFailed(key: key.rawValue))
            
            return nil
        }
        
        return data
    }
}
