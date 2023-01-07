//
//  VOCPageView.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI
import Lottie

struct VOCPageView: View {
    // MARK: - Observed
    @StateObject var model: VOCPageViewModel
    @ObservedObject var manager: VOCViewModel
    
    // MARK: - States
    @State var scrollEnabled: Bool = false
    
    let font: FontRepository = .heading_2,
        titleGradient: LinearGradient = Colors.gradient_1,
        titleLeadingPadding: CGFloat = 20
    
    var titleTopPadding: CGFloat {
        return model.isLastPage ? 100 :
        (model.pageNumber == 1 ? -70 : -120)
    }
    var animationViewTopPadding: CGFloat {
        return model.pageNumber == 2 ? 50 : 0
    }
    var animationShouldPlay: Bool {
        return model.isCurrentPage
    }
    
    var titleTextView: some View {
        HStack {
            Text(model.title)
                .withFont(font)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .applyGradient(gradient: titleGradient)
                .frame(width: 230,
                       height: 300,
                       alignment: .leading)
            
            Spacer()
        }
        .padding(.leading,
                 titleLeadingPadding)
        .padding(.top,
                 titleTopPadding)
    }
    
    var lottieAnimationView: some View {
        return HStack {
            Spacer()
            
            if let animation = model.lottieAnimation {
                let lottieView = LottieViewUIViewRepresentable(animationName: animation, shouldPlay: .constant(animationShouldPlay))
                
                 lottieView
                    .frame(width: 300, height: 300)
                    .scaledToFit()
            }
            
            Spacer()
        }
        .padding(.top,
                 animationViewTopPadding)
    }
    
    var body: some View {
        GeometryReader { geom in
            ZStack {
                ScrollView {
                    VStack {
                        Group {
                            VStack {
                                
                                if !model.isLastPage {
                                    Spacer()
                                    lottieAnimationView
                                        .scaledToFit()
                                        .opacity(model.isCurrentPage ? 1 : 0)
                                }
                                
                                if model.isCurrentPage {
                                    titleTextView
                                        .transition(.move(edge: .leading))
                                    
                                    Spacer()
                                }
                            }
                        }
                        .animation(.spring(response: 1.2),
                                   value: model.isCurrentPage)
                    }
                    .frame(width: geom.size.width,
                           height: geom.size.height)
                }
                .scrollDisabled(!scrollEnabled)
            }
            .background(
                model.backgroundGradient
            )
            .ignoresSafeArea()
        }
    }
}

struct VOCPageView_Previews: PreviewProvider {
    private static func getTestModel() -> VOCPageViewModel {
        let model = OnboardingPages(pageManager: .init(coordinator: .init())).page_1
        
        return model
    }
    
    static var previews: some View {
        let model = getTestModel()
        
        VOCPageView(model: model,
                    manager: model.manager)
    }
}
