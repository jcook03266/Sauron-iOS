//
//  DeeplinkManagerProtocol.swift
//  Sauron
//
//  Created by Justin Cook on 1/12/23.
//

import Foundation

/// Defines the conformance criteria for the centralized deep link manager used by the app
protocol DeeplinkManagerProtocol {
    // MARK: - Instance Variables
    // Published
    var activeDeepLinkTarget: URL? { get set }
    // Static
    var lastActiveLink: URL? { get set }
    
    // MARK: - Singleton
    static var shared: DeepLinkManager { get }
    
    // Dependencies
    var systemLinker: SystemLinker { get }
    var rootCoordinatorDelegate: RootCoordinatorDelegate { get }
    
    // Handlers
    /// Responsibility chain
    var deeplinkHandlers: [any DeeplinkHandlerProtocol] { get set }
    
    // MARK: - Navigation & Handler Chain Response logic
    func manage(_ url: URL)
    func injectHandlers()
    func switchActiveRoot(to coordinator: RootCoordinatorDispatcher.RootCoordinators)
    func openLastActiveLink()
    func printLastActiveLinkDebugDescription()
    mutating func setActiveDeepLinkTarget(to target: URL)
    
    // MARK: - System Linker Interface
    func open(systemLink: SystemLinker.Links)
}

// MARK: - Implementations
extension DeeplinkManagerProtocol {
    var systemLinker: SystemLinker { return .shared }
    
    var rootCoordinatorDelegate: RootCoordinatorDelegate {
        return .shared
    }
    
    /// Manages the responsibility chain of the handlers by passing the URL to the handler that can open it
    func manage(_ url: URL) {
        guard let handler = deeplinkHandlers.first(where: { $0.canOpenURL(url) })
        else {
            ErrorCodeDispatcher
                .DeeplinkingErrors
                .printErrorCode(for: .noHandlerFoundFor(url: url))
            
            return
        }
        
        handler.openURL(url)
    }
    
    func switchActiveRoot(to coordinator: RootCoordinatorDispatcher.RootCoordinators) {
        rootCoordinatorDelegate.switchActiveRoot(to: coordinator)
    }
    
    func openLastActiveLink() {
        guard let lastActiveLink = lastActiveLink
        else { return }
        
        self.manage(lastActiveLink)
    }
    
    /// Debugging
    func printLastActiveLinkDebugDescription() {
        print("🔗 Last Active Deeplink: \(lastActiveLink?.description ?? "None")")
    }
    
    mutating func setActiveDeepLinkTarget(to target: URL) {
        activeDeepLinkTarget = target
        lastActiveLink = target
    }
    
    func open(systemLink: SystemLinker.Links) {
        systemLinker.open(link: systemLink)
    }
}
