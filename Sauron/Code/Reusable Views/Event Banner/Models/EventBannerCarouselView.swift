//
//  EventBannerCarouselView.swift
//  Sauron
//
//  Created by Justin Cook on 1/25/23.
//

import SwiftUI

struct EventBannerCarouselView: View {
    // MARK: - Observed
    @StateObject var model: SRNEventBannerViewModel
    
    // MARK: - States / Binding to Publishers
    @Binding var currentPage: Int
    
    // MARK: - Dimensions
    private let bodyHeight: CGFloat = 140,
                topLeftCornerRadius: CGFloat = 40,
                bottomLeftCornerRadius: CGFloat = 20,
                shadowRadius: CGFloat = 1,
                shadowOffset: CGSize = .init(width: 0,
                                             height: 4)
    
    // MARK: - Padding
    private let pageBarTopPadding: CGFloat = 15,
                pageBarLeadingPadding: CGFloat = 20
    
    var body: some View {
        content
            .animation(.spring(),
                       value: self.currentPage)
    }
}

// MARK: - View Combinations
extension EventBannerCarouselView {
    var content: some View {
        VStack(spacing: 0) {
            carousel
            
            pageBarView
        }
    }
}

// MARK: - Subviews
extension EventBannerCarouselView {
    var pageBarView: some View {
        Group {
            if model.shouldDisplayPageBar {
                HStack(spacing: 0) {
                    PageBarView(model: model.pageBarViewModel)
                        .padding(.top,
                                 pageBarTopPadding)
                        .padding(.leading,
                                 pageBarLeadingPadding)
                    Spacer()
                }
            }
        }
    }
    
    var carousel: some View {
        
        TabView(selection: $currentPage) {
            ForEach((0..<model.bannerEvents.count),
                    id: \.self) { index in
                
                let event = model.bannerEvents[index]
 
                    BannerEventView(parentModel: self.model,
                                    model: event)
                    
                    // Rounding the corners of the first and last elements to keep the rounded aesthetic of this view
                    .if(event == model.bannerEvents.first) {
                        $0.cornerRadius(topLeftCornerRadius,
                                        corners: [.topLeft])
                        .cornerRadius(bottomLeftCornerRadius,
                                      corners: [.bottomLeft])
                    }
                    .if(event == model.bannerEvents.last) {
                        $0.cornerRadius(bottomLeftCornerRadius,
                                        corners: [.bottomRight])
                    }
            }
        }
        .tabViewStyle(
            .page(indexDisplayMode: .never))
        .frame(height: bodyHeight)
        .cornerRadius(topLeftCornerRadius,
                      corners: [.topLeft])
        .cornerRadius(bottomLeftCornerRadius,
                      corners: [.bottomLeft])
        .shadow(color: model.shadowColor,
                radius: shadowRadius,
                x: shadowOffset.width,
                y: shadowOffset.height)
    }
}

struct EventBannerCarouselView_Previews: PreviewProvider {
    @ObservedObject static var model: SRNEventBannerViewModel = .init()
    
    static var previews: some View {
        EventBannerCarouselView(model: model,
                                currentPage: $model.currentPage)
    }
}
