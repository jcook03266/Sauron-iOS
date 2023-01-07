//
//  CoinImageViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 12/30/22.
//

import SwiftUI
import Combine

class CoinImageViewModel: GenericViewModel {
    // MARK: - Published
    @Published var image: UIImage? = nil
    /// Used to determine the current state of the async loading of the specified image asset
    @Published var isLoading: Bool = true
    
    // MARK: - Observed
    @ObservedObject var coinImageFetcher: CoinImageFetcher
    
    // MARK: Properties
    private let coinModel: CoinModel
    
    init(coinModel: CoinModel) {
        self.coinModel = coinModel
        self.coinImageFetcher = CoinImageFetcher(coinModel: coinModel)
        
        getImage()
    }
    
    private func getImage() {
        coinImageFetcher.getImage { [weak self] fetchImage in
            guard let self = self else { return }
            
            self.image = fetchImage
            self.isLoading = false
        }
    }
}

