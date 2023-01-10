//
//  LanguageManager.swift
//  Sauron
//
//  Created by Justin Cook on 1/10/23.
//

import Foundation

/// A symbolic manager used to organize information pertaining to localized language support and preferences in this application, of which control is delegated to the system's preferences for app or system specific language settings
class LocalizedLanguageManager {
    // MARK: - Singleton
    static let shared: LocalizedLanguageManager = .init()
    
    // MARK: - Properties
    static let defaultLanguage: SupportedLanguages = .en
    
    // MARK: - Convenience
    var totalSupportedLanguages: Int {
        return SupportedLanguages.allCases.count
    }
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let appService: AppService = inject()
    }
    let dependencies = Dependencies()
    
    private init() {}
    
    /// Since changing the app's specific language isn't available programmatically, the user has to be prompted to go to the settings menu for the app to alter their preferences
    func goToAppSettings() {
        dependencies
            .appService
            .deepLinkManager
            .open(systemLink: .openSettings)
    }
    
    enum SupportedLanguages: String, CaseIterable, Hashable {
        case en
        
        func getDescription() -> String {
            switch self {
            case .en:
                return "English"
            }
        }
    }
}
