//
//  FileManagerInterfaceProtocol.swift
//  Sauron
//
//  Created by Justin Cook on 12/31/22.
//

import Foundation

/// General protocol that outlines the basic requirements for a fully fledged file manager interface that specializes in storing and getting a specific file type
protocol FileManagerInterface {
    typealias DirectoryNameType = Hashable
    associatedtype DirectoryName: DirectoryNameType
    associatedtype FileManagerInterfaceType: FileManagerInterface
    
    // MARK: - Singleton Instance
    static var shared: FileManagerInterfaceType { get }
    
    // MARK: - File Manager API properties
    var sharedFileManager: FileManager { get }
    var folderSearchPathDirectory: FileManager.SearchPathDirectory { get }
    var folderSearchPathDomainMask: FileManager.SearchPathDomainMask { get }
    
    // MARK: - Operation Methods
    
    /** Class by class implementation required for these specialized functions
    * - func saveFile(file: Data, fileName: String, folderName: DirectoryName)
    * - func getURLForFile(fileName: String, folderName: DirectoryName) -> URL?
    * - func getFile(fileName: String, folderName: DirectoryName) -> Data?
    * Note: Filename needs its required type extension to be appended to the URL obtained inside the body of the implementing method
    */
    
    // URL Getters
    func getURLForFolder(folderName: DirectoryName) -> URL?
    
    // Directory creation
    func createFolderIfNeeded(folderName: DirectoryName) throws
    func createDirectory(named directory: DirectoryName, at url: URL) throws
    
    // Directory and file deletion
    func deleteFile(at fileURL: URL,
                             with fileName: String,
                             and directoryName: DirectoryName)
    func deleteFolder(at directoryURL: URL, with directoryName: DirectoryName)
    
    // Convenience
    func doesFileExistAt(url: URL) -> Bool
}
