//
//  SystemLinker.swift
//  Sauron
//
//  Created by Justin Cook on 1/10/23.
//

import Foundation
import UIKit

/// A static linker that opens up links pointing to global system wide locations such as the settings menu
struct SystemLinker {
    // MARK: - Singleton
    static let shared: SystemLinker = .init()
    
    // MARK: - Properties
    let applicationInterface = UIApplication.shared
    
    private init() {}
    
    func open(link: Links) {
        guard let linkURL = getURL(for: link)
        else { return }
        
        applicationInterface.open(linkURL)
    }
    
    private func getURL(for link: Links) -> URL? {
        switch link {
        case .openSettings:
            return UIApplication.openSettingsURLString.asURL
        }
    }
    
    enum Links: String, CaseIterable, Hashable {
        case openSettings
    }
}
