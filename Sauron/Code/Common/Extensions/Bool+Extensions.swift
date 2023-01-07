//
//  Bool+Extensions.swift
//  Sauron
//
//  Created by Justin Cook on 1/6/23.
//

import Foundation

extension Bool {
    /// XOR Operator for Boolean type, already exists for int
    static func ^ (left: Bool, right: Bool) -> Bool {
        return left != right
    }
    
    /// Implicitly performs XOR operation on a list of operands instead of explicitly stating it
    static func XOR(operands: [Bool]) -> Bool {
        guard var condition: Bool = operands.first else { return false }
        
        for (index, bool) in operands.enumerated() {
            if index == 0 { continue }
            
            condition = condition ^ bool
        }
        
        return condition
    }
}
