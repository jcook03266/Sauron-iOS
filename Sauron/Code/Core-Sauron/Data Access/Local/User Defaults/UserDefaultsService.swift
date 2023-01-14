//
//  UserDefaultsService.swift
//  Sauron
//
//  Created by Justin Cook on 12/25/22.
//

import Foundation

/// Service used for interfacing with the UserDefaults API in order to store small as-needed data neccessary for customizing the application's UX. This data can be user progression dependent feature flags, and user preferences
class UserDefaultsService {
    /// Shared userdefaults database
    var shared: UserDefaults {
        guard let userDefaultsDatabase = UserDefaults(suiteName: self.databaseName)
        else {
            ErrorCodeDispatcher.UserDefaultsErrors.triggerFatalError(for: .invalidAppGroup)()
        }
        
        return userDefaultsDatabase
    }
    
    /// The name of the domain in which this user defaults database lies
    private var databaseName: String {
        return "group.com.Sauron"
    }
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
    }
    let dependencies = Dependencies()
    
    // MARK: - All UserDefaults Keys
    enum NonOptionalKeys: AssociatedEnum {
        static var allCases: [UserDefaultsService.NonOptionalKeys] = []
        
        typealias associatedValue = UserDefaultsValueKey<Any>
        
        // MARK: - FTUE Service
        /// By default the user has not completed the FTUE if the value for this key isn't found within the target suite
        case didCompleteFTUE(UserDefaultsValueKey<Any> = UserDefaultsValueKey<Any>("didCompleteFTUE",
                                                                                   defaultReturnValue: false))
        
        case didCompleteOnboarding(UserDefaultsValueKey<Any> = UserDefaultsValueKey<Any>("didCompleteOnboarding",
                                                                                         defaultReturnValue: false))
        
        // MARK: - Currency Manager
        case userPreferredFiatCurrency(UserDefaultsValueKey<Any> = UserDefaultsValueKey<Any>("userPreferredFiatCurrency",
                                                                                             defaultReturnValue: FiatCurrencyManager.defaultCurrency.rawValue))
        
        // MARK: - Portfolio Coin Sorting
        case portfolioCoinSortKey(UserDefaultsValueKey<Any> = UserDefaultsValueKey<Any>("portfolioCoinSortKey",
                                                                                        defaultReturnValue: CoinStore.defaultSortKey.rawValue))
        
        case portfolioCoinAscendingSortOrder(UserDefaultsValueKey<Any> = UserDefaultsValueKey<Any>("portfolioAscendingSortOrder",
                                                                                                   defaultReturnValue: CoinStore.defaultAscendingSortOrder))
        
        func getAssociatedValue() -> UserDefaultsValueKey<Any> {
            switch self {
            case .didCompleteFTUE(let value):
                return value
            case .didCompleteOnboarding(let value):
                return value
            case .userPreferredFiatCurrency(let value):
                return value
            case .portfolioCoinSortKey(let value):
                return value
            case .portfolioCoinAscendingSortOrder(let value):
                return value
            }
        }
    }
    
    /// Reserved
    enum OptionalKeys: AssociatedEnum {
        static var allCases: [UserDefaultsService.OptionalKeys] = []
        
        typealias associatedValue = UserDefaulsOptionalKey<Any?>
        
        case base_implementation(UserDefaulsOptionalKey<Any?> =  UserDefaulsOptionalKey<Any?>("base_implementation"))
        
        func getAssociatedValue() -> UserDefaulsOptionalKey<Any?> {
            return .init("")
        }
    }
    
    enum OptionalURLKeys: AssociatedEnum {
        static var allCases: [UserDefaultsService.OptionalURLKeys] = []
        
        typealias associatedValue = UserDefaulsOptionalKey<URL?>
        
        // MARK: - Deeplink Manager
        case lastActiveDeeplink(UserDefaulsOptionalKey<URL?> =  UserDefaulsOptionalKey<URL?>("lastActiveDeeplink"))
        
        func getAssociatedValue() -> UserDefaulsOptionalKey<URL?> {
            switch self {
            case .lastActiveDeeplink(let value):
                return value
            }
        }
    }
    
    // MARK: - Get set methods for all supported keys
    // MARK: - Non-Optional Keys
    /// Note: Specifying the type 't' gives the compiler enough information to interpret the return type even if the generic function isn't specialized
    func getValueFor<T: Any>(type t: T.Type, key: NonOptionalKeys) -> T {
        guard let value = shared[key.getAssociatedValue()] as? T
        else {
            ErrorCodeDispatcher.UserDefaultsErrors.triggerFatalError(for: .mismatchingGenericTypes,
                                                                     with: "\(#function) in \(#file) for type: \(T.self)")()
        }
        
        return value
    }
    
    func setValueFor<T: Any>(type t: T.Type, key: NonOptionalKeys, value: T){
        shared[key.getAssociatedValue()] = value
    }
    
    func removeValueFor(key: NonOptionalKeys){
        let key = key.getAssociatedValue().literalValue
        
        shared.removeObject(forKey: key)
    }
    
    // MARK: - Optional Keys
    func getValueFor<T: Any>(type t: T.Type, key: OptionalKeys) -> T? {
        return shared[key.getAssociatedValue()] as? T
    }
    
    func setValueFor<T: Any>(type t: T.Type,
                             key: OptionalKeys,
                             value: T?)
    {
        shared[key.getAssociatedValue()] = value
    }
    
    func removeValueFor(key: OptionalKeys){
        let key = key.getAssociatedValue().literalValue
        
        shared.removeObject(forKey: key)
    }
    
    // MARK: - Optional URL Keys
    func getValueFor(key: OptionalURLKeys) -> URL? {
        return shared[key.getAssociatedValue()]
    }
    
    func setValueFor(key: OptionalURLKeys,
                     value: URL?)
    {
        shared[key.getAssociatedValue()] = value
    }
    
    func removeValueFor(key: OptionalURLKeys){
        let key = key.getAssociatedValue().literalValue
        
        shared.removeObject(forKey: key)
    }
}

