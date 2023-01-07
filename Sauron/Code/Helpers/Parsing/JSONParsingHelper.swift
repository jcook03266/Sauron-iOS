//
//  JSONParsingHelper.swift
//  Sauron
//
//  Created by Justin Cook on 12/28/22.
//

import Foundation

struct JSONParsingHelper {
    /// Parse any type that conforms to the decodable protocol with this method
    static func parseJSON<T: Decodable>(with type: T.Type,
                                  using data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        }
        catch { throw error }
    }
}
