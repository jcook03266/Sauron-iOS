//
//  CounterRectangularButton.swift
//  Sauron
//
//  Created by Justin Cook on 1/6/23.
//

import SwiftUI

/// Button that displays a styled counter and message side by side
struct CounterRectangularButton: View {
    // MARK: Styling
    // Font
    var font: FontRepository = .body_S,
        fontWeight: Font.Weight = .regular
    
    // Dimensions + Padding
    var size: CGSize = CGSize(width: 160, height: 40),
        verticalInsetPadding: CGFloat = 5,
        horizontalInsetPadding: CGFloat = 10,
        borderWidth: CGFloat = 2
    
    // Colors
    var borderColor: Color = Colors.black.0,
        borderGradient: LinearGradient? = nil,
        backgroundColor: Color = Colors.white.0,
        messageTextColor: Color = Colors.black.0,
        messageTextGradient: LinearGradient? = nil,
        counterTextColor: Color = Colors.primary_1.0,
        counterTextGradient: LinearGradient? = Colors.gradient_1,
        shadowColor: Color = Colors.shadow_1.0,
        selectedBackgroundColor: Color = Colors.primary_2.0,
        selectedTextColor: Color = Colors.permanent_white.0
    
    // Shadow & Radius Properties
    let cornerRadius: CGFloat = 10,
        shadowCoordinates: CGPoint = CGPoint(x: 0, y: 1),
        shadowRadius: CGFloat = 2
    
    // MARK: - Properties
    var action: (() -> Void),
        message: (String?, LocalizedStringKey?) = ("Search Result", nil),
        borderEnabled: Bool = false
    var counter: UInt
    var hideCounterWhenItReaches: Int? = nil
    
    // MARK: - States
    @Binding var isSelected: Bool
    
    private var shouldHideCounter: Bool {
        guard let hideIndex = hideCounterWhenItReaches
        else { return false }
        
        return counter == hideIndex
    }
    
    // MARK: - Subviews
    var messageTextView: some View {
        Group {
            if let message = message.0 {
                Text(message)
            }
            else if let message = message.1 {
                Text(message)
            }
        }
        .transition(.scale.animation(.spring()))
        .foregroundColor(isSelected ? selectedTextColor : messageTextColor)
    }
    
    var counterTextView: some View {
        Text(counter, format: .number)
            .foregroundColor(isSelected ? selectedTextColor : counterTextColor)
            .if(counterTextGradient != nil && !isSelected,
                transform: {
                $0.applyGradient(gradient: counterTextGradient!)
            })
                .id(counter)
                .transition(.push(from: .top))
    }
    
    // MARK: - Sections
    var combinedTextView: some View {
        HStack {
            if !shouldHideCounter {
                counterTextView
            }
            
            messageTextView
        }
        .minimumScaleFactor(0.1)
        .withFont(font)
        .fontWeight(fontWeight)
        .padding([.top, .bottom], verticalInsetPadding)
        .padding([.leading, .trailing], horizontalInsetPadding)
    }
    
    var mainBody: some View {
        Button(action: {
            HapticFeedbackDispatcher.interstitialCTAButtonPress()
            action()
        }) {
            combinedTextView
            .frame(width: size.width, height: size.height)
            .background(isSelected ? selectedBackgroundColor : backgroundColor)
            .overlay(
                ShapeBorderModifier<RoundedRectangle>(
                    content: {
                        RoundedRectangle(cornerRadius: cornerRadius)
                    },
                    borderColor: borderColor,
                    borderWidth: borderWidth,
                    borderEnabled: borderEnabled
                )
                .if(borderGradient != nil,
                    transform: {
                    $0.applyGradient(gradient: borderGradient!)
                })
            )
            .cornerRadius(cornerRadius)
            .shadow(color: shadowColor,
                    radius: shadowRadius,
                    x: shadowCoordinates.x,
                    y: shadowCoordinates.y)
        }
        .buttonStyle(.genericSpringyShrink)
    }
    
    var body: some View {
        mainBody
            .animation(.spring(),
                       value: counter)
    }
}

struct CounterRectangularButton_Previews: PreviewProvider {
    static var previews: some View {
        CounterRectangularButton(action: {},
                                 counter: 1,
                                 isSelected: .constant(false))
    }
}
