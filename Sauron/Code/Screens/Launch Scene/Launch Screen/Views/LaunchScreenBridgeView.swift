//
//  LaunchScreenBridgeView.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI

/// View displayed after the launch screen, used as a stylized splash screen to compliment UX
struct LaunchScreenBridgeView: View {
    // MARK: - Observed
    @StateObject var model: LaunchScreenBridgeViewModel = .init()
    
    // MARK: - States
    @State var didAppear: Bool = false
    @State var showAppName: Bool = false
    
    // MARK: - Padding
    var appNameTextViewBottomPadding: CGFloat = 20,
        lottieAnimationTopPadding: CGFloat = 25
    
    // MARK: - Styling
    var appIconShadowColor: Color {
        didAppear ? Colors.permanent_white.0 : .clear
    }
    var appIconShadowRadius: CGFloat {
        didAppear ? 30 : 0
    }
    
    // MARK: - Assets
    var launchScreenImage: some View {
        model.launchScreenImage
            .resizable()
            .renderingMode(.original)
            .aspectRatio(contentMode: .fit)
            .frame(width: model.launchScreenImageSize.width,
                   height: model.launchScreenImageSize.height)
            .shadow(color: appIconShadowColor,
                    radius: appIconShadowRadius)
            .scaledToFit()
    }
    
    var lottieAnimationView: some View {
        return HStack {
            Spacer()
            
            if let animation = model.lottieAnimation {
                let lottieView = LottieViewUIViewRepresentable(animationName: animation, shouldPlay: .constant(true))
                
                lottieView
                    .frame(width: 400, height: 400)
                    .padding(.top,
                             lottieAnimationTopPadding)
                    .scaledToFit()
            }
            
            Spacer()
        }
    }
    
    var appNameTextView: some View {
        HStack {
            Spacer()
            
            if didAppear && showAppName {
                Text(model.appNameText)
                    .font(model.appNameTextFont)
                    .withFont(model.appNameTextFontName)
                    .minimumScaleFactor(0.1)
                    .scaledToFit()
                    .transition(
                        .offset(CGSize(width: 0,
                                       height: 400)))
                    .animation(
                        .spring()
                        .speed(1.2),
                        value: showAppName)
                    .foregroundColor(model.textColor)
            }
            
            Spacer()
        }
        .padding(.bottom,
                 appNameTextViewBottomPadding)
    }
    
    var body: some View {
        GeometryReader { geom in
            ZStack {
                VStack {
                    Spacer()
                    
                    ZStack {
                        lottieAnimationView
                        
                        HStack {
                            Spacer()
                            launchScreenImage
                            Spacer()
                        }
                    }
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    
                    appNameTextView
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.75)) {
                    didAppear = true
                    showAppName = true
                }
            }
            .frame(width: geom.size.width,
                   height: geom.size.height)
            .foregroundColor(model.foregroundColor)
            .background(model.backgroundGradient)
        }
        .ignoresSafeArea()
    }
}

struct LaunchScreenBridgeView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenBridgeView()
    }
}
