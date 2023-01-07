//
//  AppInformation.swift
//  Inspec
//
//  Created by Justin Cook on 12/1/22.
//

import Foundation

/// Accessors for static run-time information about the application
open class AppInformation {
    static var shared: AppInformation = .init()
    
    // MARK: - Versioning
    static var buildID: Int {
        return Bundle.main.buildID
    }
    static var releaseVersion: String {
        return Bundle.main.releaseVersion
    }
    static var version: String {
        return "v\(Bundle.main.version)"
    }
    // MARK: - Debug / Production Modes
    static var isProduction: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
    
    private init() {}
}
