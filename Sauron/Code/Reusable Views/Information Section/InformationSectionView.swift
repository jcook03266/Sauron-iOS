//
//  InformationSectionView.swift
//  Sauron
//
//  Created by Justin Cook on 12/31/22.
//

import SwiftUI

/// A static view with an information icon that presents an informative prompt to the user
struct InformationSectionView: View {
    // MARK: - Static Properties
    let informationCopy: (String?, LocalizedStringKey?)
    let icon: Image = Icons.getIconImage(named: .info_circle_fill)
    
    // MARK: - Styling
    // Colors
    var iconGradient: LinearGradient? = Colors.gradient_1,
        iconColor: Color? = Colors.black.0,
        textColor: Color = Colors.neutral_600.0
    
    // Fonts
    var textFont: FontRepository = .body_S,
        textWeight: Font.Weight = .regular
    
    // Other Properties
    var textAlignment: TextAlignment = .leading
    
    // MARK: Dimensions + Padding
    var height: CGFloat = 35
    var iconSize: CGFloat {
        return height - 8
    }
    
    private let iconTrailingPadding: CGFloat = 5
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            icon
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .if(iconGradient != nil) {
                    $0.applyGradient(gradient: iconGradient!)
                }
                .if(iconColor != nil) {
                    $0.foregroundColor(iconColor)
                }
                .transition(.scale)
                .padding(.trailing, iconTrailingPadding)
                .frame(width: iconSize,
                       height: iconSize)
            
            if let stringKey = informationCopy.1 {
                Text(stringKey)
                    .withFont(textFont)
                    .fontWeight(textWeight)
                    .foregroundColor(textColor)
                    .minimumScaleFactor(0.3)
                    .lineLimit(2)
                    .multilineTextAlignment(textAlignment)
                    .transition(.slideBackwards)
            }
            else if let string = informationCopy.0 {
                Text(string)
                    .withFont(textFont)
                    .fontWeight(textWeight)
                    .foregroundColor(textColor)
                    .minimumScaleFactor(0.3)
                    .lineLimit(2)
                    .multilineTextAlignment(textAlignment)
                    .transition(.slideBackwards)
            }
        }
        .frame(height: height)
    }
}

struct InformationSectionView_Previews: PreviewProvider {
    static var previews: some View {
        InformationSectionView(informationCopy: ("This is an example of an informative prompt used to give the user an idea of what's to come.", nil))
            .previewLayout(.sizeThatFits)
    }
}
