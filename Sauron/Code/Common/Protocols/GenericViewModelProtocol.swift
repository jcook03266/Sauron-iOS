//
//  GenericViewModelProtocol.swift
//  Inspec
//
//  Created by Justin Cook on 11/12/22.
//

import SwiftUI

/// Basis for observable view models, allows a view to respond to changes within the target object's values
protocol GenericViewModel: ObservableObject, Identifiable {
    var id: UUID { get }
}

// MARK: - Implementations
extension GenericViewModel {
    var id: UUID {
        return UUID()
    }
}

/// View model that uses a coordinator object for navigation and routing
protocol CoordinatedGenericViewModel: GenericViewModel {
    associatedtype coordinator = any Coordinator
    
    // MARK: - Observed Object
    var coordinator: coordinator { get set }
}

/// Generic view model that conforms to the navigation protocol which allows for the movement between items in a collection, namely views to create a carousel of some sort
protocol NavigableGenericViewModel: CoordinatedGenericViewModel, GenericNavigationProtocol {
}

/// For view models that don't use navigation coordinators
protocol UncoordinatedNavigableGenericViewModel: GenericViewModel, GenericNavigationProtocol {
}
