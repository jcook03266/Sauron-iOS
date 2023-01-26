//
//  URL+Extensions.swift
//  Sauron
//
//  Created by Justin Cook on 1/25/23.
//

import UIKit

extension URL {
    /// - Returns: the absolute string version of the URL
    var asString: String {
        return self.absoluteString
    }
    
    /// Used to check if the url contains a fragment before trying to parse it for a fragment, the fragment() function
    ///  unwraps nil for some reason when no fragment is found in the url, and this causes a fatal crash which shouldn't be, but for the time being, use this to overcome that force unwrap from the system level API
    var containsFragment: Bool {
        return self.asString.contains { $0 == "#" }
    }
}
