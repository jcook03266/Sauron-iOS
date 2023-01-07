//
//  CoinImageFetcher.swift
//  Sauron
//
//  Created by Justin Cook on 1/3/23.
//

import Foundation
import SwiftUI
import Combine

/// Store specifically meant for fetching and storing images corresponding to the image assets linked to each coin model. Images are stored in the file system versus local memory in order to preserve performance
class CoinImageFetcher: ObservableObject {
    // MARK: - Published
    /// Used to determine the current state of the async loading of the specified image asset
    @Published var isLoading: Bool = true
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let imageDownloader: ImageDownloaderService = inject()
    }
    let dependencies = Dependencies()
    
    // MARK: Properties
    // Coin Model Information
    private let coinModel: CoinModel
    private var coinModelImageURL: URL {
        guard let url = coinModel.image.asURL
        else {
            ErrorCodeDispatcher.SwiftErrors.triggerPreconditionFailure(for: .urlCouldNotBeParsed,
                                                                       using: coinModel.image)()
        }
        
        return url
    }
    
    // Subscriptions
    /// Keeps subscriptions alive and stores them when they're cancelled
    private var cancellables = Set<AnyCancellable>()
    
    // Caching
    private var imageFileManager = LocalFileDirector.imageFileManager
    private var shouldCacheImages = true
    
    init(coinModel: CoinModel) {
        self.coinModel = coinModel
    }
    
    /// Fetches the image from the local file system if it exists, if not then the image is downloaded and then cached appropriately
    func getImage(completionHandler: @escaping ((UIImage) -> Void)) {
        do {
            try fetchImageFromLocal(completionHandler: completionHandler)
        } catch {
            downloadImage(completionHandler: completionHandler)
        }
    }
    
    /// Remote Data Access
    private func downloadImage(completionHandler: @escaping ((UIImage) -> Void)) {
        dependencies.imageDownloader.getImage(for: coinModelImageURL,
                                              imageName: coinModel.id,
                                              canCacheImage: shouldCacheImages)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.isLoading = false
            } receiveValue: { parsedImage in
                completionHandler(parsedImage)
            }
            .store(in: &cancellables)
    }
    
    /// Local Data Access
    private func fetchImageFromLocal(completionHandler: @escaping ((UIImage) -> Void)) throws {
        let fileName = coinModel.id
        let folderName = ImageFileManager.ImageDirectoryNames.coinImages
        
        guard let savedImage = imageFileManager.getImage(imageName: fileName,
                                                      folderName: folderName)
        else {
            throw ErrorCodeDispatcher.FileManagerErrors.throwError(for: .imageNotFound(fileName: fileName,
                                                                                          folderName: folderName.rawValue))
        }
        
        self.isLoading = false
        completionHandler(savedImage)
    }
}

