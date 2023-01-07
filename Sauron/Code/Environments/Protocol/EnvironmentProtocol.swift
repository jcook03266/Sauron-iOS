//
//  EnvironmentProtocol.swift
//  Sauron
//
//  Created by Justin Cook on 12/28/22.
//

import Foundation

/// Scope used to host various development level objects for ease of access
protocol Environment: Identifiable, Equatable, Hashable{
    associatedtype EnvironmentType: Environment
    
    var id: UUID { get }
    var scope: EnvironmentScopes { get } /// The domain of this environment, any elements outside of this domain cannot affect whatever lies inside of it
    static var shared: EnvironmentType { get } /// Singleton instance since this instance has to be shared across the entire application and instantiating it will be expensive
}

enum EnvironmentScopes: Identifiable, CaseIterable, Hashable {
    case dev
    case prod
    
    var id: String {
        UUID().uuidString
    }
}

/// Dependency Injection for accessing and injecting required environments from one centralized source of truth
protocol Environments {}

extension Environments {
    static func inject() -> DevEnvironment {
        return .shared
    }
}
