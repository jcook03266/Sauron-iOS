//
//  Videos.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import UIKit
import AVKit
import SwiftUI

/// Video selector that loads up specific video resources from the main bundle
/// Any new videos added to the xcassets file must be added here as well
// MARK: - Structs
struct Videos {
    static func getVideo(named videoName: VideoRepository) -> AVPlayerItem {
        let video = packageVideoResource(from: videoName)
        
        guard let videoURL = video.loadResourceURLFromBundle() else {
            preconditionFailure("Error: The video named \(videoName) was not found in the bundle \(video.bundle), Function: \(#function)")
        }
        
        return AVPlayerItem(url: videoURL)
    }
}

extension Videos {
    static private func packageVideoResource(from videoName: VideoRepository) -> Video {
        return Video(from: videoName.rawValue)
    }
}

/// Stores the individual components of a video asset's URL, including the respective Bundle the asset is located within
struct Video {
    var fileExtension: String,
        fileName: String,
    bundle: Bundle
    
    init(fileExtension: String,
         fileName: String,
         bundle: Bundle = .main)
    {
        self.fileExtension = fileExtension
        self.fileName = fileName
        self.bundle = bundle
    }
    
    /// Overloaded method for initializing videos directly from the video repository
    init(from url: String,
         with bundle: Bundle = .main)
    {
        assert(url.contains(where: { $0 == "." }),
               "The passed string is not a valid URL, it's missing a period and or file extension")
        
        let components = Video.parseFileComponents(from: url)
        self.fileName = components.0
        self.fileExtension = components.1
        self.bundle = bundle
    }
    
    func loadResourceURLFromBundle() -> URL? {
        return bundle.url(forResource: self.fileName, withExtension: self.fileExtension)
    }
    
    /// Parses the file name and file extension from the given URL string, [0] is filename [1] is file extension
    static func parseFileComponents(from url: String) -> (String, String) {
        guard url.contains(where: { $0 == "." }) else {
            return ("", "")
        }
        
        let components = url.components(separatedBy: ".")
        let fileName = components[0]
        let fileExtension = components[1]
        
        return (fileName, fileExtension)
    }
    
    enum fileExtensionTypes: String, CaseIterable, Hashable {
        case mp4,
             mov
    }
}

enum VideoRepository: String, CaseIterable, Hashable {
    case Homescreen_B_Roll = "Homescreen-B-Roll.mp4"
}
