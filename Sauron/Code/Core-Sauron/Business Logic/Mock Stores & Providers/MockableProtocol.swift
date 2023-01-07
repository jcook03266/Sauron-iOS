//
//  MockableProtocol.swift
//  Sauron
//
//  Created by Justin Cook on 12/29/22.
//

import Foundation

/// When it comes to developing dynamic applications dependent on transient data that has to be loaded asynchronously, it's best to mock this async data in order to speed up the development process and to prevent over usage of APIs. This protocol defines the basis for this application state by providing a branching point for data providers and stores to transition to their mock implementations
protocol Mockable {
    // MARK: - Debug environment variables
    var mockEnvironment: Bool { get }
}

extension Mockable {
    var mockEnvironment: Bool {
        return AppService.useMockData
    }
}
