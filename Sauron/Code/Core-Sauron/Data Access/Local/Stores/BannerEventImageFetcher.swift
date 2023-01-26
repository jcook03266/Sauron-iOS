//
//  BannerEventImageFetcher.swift
//  Sauron
//
//  Created by Justin Cook on 1/24/23.
//

import SwiftUI
import Combine

class BannerEventImageFetcher: ObservableObject {
    // MARK: - Published
    /// Used to determine the current state of the async loading of the specified image asset
    @Published var isLoading: Bool = true
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let imageDownloader: ImageDownloaderService = inject()
    }
    let dependencies = Dependencies()
    
    // MARK: Properties
    // Banner Event Model Information
    private let bannerEvent: BannerEventModel
    private var bannerEventModelImageURL: URL {
        guard let url = bannerEvent.imageURL?.asURL
        else {
            ErrorCodeDispatcher.SwiftErrors.triggerPreconditionFailure(for: .urlCouldNotBeParsed,
                                                                       using: bannerEvent.imageURL ?? "URL IS NIL, [PLEASE CHECK]")()
        }
        
        return url
    }
    
    // Subscriptions
    /// Keeps subscriptions alive and stores them when they're cancelled
    private var cancellables = Set<AnyCancellable>()
    
    // Caching
    private var imageFileManager = LocalFileDirector.imageFileManager
    private var shouldCacheImages = true
    
    init(bannerEvent: BannerEventModel) {
        self.bannerEvent = bannerEvent
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
        dependencies.imageDownloader.getImage(for: bannerEventModelImageURL,
                                              imageName: bannerEvent.id,
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
        let fileName = bannerEvent.id
        let folderName = ImageFileManager.ImageDirectoryNames.bannerEventImages
        
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

