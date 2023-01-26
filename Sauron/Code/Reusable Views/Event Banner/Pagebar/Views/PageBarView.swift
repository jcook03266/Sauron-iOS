//
//  PageBarView.swift
//  Sauron
//
//  Created by Justin Cook on 1/25/23.
//

import SwiftUI

/// A general page indicator that changes whenever the value of the 'current page' publisher is updated from the view model
struct PageBarView: View {
    // MARK: - Observed
    @StateObject var model: PageBarViewModel
    
    // MARK: - Dimensions
    private let barHeight: CGFloat = 5,
                barWidthFull: CGFloat = 50,
                barWidthShrunken: CGFloat = 15,
                cornerRadius: CGFloat = 40
    
    // MARK: - Padding / Spacing
    private let barSpacing: CGFloat = 5
    
    var body: some View {
        barRow
            .animation(.spring(),
                       value: model.currentPage)
    }
}

// MARK: - View Combinations
extension PageBarView {
    var barRow: some View {
        HStack(spacing: barSpacing) {
            ForEach((0..<model.totalPages),
                    id: \.self) { index in
                bar
                    .if(index == model.currentPage) {
                        $0.applyGradient(gradient: model.pageBarActiveFillGradient)
                    }
                    .frame(width: index == model.currentPage ? barWidthFull : (model.shrinkInactiveBars ? barWidthShrunken : barWidthFull),
                           height: barHeight)
            }
        }
    }
}

// MARK: - Subviews
extension PageBarView {
    var bar: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(model.pageBarInactiveBackgroundColor)
    }
}

struct PageBarView_Previews: PreviewProvider {
    static var previews: some View {
        PageBarView(model: .init(totalPages: 4,
                                 shrinkInactiveBars: true))
        
        PageBarView(model: .init(totalPages: 4,
                                 shrinkInactiveBars: false))
    }
}
