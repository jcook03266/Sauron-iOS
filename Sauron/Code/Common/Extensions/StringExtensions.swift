//
//  StringExtensions.swift
//  Inspec
//
//  Created by Justin Cook on 10/29/22.
//

import UIKit

// MARK: - Localizable Strings + General Formatting
extension String {
    /// Gets a localized version of the current string from a table that Xcode generates for you when exporting localizations
    var localized: String {
        let defaultString = "Localization for \(self) not found",
            localizedString = NSLocalizedString(self, value: defaultString, comment: "")
        
        guard defaultString != localizedString else {
            assertionFailure("\(#function), no localized string was found for the string: \(self)")
            return self
        }
        
        return localizedString
    }
    
    /// Ex: hi there -> Hi there; WELCOME -> Welcome
    var capitalizedFirstLetter: String {
        return prefix(1).uppercased() + lowercased().dropFirst()
    }

    /// Ex: hi there -> Hi there; aN EXAMPLE -> AN EXAMPLE
    var capitalizeFirstLetterOnly: String {
        return prefix(1).uppercased()
    }

    /// Ex: Hello -> hello ; HELLO -> hELLO
    var lowercasedFirstLetter: String {
        return prefix(1).lowercased() + uppercased().dropFirst()
    }

    /// Ex: Hello -> hello ; HELLO -> hELLO
    var lowercaseFirstLetterOnly: String {
        return prefix(1).lowercased()
    }

    /// Ex: hello there! -> Hello There!
    var capitalizeAllFirstLetters: String {
        let components = components(separatedBy: " ")

        return components.map {
            $0.capitalizedFirstLetter
        }.joined(separator: " ")
    }

    /// Ex: hello there! -> Hello there!
    var capitalizeFirstWord: String {
        let components = components(separatedBy: " ")

        return components.enumerated().map { (index, word) in
            (index == 0) ? word.uppercased() : word.lowercased()
        }.joined(separator: " ")
    }

    /// Ex: First Word Only -> FIRST Word Only
    var capitalizeFirstWordOnly: String {
        let components = components(separatedBy: " ")

        return components.enumerated().map { (index, word) in
            guard index == 0 else { return word }
            return word.uppercased()
        }.joined(separator: " ")
    }

    /// Ex: This Is An EXAMPLE -> this is an eXAMPLE
    var lowercaseAllFirstLetters: String {
        let components = components(separatedBy: " ")

        return components.map {
            $0.lowercasedFirstLetter
        }.joined(separator: " ")
    }

    /// Ex: First Word  -> first WORD
    var lowercaseFirstWord: String {
        let components = components(separatedBy: " ")

        return components.enumerated().map { (index, word) in
            (index == 0) ? word.uppercased() : word.uppercased()
        }.joined(separator: " ")
    }

    /// Ex: First Word Only -> first Word Only
    var lowercaseFirstWordOnly: String {
        let components = components(separatedBy: " ")

        return components.enumerated().map { (index, word) in
            guard index == 0 else { return word }
            return word.lowercased()
        }.joined(separator: " ")
    }
}

// MARK: - Search Bar Queries
extension String {
    /// Removes any trailing white space in a search query to rule out unnecessary characters
    func removeTrailingSpaces() -> String {
        let lastNonWhiteSpaceCharIndex = self.lastIndex { $0 != " " }
        
        guard self.last == " ",
              let lastNonWhiteSpaceCharIndex = lastNonWhiteSpaceCharIndex
        else { return self }
   
        return String(self.prefix(through: lastNonWhiteSpaceCharIndex))
    }
}

// MARK: - Convenience Extensions
extension String {
    var asURL: URL? {
        return URL(string: self)
    }
    
    /// Use this when building or comparing URLs specific to these page / route names
    func getURLSafeString() -> String {
        return self
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "_", with: "+")
            .lowercased()
    }
    
    /// Reverses the changes done to URL safe strings
    func convertFromURLSafeString() -> String {
        return self
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "+", with: "_")
    }
    
    /// Sets string to null space
    mutating func clear() {
        self = ""
    }
}
