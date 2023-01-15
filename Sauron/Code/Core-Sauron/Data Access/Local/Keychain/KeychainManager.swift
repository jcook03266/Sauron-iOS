//
//  KeychainManager.swift
//  Sauron
//
//  Created by Justin Cook on 1/14/23.
//

import Security
import Foundation

/// Manager used to manage keychain operations and all possible key -> value pairs for secure sensitive user data storage
final class KeychainManager {
    // MARK: - Mutation Methods
    @discardableResult
    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8,
                                    allowLossyConversion: true)
        else { return false }
        
        var query: [CFString : Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key as AnyObject,
            kSecValueData: data as AnyObject,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Remove an old version of this key, if any exists
        remove(key: key)
        
        // Add key value pair to keychain
        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        let operationSuccessful = (status == noErr)
        
        guard operationSuccessful
        else {
            // Save unsuccessful
            ErrorCodeDispatcher.KeychainErrors.printErrorCode(for: .saveFailed(key: key,
                                                                               value: value))
            
            return operationSuccessful
        }
        
        return operationSuccessful
    }
    
    @discardableResult
    func remove(key: String) -> Bool {
        let query: [CFString : Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        let operationSuccessful = (status == noErr)
        
        guard operationSuccessful
        else {
            // Deletion Unsuccessful
            ErrorCodeDispatcher.KeychainErrors.printErrorCode(for: .deletionFailed(key: key))
            
            return operationSuccessful
        }
        
        return operationSuccessful
    }
    
    @discardableResult
    func update(key: String, newValue: String) -> Bool {
        let query: [CFString : Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        
        // Set attributes for new password
        let attributes: [String : Any] = [kSecValueData as String : newValue]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        let operationSuccessful = (status == noErr)
        
        guard operationSuccessful
        else {
            // Update Unsuccessful
            ErrorCodeDispatcher.KeychainErrors.printErrorCode(for: .updateFailed(key: key,
                                                                                 value: newValue))
            
            return operationSuccessful
        }
        
        return operationSuccessful
    }
    
    // MARK: - Data retrieval
    func load(key: String) -> String? {
        let query: [CFString : Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnAttributes: true
        ]
        
        var fetchedData: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &fetchedData)
        
        guard status == noErr,
              let data = fetchedData as? Data,
              let string = NSString(data: data,
                                    encoding: String.Encoding.utf8.rawValue)
        else {
            // Load unsuccessful
            ErrorCodeDispatcher.KeychainErrors.printErrorCode(for: .loadFailed(key: key))
            
            return nil
        }
        
        return string as String
    }
}
