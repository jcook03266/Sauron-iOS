//
//  KeypadUtilityButton.swift
//  Sauron
//
//  Created by Justin Cook on 1/17/23.
//

import SwiftUI

/// A key pad button that serves some utility purpose such as deletion or triggering of a separate auth process
struct KeypadUtilityButton: View {
    // MARK: - Observed
    @StateObject var model: PasscodeKeyPadUtilityButtonViewModel
    
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
extension KeypadUtilityButton {
    var mainBody: some View {
        Button {
            model.action()
        } label: {
            buttonBody
        }
        .onLongPressGesture {
            model.longPressAction()
        }
        .buttonStyle(.genericSpringyShrink)
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
                
                iconView
                
                Spacer()
            }
        }
    }
}

// MARK: - Subviews
extension KeypadUtilityButton {
    var iconView: some View {
        model.buttonIcon
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .frame(width: size.width/2,
                   height: size.height/2)
            .if(model.isEnabled) {
                $0.foregroundColor(model.foregroundColor)
            }
            .if(!model.isEnabled) {
                $0.foregroundColor(Colors.neutral_400.0)
            }
    }
}

struct KeypadUtilityButton_Previews: PreviewProvider {
    static var previews: some View {
        KeypadUtilityButton(model: .init(authScreenViewModel: .init(coordinator: .init()),
                                  utilityType: .deletion))
    }
}
