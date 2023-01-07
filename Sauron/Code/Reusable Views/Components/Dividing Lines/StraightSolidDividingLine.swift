//
//  StraightSolidDividingLine.swift
//  Inspec
//
//  Created by Justin Cook on 11/30/22.
//

import SwiftUI

struct StraightSolidDividingLine: View {
    var cornerRadius: CGFloat = 0,
        color: Color = Colors.primary_1.0,
        width: CGFloat = 100,
        height: CGFloat = 2,
        shadowColor: Color = .clear,
        shadowOffset: CGSize = .zero,
        shadowRadius: CGFloat = 0,
        gradient: LinearGradient? = nil
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundColor(color)
            .frame(width: width, height: height)
            .shadow(color: shadowColor,
                    radius: shadowRadius,
                    x: shadowOffset.width,
                    y: shadowOffset.height)
            .if(gradient != nil) {
                $0.applyGradient(gradient: gradient!)
                    .foregroundColor(Colors.permanent_white.0)
            }
    }
}

struct StraightSolidDividingLine_Previews: PreviewProvider {
    static var previews: some View {
        StraightSolidDividingLine()
            .previewLayout(.sizeThatFits)
    }
}
