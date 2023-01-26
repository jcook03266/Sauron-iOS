//
//  PageBarViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/25/23.
//

import SwiftUI

class PageBarViewModel: GenericViewModel {
    // MARK: - Published
    @Published var currentPage: Int
    
    // MARK: - Properties
    let totalPages: UInt,
        shrinkInactiveBars: Bool
    
    // MARK: - Styling
    // Colors
    let pageBarActiveFillGradient: LinearGradient = Colors.gradient_1,
        pageBarInactiveBackgroundColor: Color = Colors.neutral_300.0
    
    // MARK: - Convenience
    var zeroIndexPageTotal: UInt {
        guard totalPages > 0
        else { return 0 }
        
        return totalPages - 1
    }
    
    init(totalPages: UInt,
         currentPage: Int = 0,
         shrinkInactiveBars: Bool)
    {
        self.totalPages = totalPages
        self.currentPage = currentPage
        self.shrinkInactiveBars = shrinkInactiveBars
    }
}
