//
//  ImageDownloaderService.swift
//  Sauron
//
//  Created by Justin Cook on 12/30/22.
//

import SwiftUI
import Combine

/// Service that bridges the networking service to be able to download and parse remote image resources from URLs into UIImages and then emit these values in singular bursts using Futures to ensure that only one call is made to download expensive resources. Important: This service can't be shared as a singleton between instances as overruns will occur and some images will not be downloaded.
class ImageDownloaderService: ObservableObject {
    // MARK: - Published
    @Published var currentImage: UIImage? = nil
    
    // MARK: - Properties
    var activeURL: URL? = nil
    private var downloaderSubscription: AnyCancellable?
    
    // MARK: - Caching
    private let imageFileManager = LocalFileDirector.imageFileManager
    
    // MARK: - Convenience
    var getCurrentImageView: Image? {
        guard let image = self.currentImage else { return nil }
        return Image(uiImage: image)
    }
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let networkingService: NetworkingService = inject()
    }
    let dependencies = Dependencies()
    
    // MARK: - URL Downloading Task Properties
    let receiverScheduler = DispatchQueue.main
    
    init() {}
    
    /**
     - Parameters:
        - imageResourceURL: The URL from which to get the image file
        - canCacheImage: Flag that informs the algorithm whether or not to
     
     - Returns: A future that emits one value when the asynchronous logic completes, this value will contain the promised value and or an error describing what went wrong
     */
    func getImage(for imageResourceURL: URL,
                  imageName: String? = nil,
                  canCacheImage: Bool) -> Future<UIImage, Error> {
        let networkingService = dependencies.networkingService
        let possibleError = ErrorCodeDispatcher
            .NetworkingErrors
            .throwError(for: .imageCouldNotBeDownloaded(endpoint: imageResourceURL))
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.downloaderSubscription = networkingService
                .fetchPublishedData(from: imageResourceURL)
                .sink(receiveCompletion: networkingService.getRequestCompletionHandler,
                      receiveValue: { data in
                    
                    guard let image = UIImage(data: data) else {
                        promise(.failure(possibleError))
                        
                        self.downloaderSubscription?.cancel()
                        return
                    }
                    
                    self.downloaderSubscription?.cancel()
                    
                    // Saves the image to the local file system to prevent unneccessary downloads when the resource is requested in different scenes
                    if canCacheImage, let imageName = imageName
                    {
                        self.imageFileManager.saveImage(image: image,
                                                   imageName: imageName,
                                                   folderName: .coinImages)
                    }
                    
                    promise(.success(image))
                })
        }
    }
}
