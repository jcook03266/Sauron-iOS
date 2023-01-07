//
//  FormattingHelper.swift
//  Sauron
//
//  Created by Justin Cook on 12/27/22.
//

import Foundation

/// General manager that encapsulates various necessary formatters used to format numbers into percentages and truncate significant figures

struct FormattingHelper {
    // MARK: - Number To String Formatting
    /// Converts a number to a string with a default 2 trailing decimal places
    static func convertNumberToString(number: NSNumber,
                                      with trailingDecimalPlaces: Int = 2) -> String {
        return String(format: "%.\(trailingDecimalPlaces)f", number)
    }
    
    /// Converts a number to a percentage with a default of 2 trailing decimal places
    static func convertToPercentage(number: NSNumber) -> String {
        return self.convertNumberToString(number: number) + "%"
    }
}
