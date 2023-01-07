//
//  AssociatedEnum.swift
//  Inspec
//
//  Created by Justin Cook on 12/1/22.
//

import Foundation

/** Protocol for retrieving generic associated values from an enum*/
protocol AssociatedEnum: CaseIterable {
    associatedtype associatedValue: Any
    
    func getAssociatedValue() -> associatedValue
}
