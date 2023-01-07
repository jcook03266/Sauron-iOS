//
//  DeeplinkManager.swift
//  Inspec
//
//  Created by Justin Cook on 11/13/22.
//

import Foundation

class DeepLinkManager {
    
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
