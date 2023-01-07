//
//  ImageFileManager.swift
//  Sauron
//
//  Created by Justin Cook on 12/30/22.
//

import Foundation
import SwiftUI

/// A class that interfaces with the file manager API to specialize in storing image data inside of specified directories
class ImageFileManager: FileManagerInterface {
    typealias DirectoryName = ImageDirectoryNames
    
    // MARK: - Singleton Instance
    static let shared: ImageFileManager = .init()
    
    // MARK: - Custom Parameters for saving and loading
    var imageFormat: ImageFormat = .png
    let jpegCompressionQuality: CGFloat = 1 // From 0 - 1 | worst <-> best quality
    
    // MARK: - File Manager API properties
    let sharedFileManager: FileManager = FileManager.default,
        folderSearchPathDirectory: FileManager.SearchPathDirectory = .cachesDirectory,
        folderSearchPathDomainMask: FileManager.SearchPathDomainMask = .userDomainMask
    
    private init() {}
    
    // MARK: - Operations
    // MARK: - Image Getter and Setter
    func saveImage(image: UIImage,
                   imageName: String,
                   folderName: ImageDirectoryNames)
    {
        // If the directory for this image does not already exist then create it
        do {
            try createFolderIfNeeded(folderName: folderName)
        } catch let error {
            print(ErrorCodeDispatcher
                .FileManagerErrors
                .throwError(for: .fileDirectoryNotCreated(folderName: folderName.rawValue,
                                                          localErrorDescription: error.localizedDescription)).localizedDescription
            )
        }
        
        // Get the path for this image
        guard let data = imageFormat == .png ? image.pngData() :
                image.jpegData(compressionQuality: jpegCompressionQuality),
              let url = getURLForImage(imageName: imageName, folderName: folderName)
        else { return }
        
        // Save the given image to the target resource path in the file system
        do {
            try data.write(to: url)
        } catch let error {
            print(ErrorCodeDispatcher
                .FileManagerErrors
                .throwError(for: .imageNotSaved(fileName: imageName,
                                                folderName: folderName.rawValue,
                                                localErrorDescription: error.localizedDescription)).localizedDescription
            )
        }
    }
    
    func getImage(imageName: String, folderName: ImageDirectoryNames) -> UIImage? {
        guard let url = getURLForImage(imageName: imageName, folderName: folderName), doesFileExistAt(url: url)
        else { return nil }
        
        return UIImage(contentsOfFile: url.path())
    }
    
    // MARK: - URL Getters
    /// Returns the URL for the directory specified, if the url does not point to an active directory then that directory does not exist
    func getURLForFolder(folderName: ImageDirectoryNames) -> URL? {
        
        guard let url = sharedFileManager.urls(for: folderSearchPathDirectory,
                                               in: folderSearchPathDomainMask).first
        else { return nil }
        
        let constructedURL = url.appendingPathComponent(folderName.rawValue)
        return constructedURL
    }
    
    /// Returns the URL for the image specified inside of the folder name, which is also given
    private func getURLForImage(imageName: String, folderName: ImageDirectoryNames) -> URL? {
        guard let folderURL = getURLForFolder(folderName: folderName)
        else { return nil }
        
        return folderURL.appendingPathComponent(imageName + imageFormat.rawValue)
    }
    
    // MARK: - Directory creation
    func createFolderIfNeeded(folderName: ImageDirectoryNames) throws {
        guard let url = getURLForFolder(folderName: folderName),
              !doesFileExistAt(url: url)
        else { return }
        
        try createDirectory(named: folderName, at: url)
    }
    
    func createDirectory(named directory: ImageDirectoryNames, at url: URL) throws {
        // Only create a directory if one doesn't exist at the target url
        guard !doesFileExistAt(url: url) else { return }
        
        do {
            try sharedFileManager.createDirectory(at: url,
                                                  withIntermediateDirectories: true)
        } catch let error {
            throw ErrorCodeDispatcher
                .FileManagerErrors
                .throwError(for: .fileDirectoryNotCreated(folderName: directory.rawValue,
                                                          localErrorDescription: error.localizedDescription))
        }
    }
    
    // MARK: - Directory and file deletion
    func deleteFile(at fileURL: URL,
                             with fileName: String,
                             and directoryName: ImageDirectoryNames)
    {
        guard doesFileExistAt(url: fileURL) else { return }
        
        do {
            try sharedFileManager.removeItem(at: fileURL)
        } catch let error {
            print(ErrorCodeDispatcher
                .FileManagerErrors
                .throwError(for: .imageCouldNotBeDeleted(fileName: fileName,
                                                         url: fileURL,
                                                         folderName: directoryName.rawValue,
                                                         localErrorDescription: error.localizedDescription))
            )
        }
    }
    
    func deleteFolder(at directoryURL: URL,
                      with directoryName: ImageDirectoryNames)
    {
        guard doesFileExistAt(url: directoryURL) else { return }
        
        do {
            try sharedFileManager.removeItem(at: directoryURL)
        } catch let error {
            print(ErrorCodeDispatcher
                .FileManagerErrors
                .throwError(for: .fileDirectoryCouldNotBeDeleted(url: directoryURL,
                                                                 folderName: directoryName.rawValue,
                                                                 localErrorDescription: error.localizedDescription))
            )
        }
    }
    
    // MARK: - Resource existence detection
    func doesFileExistAt(url: URL) -> Bool {
        return sharedFileManager.fileExists(atPath: url.path())
    }
    
    // MARK: - Supported Image format and directory name references
    enum ImageFormat: String, CaseIterable {
        case jpeg = ".jpeg"
        case png = ".png"
    }
    
    enum ImageDirectoryNames: String, CaseIterable {
        case coinImages
    }
}
