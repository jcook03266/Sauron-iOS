//
//  OnboardingPageModels.swift
//  Inspec
//
//  Created by Justin Cook on 11/5/22.
//

import SwiftUI

struct OnboardingPages {
    let pageManager: VOCViewModel
    
    // MARK: - View Layout parameters, grid based display in a scrollView
    static var gridItemLayout: [GridItem] = [GridItem(spacing: 0)]
    
    // MARK: - Pages
    var page_1: VOCPageViewModel {
        let pageNumber: Int = 1,
            title: LocalizedStringKey = LocalizedStrings.getLocalizedStringKey(for: .ONBOARDING_PAGE_1_TITLE)
        
        return VOCPageViewModel(manager: pageManager,
                                pageNumber: pageNumber,
                                title: title,
                                lottieAnimation: .crypto_orbital,
                                backgroundGradient: Colors.gradient_3)
    }
    
    var page_2: VOCPageViewModel {
        let pageNumber: Int = 2,
            title: LocalizedStringKey = LocalizedStrings.getLocalizedStringKey(for: .ONBOARDING_PAGE_2_TITLE)
        
        return VOCPageViewModel(manager: pageManager,
                                pageNumber: pageNumber,
                                title: title,
                                lottieAnimation: .dashboard_graph,
                                backgroundGradient: Colors.gradient_4)
    }
    
    var page_3: VOCPageViewModel {
        let pageNumber: Int = 3,
            title: LocalizedStringKey = LocalizedStrings.getLocalizedStringKey(for: .ONBOARDING_PAGE_3_TITLE)
        
        return VOCPageViewModel(manager: pageManager,
                                pageNumber: pageNumber,
                                title: title,
                                lottieAnimation: nil,
                                backgroundGradient: Colors.gradient_5)
    }
    
    // MARK: - Init
    init(pageManager: VOCViewModel) {
        self.pageManager = pageManager
    }
    
    // MARK: - Convenient functions
    func getPageFor(page: OnboardingPages.pages) -> VOCPageViewModel {
        switch page {
        case .one:
            return page_1
        case .two:
            return page_2
        case .three:
            return page_3
        }
    }
    
    func getAllPages() -> [VOCPageViewModel] {
        var pageModels: [VOCPageViewModel] = []
        
        for page in pages.allCases {
            pageModels.append(getPageFor(page: page))
        }
        
        return pageModels
    }
    
    enum pages: String, CaseIterable {
        case one, two, three
    }
}
