//
//  UserDefaults+SubscriptExtensions.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import Foundation

// MARK: - Statically typed subscript access to the UserDefaults API
extension UserDefaults {
    class Key {
        let literalValue: String
        init(_ key: String) { literalValue = key }
    }
}

class UserDefaulsOptionalKey<T>: UserDefaults.Key {}

extension UserDefaults {
    subscript(key: UserDefaulsOptionalKey<Any?>) -> Any? {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) }
    }

    subscript(key: UserDefaulsOptionalKey<URL?>) -> URL? {
        set { set(newValue, forKey: key.literalValue) }
        get { return url(forKey: key.literalValue) }
    }

    subscript(key: UserDefaulsOptionalKey<[Any]?>) -> [Any]? {
        set { set(newValue, forKey: key.literalValue) }
        get { return array(forKey: key.literalValue) }
    }

    subscript(key: UserDefaulsOptionalKey<[AnyHashable: Any]?>) -> [AnyHashable: Any]? {
        set { set(newValue, forKey: key.literalValue) }
        get { return dictionary(forKey: key.literalValue) }
    }

    subscript(key: UserDefaulsOptionalKey<String?>) -> String? {
        set { set(newValue, forKey: key.literalValue) }
        get { return string(forKey: key.literalValue) }
    }

    subscript(key: UserDefaulsOptionalKey<[String]?>) -> [String]? {
        set { set(newValue, forKey: key.literalValue) }
        get { return stringArray(forKey: key.literalValue) }
    }
    
    subscript(key: UserDefaulsOptionalKey<Date?>) -> Date? {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? Date }
    }

    subscript(key: UserDefaulsOptionalKey<Data?>) -> Data? {
        set { set(newValue, forKey: key.literalValue) }
        get { return data(forKey: key.literalValue) }
    }

    subscript(key: UserDefaulsOptionalKey<Bool?>) -> Bool? {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? Bool }
    }

    subscript(key: UserDefaulsOptionalKey<Int?>) -> Int? {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? Int }
    }

    subscript(key: UserDefaulsOptionalKey<Float?>) -> Float? {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? Float }
    }

    subscript(key: UserDefaulsOptionalKey<Double?>) -> Double? {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? Double }
    }
}

// MARK: - Enable support for Enum types
extension UserDefaults {
    subscript<Raw>(key: UserDefaultsValueKey<Raw>) -> Raw where Raw: RawRepresentable {
        set { set(newValue.rawValue, forKey: key.literalValue) }
        get {
            if let rawValue = object(forKey: key.literalValue) as? Raw.RawValue,
               let value = Raw(rawValue: rawValue) {
                return value
            }
            return key.defaultReturnValue
        }
    }

    subscript<Raw>(key: UserDefaulsOptionalKey<Raw?>) -> Raw? where Raw: RawRepresentable {
        set { set(newValue?.rawValue, forKey: key.literalValue) }
        get {
            if let rawValue = object(forKey: key.literalValue) as? Raw.RawValue,
               let value = Raw(rawValue: rawValue) {
                return value
            }
            return nil
        }
    }

    func removeObject(forKey key: UserDefaults.Key) {
        removeObject(forKey: key.literalValue)
    }
}

// MARK: - Keys for non-optional types
class UserDefaultsValueKey<T>: UserDefaults.Key {
    /// If a value can't be retrieved for the specified key then this default value is fell back on
    let defaultReturnValue: T
    
    init(_ key: String, defaultReturnValue: T) {
        self.defaultReturnValue = defaultReturnValue
        super.init(key)
    }
}

extension UserDefaults {
    subscript(key: UserDefaultsValueKey<Any>) -> Any {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) ?? key.defaultReturnValue }
    }

    subscript(key: UserDefaultsValueKey<URL>) -> URL {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? URL ?? key.defaultReturnValue }
    }

    subscript(key: UserDefaultsValueKey<[Any]>) -> [Any] {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? [Any] ?? key.defaultReturnValue }
    }

    subscript(key: UserDefaultsValueKey<[AnyHashable: Any]>) -> [AnyHashable: Any] {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? [AnyHashable: Any] ?? key.defaultReturnValue }
    }

    subscript(key: UserDefaultsValueKey<String>) -> String {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? String ?? key.defaultReturnValue }
    }

    subscript(key: UserDefaultsValueKey<[String]>) -> [String] {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? [String] ?? key.defaultReturnValue }
    }
    
    subscript(key: UserDefaultsValueKey<Date>) -> Date {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? Date ?? key.defaultReturnValue }
    }

    subscript(key: UserDefaultsValueKey<Data>) -> Data {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? Data ?? key.defaultReturnValue }
    }

    subscript(key: UserDefaultsValueKey<Bool>) -> Bool {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? Bool ?? key.defaultReturnValue }
    }

    subscript(key: UserDefaultsValueKey<Int>) -> Int {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? Int ?? key.defaultReturnValue }
    }

    subscript(key: UserDefaultsValueKey<Float>) -> Float {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? Float ?? key.defaultReturnValue }
    }

    subscript(key: UserDefaultsValueKey<Double>) -> Double {
        set { set(newValue, forKey: key.literalValue) }
        get { return object(forKey: key.literalValue) as? Double ?? key.defaultReturnValue }
    }
}
