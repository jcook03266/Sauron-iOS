//
//  RoutesProtocol.swift
//  Sauron
//
//  Created by Justin Cook on 1/14/23.
//

import Foundation

// MARK: - Generic protocol for all routes to conform to
protocol RoutesProtocol {
    var id: String { get }
}

/// Identifiable conformance implementation
extension RoutesProtocol {
    var id: String {
        return UUID().uuidString
    }
}
