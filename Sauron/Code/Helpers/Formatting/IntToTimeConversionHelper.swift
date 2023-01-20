//
//  IntToTimeConversionHelper.swift
//  Sauron
//
//  Created by Justin Cook on 1/19/23.
//

import Foundation

/// Converts unsigned integers to a string formatted timestamp
struct IntToTimeConversionHelper {
    
    /// Pass in a number representing seconds and convert this to a time stamp
    static func convertIntToTimeStamp(number: UInt,
                                      with format: TimeStampFormat) -> String
    {
        let minutes = number / 60 >= 1 ? number / 60 : 0,
            seconds = number % 60,
            hours = minutes / 60 >= 1 ? minutes / 60 : 0
        
        // Ex: Long: 00:12:25 / Short: 12:25 [Short Truncates the hours]
        var timeStamp = ""
        if format == .long {
            timeStamp += "\(hours)".count == 1 ? "0\(hours)" : "\(hours)"
            timeStamp += ":"
        }
            timeStamp += "\(minutes)".count == 1 ? "0\(minutes)" : "\(minutes)"
            timeStamp += ":"
            timeStamp += "\(seconds)".count == 1 ? "0\(seconds)" : "\(seconds)"
        
        return timeStamp
    }
    
    enum TimeStampFormat: String, CaseIterable {
        case long,
             short
    }
}
