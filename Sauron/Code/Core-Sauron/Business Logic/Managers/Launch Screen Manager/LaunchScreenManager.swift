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
    var isComplete: Bool = false
    
    // MARK: - Singleton
    static let shared: LaunchScreenManager = .init()
    
    private init() {}
    
    /// Closure to be run when the launch screen is done being displayed
    func onComplete(execute task: @escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + LaunchScreenManager.displayDuration) { [weak self] in
                guard let self = self else { return }
                
                self.isComplete = true
            task()
        }
    }
}
