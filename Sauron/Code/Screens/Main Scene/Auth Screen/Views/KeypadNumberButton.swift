//
//  KeypadNumberButton.swift
//  Sauron
//
//  Created by Justin Cook on 1/17/23.
//

import SwiftUI

/// Key pad button that represents the literal number associated with its view model
struct KeypadNumberButton: View {
    // MARK: - Observed
    @StateObject var model: PasscodeKeyPadNumberButtonViewModel
    
    // MARK: - Dimensions
    private let size: CGSize = .init(width: 65,
                                     height: 65),
                shadowOffset: CGSize = .init(width: 0,
                                             height: 1),
                shadowRadius: CGFloat = 2
    
    var body: some View {
        mainBody
    }
}

// MARK: - View Combinations
extension KeypadNumberButton {
    var mainBody: some View {
        Button {
            model.action()
        } label: {
            buttonBody
        }
        .onLongPressGesture {
            model.longPressAction()
        }
        .buttonStyle(.keypadButtonStyle)
        .frame(width: size.width,
               height: size.height)
        .disabled(!model.isEnabled)
        .opacity(model.isEnabled ? 1 : 0.5)
        .animation(.easeInOut,
                   value: model.isEnabled)
    }
    
    var buttonBody: some View {
        ZStack {
            Circle()
                .fill(model.backgroundColor)
                .shadow(color: model.shadowColor,
                        radius: shadowRadius,
                        x: shadowOffset.width,
                        y: shadowOffset.height)
            
            VStack(spacing: 0) {
                Spacer()
                
                textView
                
                Spacer()
            }
        }
    }
}

// MARK: - Subviews
extension KeypadNumberButton {
    var textView: some View {
        Text(model.assignedNumber.rawValue)
            .withFont(model.numberFont)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .if(model.isEnabled) {
                $0.applyGradient(gradient: model.foregroundGradient)
            }
            .if(!model.isEnabled) {
                $0.foregroundColor(Colors.neutral_400.0)
            }
    }
}

struct KeypadNumberButton_Previews: PreviewProvider {
    static var previews: some View {
        KeypadNumberButton(model: .init(authScreenViewModel: .init(coordinator: .init()),
                                        assignedNumber: .one))
    }
}
