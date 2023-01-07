//
//  VOCPageViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI

// MARK: - Carousel Pages
class VOCPageViewModel: GenericViewModel {
    let id: UUID,
        pageNumber: Int, // 1-indexed
        title: LocalizedStringKey,
        lottieAnimation: LottieAnimationRepository?,
        backgroundGradient: LinearGradient
    
    // MARK: - Observed
    @ObservedObject var manager: VOCViewModel
    
    var isCurrentPage: Bool {
        return manager.currentPage == self.pageNumber
    }
    var isFirstPage: Bool {
        return self.pageNumber == 1
    }
    var isLastPage: Bool {
        return self.pageNumber == manager.pageCount
    }
    
    init(id: UUID = UUID(),
         manager: VOCViewModel,
         pageNumber: Int,
         title: LocalizedStringKey,
         lottieAnimation: LottieAnimationRepository?,
         backgroundGradient: LinearGradient)
    {
        self.id = id
        self.manager = manager
        self.pageNumber = pageNumber
        self.title = title
        self.lottieAnimation = lottieAnimation
        self.backgroundGradient = backgroundGradient
    }
    
}
