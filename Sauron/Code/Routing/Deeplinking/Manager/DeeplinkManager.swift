//
//  DeeplinkManager.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import Foundation

final class DeepLinkManager: ObservableObject {
    // MARK: - Published
    @Published var activeDeepLinkTarget: URL? = nil
    
    // MARK: - Singleton
    static let shared: DeepLinkManager = .init()
    
    // MARK: - Properties
    var deeplinkHandlers: [any DeeplinkHandlerProtocol] = []
    
    private init() {
        setup()
    }
    
    private func setup() {
        injectHandlers()
    }
}

extension DeepLinkManager: DeeplinkManagerProtocol {
    func injectHandlers() {
        deeplinkHandlers = [
            OnboardingDeeplinkHandler(manager: self)
        ]
    }
}

extension DeepLinkManager {
    class DeepLinkConstants {
        static let scheme = "Sauron"
        static let suffix = "://"
        static let identifier = "com.Sauron.deeplinker"
        static let queryTag = "q"
        static let portfolioCoinsOnlyFilterTag = "pcf"
    }
}
