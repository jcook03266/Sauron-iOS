//
//  BannerEventView.swift
//  Sauron
//
//  Created by Justin Cook on 1/25/23.
//

import SwiftUI

// The event views stored inside of each event banner carousel view
struct BannerEventView: View {
    // MARK: - Observed
    @ObservedObject var parentModel: SRNEventBannerViewModel
    @StateObject var model: BannerEventModel
    
    // MARK: - Dimensions
    private let bodyHeight: CGFloat = 140,
        ctaSectionCornerRadius: CGFloat = 20,
        shadowRadius: CGFloat = 1,
        shadowOffset: CGSize = .init(width: 0,
                                     height: 4)
    
    var backgroundImageHeight: CGFloat {
        return model.shouldDisplayCTA ? bodyHeight - 20 : bodyHeight
    }
    
    // MARK: - Padding
    let ctaForegroundViewLeadingPadding: CGFloat = 0,
        ctaForegroundViewBottomPadding: CGFloat = 0,
        ctaBackgroundViewBottomPadding: CGFloat = 2,
        ctaBackgroundViewLeadingPadding: CGFloat = 8,
        ctaTopOffset: CGFloat = 20
    
    var body: some View {
        mainBody
    }
}

// MARK: - View Combinations
extension BannerEventView {
    var mainBody: some View {
        Button {
            model.performAction()
        } label: {
            ZStack(alignment: .top) {
                roundedBackground
                ctaSection
            }
            .frame(height: bodyHeight)
        }
        .buttonStyle(OffsettableButtonStyle(offset: .init(width: 0,
                                                          height: -5)))
    }
    
    var roundedBackground: some View {
        Rectangle()
            .overlay {
                eventBackground
            }
            .frame(height: backgroundImageHeight)
    }
    
    var ctaSection: some View {
        Group {
            if model.shouldDisplayCTA {
                GeometryReader { geom in
                    VStack(spacing: 0) {
                        Spacer()
                        
                        ZStack(alignment: .bottomLeading) {
                            ctaBackgroundView
                                .frame(width: geom.size.width * 0.625,
                                       height: geom.size.height * 0.5)
                            
                            ctaForegroundView.frame(width: geom.size.width * 0.6,
                                                    height: geom.size.height * 0.45)
                            .padding(.bottom,
                                     ctaForegroundViewBottomPadding)
                            .padding(.leading,
                            ctaForegroundViewLeadingPadding)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Subviews
extension BannerEventView {
    var ctaForegroundView: some View {
        ZStack {
            Rectangle()
                .fill(parentModel.ctaSectionInnerBackgroundColor)
                .cornerRadius(ctaSectionCornerRadius,
                              corners: [.bottomLeft, .topRight])
                .shadow(color: parentModel.shadowColor,
                        radius: shadowRadius,
                        x: shadowOffset.width,
                        y: shadowOffset.height)
            
            Text(model.getEventCTA() ?? "")
                .withFont(parentModel.ctaSectionFont)
                .fontWeight(parentModel.ctaSectionFontWeight)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.1)
                .foregroundColor(parentModel.ctaSectionForegroundColor)
        }
    }
    
    var ctaBackgroundView: some View {
        Rectangle()
            .fill(parentModel.ctaSectionOuterGradient)
            .cornerRadius(ctaSectionCornerRadius,
                          corners: [.bottomLeft, .topRight])
            .padding(.leading,
                     ctaBackgroundViewLeadingPadding)
            .padding(.bottom,
                     ctaBackgroundViewBottomPadding)
            .shadow(color: parentModel.shadowColor,
                    radius: shadowRadius,
                    x: shadowOffset.width,
                    y: shadowOffset.height)
    }
    
    var eventBackground: some View {
        model.image?
            .filledResizableOriginalImageModifier()
    }
}

struct BannerEventView_Previews: PreviewProvider {
    static var previews: some View {
        BannerEventView(parentModel: .init(),
                        model: BannerEventsManager
            .LocalBannerEvents
            .ftueWelcomeMessage
            .createBannerEvent())
    }
}
