//
//  LaunchScreenManager.swift
//  Sauron
//
//  Created by Justin Cook on 12/23/22.
//

import Foundation

/// Manages the lifecycle and states of the launch screen
class LaunchScreenManager {
    
    // MARK: - Life Cycle Properties
    // In seconds [s]
    static var displayDuration: CGFloat = 2
    
    init() {}
    
    /// Closure to be run when the launch screen is done being displayed
    func onComplete(execute task: @escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + LaunchScreenManager.displayDuration) {
            task()
        }
    }
}
