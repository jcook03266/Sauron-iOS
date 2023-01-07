//
//  Router.swift
//  Inspec
//
//  Created by Justin Cook on 11/15/22.
//

import SwiftUI

/// Responsibilities: Knows how to create views, create views, presents views, and dismisses views
public protocol Routable: ObservableObject {
    typealias RouteType = Hashable & CaseIterable
    associatedtype coordinator: Coordinator
    associatedtype Route: RouteType
    associatedtype Body: View
    
    var coordinator: coordinator { get }
    
    @ViewBuilder func view(for route: Route) -> Self.Body
    
    /// Optional func for abstracting the intialization of any retained view models by the router
    func initViewModels() -> Void
}

extension Routable {
    func initViewModels() {}
}
