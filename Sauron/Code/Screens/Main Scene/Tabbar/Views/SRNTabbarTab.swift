//
//  SRNTabbarTab.swift
//  Sauron
//
//  Created by Justin Cook on 1/21/23.
//

import SwiftUI

struct SRNTabbarTab: View {
    // MARK: - Observed
    @StateObject var model: SRNTabbarTabViewModel
    
    var body: some View {
        buttonBody
    }
}

// MARK: - View Combinations
extension SRNTabbarTab {
    var buttonBody: some View {
        Button {
            model.action()
        } label: {
            textBody
        }
    }
}

// MARK: - Subviews
extension SRNTabbarTab {
    var textBody: some View {
        Text(model.title)
            .withFont(model.font)
            .fontWeight(model.fontWeight)
            .foregroundColor(model.foregroundColor)
            .minimumScaleFactor(0.1)
            .lineLimit(1)
            .multilineTextAlignment(.center)
    }
}

struct SRNTabbarTab_Previews: PreviewProvider {
    static var previews: some View {
        SRNTabbarTab(model: .init(parent: .init(coordinator: .init(),
                                                router: .init(coordinator: .init()),
                                                currentTab: .home),
                                  tab: .wallet))
            .previewLayout(.sizeThatFits)
            .padding(.all, 10)
    }
}
