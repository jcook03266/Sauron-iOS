//
//  DeeplinkBuilder.swift
//  Sauron
//
//  Created by Justin Cook on 1/14/23.
//

import Foundation

/// A builder designed to build out deep links for a general section of the application given the router directory supplied. Also supports parameters and arguments, as well as a URL fragment across both URI deeplinks and URL universal links\
/// - Ex: Deeplink -> sauron://onboarding/
/// - Ex: Universal link -> https://www.sauron.io/onboarding/
final class DeepLinkBuilder {
    typealias Router = LaunchScreenRouter
    
    // MARK: - Properties
    // Static
    var routerDirectory: RouteDirectories
    var directories: [String]
    var parameters: [String : String]
    var fragment: String
    
    // Dynamic
    var currentDeeplink: URL? = nil
    var currentUniversalLink: URL? = nil
    
    init(routerDirectory: RouteDirectories,
         directories: [String] = [],
         parameters: [String : String] = [:],
         fragment: String = "")
    {
        self.routerDirectory = routerDirectory
        self.directories = directories
        self.parameters = parameters
        self.fragment = fragment
        
        self.currentDeeplink = DeepLinkBuilder.buildDeeplinkFor(routerDirectory: routerDirectory,
                                     directories: directories,
                                     parameters: parameters,
                                     fragment: fragment)
        
        self.currentUniversalLink = DeepLinkBuilder.buildUniversalDeeplinkFor(routerDirectory: routerDirectory,
                               directories: directories,
                               parameters: parameters,
                               fragment: fragment)
    }
    
    @discardableResult
    static func buildDeeplinkFor(routerDirectory: RouteDirectories,
                                      directories: [String] = [],
                                      parameters: [String : String] = [:],
                                      fragment: String = "") -> URL?
    {
        var urlString = ""
        let scheme = DeepLinkManager.DeepLinkConstants.scheme,
            schemeSuffix = DeepLinkManager.DeepLinkConstants.schemeSuffix,
            host = routerDirectory.rawValue.getURLSafeString(),
            parameterStub = DeepLinkManager.DeepLinkConstants.parameterStub,
            fragmentStub = DeepLinkManager.DeepLinkConstants.fragmentStub,
            directorySlash = DeepLinkManager.DeepLinkConstants.directorySlash,
            parameterChainer = DeepLinkManager.DeepLinkConstants.parameterChainer,
            parameterEquator = DeepLinkManager.DeepLinkConstants.parameterEquator
        
        urlString += scheme
        urlString += schemeSuffix
        urlString += host // Path for deeplinks
        urlString += directorySlash
        
        // Directories
        for directory in directories {
            urlString += directory.getURLSafeString()
            urlString += directorySlash
        }
        
        // Parameters
        if !parameters.isEmpty {
            urlString += parameterStub
            
            /// Append parameters and arguments onto the URL string, and concatenate these parameters with an ampersand
            for (index, (parameter, argument)) in parameters.enumerated() {
                if index != 0 { urlString += parameterChainer}
                urlString += "\(parameter)\(parameterEquator)\(argument)"
            }
        }
        
        // Fragment [Only one fragment is allowed]
        if !fragment.isEmpty {
            urlString += directorySlash
            urlString += fragmentStub
            urlString += fragment.getURLSafeString()
        }
  
        return urlString.asURL
    }
    
    @discardableResult
    static func buildUniversalDeeplinkFor(routerDirectory: RouteDirectories,
                                directories: [String] = [],
                                parameters: [String : String] = [:],
                                fragment: String = "") -> URL?
    {
        var urlString = ""
        let universalScheme = DeepLinkManager.DeepLinkConstants.universalScheme,
            schemeSuffix = DeepLinkManager.DeepLinkConstants.schemeSuffix,
            host = DeepLinkManager.DeepLinkConstants.host,
            path = routerDirectory.rawValue.getURLSafeString(),
            parameterStub = DeepLinkManager.DeepLinkConstants.parameterStub,
            fragmentStub = DeepLinkManager.DeepLinkConstants.fragmentStub,
            directorySlash = DeepLinkManager.DeepLinkConstants.directorySlash,
            parameterChainer = DeepLinkManager.DeepLinkConstants.parameterChainer,
            parameterEquator = DeepLinkManager.DeepLinkConstants.parameterEquator
        
        urlString += universalScheme
        urlString += schemeSuffix
        urlString += host
        urlString += directorySlash
        urlString += path
        urlString += directorySlash
        
        // Directories
        for directory in directories {
            urlString += directory
            urlString += directorySlash
        }
        
        // Parameters
        if !parameters.isEmpty {
            urlString += parameterStub
            
            /// Append parameters and arguments onto the URL string, and concatenate these parameters with an ampersand
            for (index, (parameter, argument)) in parameters.enumerated() {
                if index != 0 { urlString += parameterChainer}
                urlString += "\(parameter)\(parameterEquator)\(argument)"
            }
        }
        
        // Fragment [Only one fragment is allowed]
        if !fragment.isEmpty {
            urlString += directorySlash
            urlString += fragmentStub
            urlString += fragment.getURLSafeString()
        }
        
        return urlString.asURL
    }
}
