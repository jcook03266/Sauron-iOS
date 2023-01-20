//
//  ObfuscatedPasscodeSegment.swift
//  Sauron
//
//  Created by Justin Cook on 1/17/23.
//

import SwiftUI

struct ObfuscatedPasscodeSegment: View {
    // MARK: - Observed
    @StateObject var model: ObfuscatedPasscodeSegmentViewModel
    
    // MARK: - Dimensions
    private let cornerRadius: CGFloat = 100
    
    private var size: CGSize {
        return .init(width: model.isActive ? 60 : 40,
                     height: 10)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(model.inactiveFillColor)
            .if(model.isActive,
                transform: {
                $0.applyGradient(gradient: model.activeFillGradient)
            })
            .frame(width: size.width,
                   height: size.height)
                .zIndex(1)
                .animation(.spring(),
                           value: model.isActive)
    }
}

struct ObfuscatedPasscodeSegment_Previews: PreviewProvider {
    static var previews: some View {
        ObfuscatedPasscodeSegment(model: .init(correspondingTextLength: 1))
            .previewLayout(.sizeThatFits)
    }
}
