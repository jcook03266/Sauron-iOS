//
//  CoinImageView.swift
//  Sauron
//
//  Created by Justin Cook on 12/30/22.
//

import SwiftUI
import Shimmer

struct CoinImageView: View {
    // MARK: - Observed Objects
    @StateObject var model: CoinImageViewModel
    
    // MARK: - Image Loading Shimmer Placeholder Properties
    private let shimmerDuration: CGFloat = 2,
                /// Start immediately
                shimmerDelay: CGFloat = 0,
                shimmerBounce: Bool = false
    
    private var isShimmerActive: Bool {
        return model.isLoading
    }
    
    // MARK: - Dimensions
    var size: CGSize = .init(width: 30, height: 30)
    
    // MARK: - Colors
    var shimmerViewColor: Color = Colors.neutral_500.0
    
    // MARK: - Subviews
    var imageView: some View {
        ZStack {
            if let image = model.image {
                Image(uiImage: image)
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .transition(.scale)
            }
            else {
                placeholderShimmerView
                    .transition(.scale)
            }
        }
        .frame(width: size.width,
               height: size.height)
    }
    
    var placeholderShimmerView: some View {
        Circle()
            .foregroundColor(shimmerViewColor)
            .shimmering(active: isShimmerActive,
                        duration: shimmerDuration,
                        bounce: shimmerBounce,
                        delay: shimmerDelay)
    }
    
    var body: some View {
        imageView
        .animation(
            .spring(),
            value: isShimmerActive)
        .frame(width: 100,
               height: 100)
    }
}

struct CoinImageView_Previews: PreviewProvider {
    static func getDevEnv() -> DevEnvironment {
        let env = DevEnvironment.shared
        env.parseJSONIntoModel()
        
        return env
    }
    
    static var previews: some View {
        let env = getDevEnv()
        let coin = env.testCoinModel!
        
        CoinImageView(model: .init(coinModel: coin))
            .previewLayout(.sizeThatFits)
    }
}
