//
//  NumberDataTypeExtensions.swift
//  Inspec
//
//  Created by Justin Cook on 11/11/22.
//

import Foundation

// MARK: - Numeric Data type Extensions
// MARK: - Integer
extension Int: Increments {
    public func incrementBy<T>(_ num: T) -> T where T : Numeric{
        guard let self = self as? T
        else {
            preconditionFailure("Error: could not convert self to generic type T: Numeric, Function: \(#function)")
        }
        
        return incrementBy(self: self, num)
    }
    
    public mutating func mutatingIncrementBy<T>(_ num: T) where T : Numeric {
        guard var self = self as? T
        else {
            preconditionFailure("Error: could not convert self to generic type T: Numeric, Function: \(#function)")
        }
        
        mutatingIncrementBy(self: &self, num)
    }
    
    public func decrementBy<T>(_ num: T) -> T where T : Numeric {
        guard let self = self as? T
        else {
            preconditionFailure("Error: could not convert self to generic type T: Numeric, Function: \(#function)")
        }
        
        return decrementBy(self: self, num)
    }
    
    public mutating func mutatingDecrementBy<T>(_ num: T) where T : Numeric {
        guard var self = self as? T
        else {
            preconditionFailure("Error: could not convert self to generic type T: Numeric, Function: \(#function)")
        }
        
        mutatingDecrementBy(self: &self, num)
    }
}

// MARK: - Protocols for implementing useful functions across multiple numerical data types
public protocol Increments {
    func incrementBy<T: Numeric>(_ num: T) -> T
    mutating func mutatingIncrementBy<T: Numeric>(_ num: T)
    
    func decrementBy<T: Numeric>(_ num: T) -> T
    mutating func mutatingDecrementBy<T: Numeric>(_ num: T)
}

extension Increments {
    func incrementBy<T: Numeric>(self: T, _ num: T) -> T {
        return self + num
    }
    mutating func mutatingIncrementBy<T: Numeric>( self: inout T, _ num: T) {
        self += num
    }
    func decrementBy<T: Numeric>(self: T, _ num: T) -> T {
        return self - num
    }
    mutating func mutatingDecrementBy<T: Numeric>( self: inout T, _ num: T) {
        self -= num
    }
}
