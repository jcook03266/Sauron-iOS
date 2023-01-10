//
//  DeeplinkManager.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import Foundation

class DeepLinkManager: ObservableObject {
    // MARK: - Singleton
    static let shared: DeepLinkManager = .init()
    
    // MARK: - Dependencies
    let systemLinker: SystemLinker = .shared
    
    private init() {}
    
    func manage(url: URL) -> DeepLinkTarget {
        guard url.scheme == DeepLinkConstants.scheme,
              url.host == DeepLinkConstants.host,
              url.path == DeepLinkConstants.detailsPath,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems
        else { return .builds }
        
        let query = queryItems.reduce(into: [String : String]()) { (result, item) in
            result[item.name] = item.value
        }
        
        guard let id = query[DeepLinkConstants.query] else { return .builds }
        return .details(reference: id)
    }
    
    // MARK: - System Linker Interface
    func open(systemLink: SystemLinker.Links) {
        systemLinker.open(link: systemLink)
    }
}

extension DeepLinkManager {
    enum DeepLinkTarget: Equatable {
        case builds
        case details(reference: String)
    }
    
    class DeepLinkConstants {
        static let scheme = "https"
        static let host = "com.Sauron"
        static let detailsPath = "/details"
        static let query = "id"
    }
}
