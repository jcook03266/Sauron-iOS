//
//  ObservableArray.swift
//  Inspec
//
//  Created by Justin Cook on 11/5/22.
//
import SwiftUI
import Combine

/// Allows an array of objects to be observed for changes
/// Concept: An array of objects only notifies its subscribers when an object has been added or removed, an array of structs is an array of values, so when those values change then the subscriber is updated appropriately; to provide the same functionality for an array of objects a sink is attached to each value in the respective array
class ObservableArray<T: ObservableObject>: ObservableObject {
    var cancellables = [AnyCancellable]()
    var array: [T] = []
    /// Notifies the parent observable object of a change in the array's objects' values
    var parentObjectWillChange: ObservableObjectPublisher? = nil
    
    func observeChildren() {
        cancellables = []
        
        self.array.forEach({
            // Observe values received by publisher
            let cancellable = $0.objectWillChange.sink(receiveValue: { _ in
                // Notify subscribers of changes
                self.parentObjectWillChange?.send()
            })
            
            // Sink subscription is cancelled if the received value isn't allocated
            self.cancellables.append(cancellable)
        })
    }
    
    init(array: [T] = [],
         parentObjectWillChange: ObservableObjectPublisher? = nil)
    {
        self.array = array
        self.parentObjectWillChange = parentObjectWillChange
    }
}
