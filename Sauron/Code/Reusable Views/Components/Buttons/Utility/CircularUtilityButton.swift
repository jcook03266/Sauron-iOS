//
//  CircularUtilityButton.swift
//  Sauron
//
//  Created by Justin Cook on 1/6/23.
//

import SwiftUI

/// A simple circle button with an icon in the middle that shrinks and grows when pressed
struct CircularUtilityButton: View {
    // MARK: - Properties: Actions - Color - Font
    var action: (() -> Void),
        icon: Image = Icons.getIconImage(named: .magnifyingglass),
        backgroundColor: Color = Colors.black.0,
        backgroundGradient: LinearGradient? = nil,
        foregroundColor: Color = Colors.permanent_white.0,
        foregroundGradient: LinearGradient? = nil,
        shadowColor: Color = Colors.shadow_1.0,
        borderEnabled: Bool = true,
        borderColor: Color = Colors.primary_1.0,
        borderGradient: LinearGradient? = Colors.gradient_1,
        disabledForegroundColor: Color = Colors.neutral_300.0
    
    // MARK: - Dimensions + Padding
    var size: CGSize = CGSize(width: 50, height: 50),
        borderWidth: CGFloat = 2,
        padding: CGFloat = 0
    
    var imageSize: CGSize {
        return size.scaleBy(0.4)
    }
    
    let shadowCoordinates: CGPoint = CGPoint(x: 0, y: 2),
        shadowRadius: CGFloat = 3
    
    // MARK: - Appear Animation
    var shouldAnimateOnAppear: Bool = false,
        animatedCircleViewColor: Color = Colors.neutral_400.0,
        animatedCircleStrokeWidth: CGFloat = 5
    
    // MARK: - Binding
    @Binding var isEnabled: Bool
    @Binding var animate: Bool
    
    // MARK: - Subviews
    var animatedCircleView: some View {
        Circle()
            .stroke(animatedCircleViewColor,
                    lineWidth: animatedCircleStrokeWidth)
            .frame(width: size.width * 1.5, height: size.height * 1.5)
            .scaleEffect(animate ? 1 : 0.0001)
            .opacity(animate ? 0 : 1)
            .animation(animate ? .spring().speed(0.8) : nil,
                       value: animate)
            .onAppear {
                guard shouldAnimateOnAppear else { return }
                animate.toggle()
            }
    }
    
    var iconView: some View {
        icon
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: imageSize.width, height: imageSize.height)
            .padding([.all], padding)
            .foregroundColor(isEnabled ? foregroundColor : disabledForegroundColor)
            .if(foregroundGradient != nil, transform: {
                $0.applyGradient(gradient: foregroundGradient!)
            })
    }
    
    var circleBorder: some View {
        Circle()
            .stroke(borderColor,
                    lineWidth: borderWidth)
            .if(borderGradient != nil, transform: {
                $0.applyGradient(gradient: borderGradient!)
            })
            .frame(width: size.width, height: size.height)
    }
    
    // MARK: - View Combinations
    var mainBody: some View {
            Button(action: {
                HapticFeedbackDispatcher.genericButtonPress()
                action()
            }){
                Circle()
                    .frame(width: size.width, height: size.height)
                    .foregroundColor(backgroundColor)
                    .if(backgroundGradient != nil, transform: {
                        $0.applyGradient(gradient: backgroundGradient!)
                    })
                        .shadow(color: shadowColor,
                                radius: shadowRadius,
                                x: shadowCoordinates.x,
                                y: shadowCoordinates.y)
                            .overlay(
                                iconView
                            )
                                .background(
                                    circleBorder
                                )
            }
            .disabled(!isEnabled)
            .buttonStyle(.genericSpringyShrink)
            .background(
                animatedCircleView
            )
    }
    
    var body: some View {
        mainBody
    }
}

struct CircularUtilityButton_Previews: PreviewProvider {
    static var previews: some View {
        CircularUtilityButton(action: {},
                              shouldAnimateOnAppear: true,
                              isEnabled: .constant(true),
                              animate: .constant(false))
    }
}
