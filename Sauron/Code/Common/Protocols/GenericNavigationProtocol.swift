//
//  GenericNavigationProtocol.swift
//  Inspec
//
//  Created by Justin Cook on 11/12/22.
//

import SwiftUI

/// Generic navigation functions that enable useful logic for forward and backward sequential and random traversal
protocol GenericNavigationProtocol: AnyObject {
    func moveForward()
    func moveBackward()
    func skipToFirst()
    func skipToLast()
}
