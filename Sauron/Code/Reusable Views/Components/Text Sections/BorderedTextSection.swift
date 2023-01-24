//
//  BorderedTextSection.swift
//  Inspec
//
//  Created by Justin Cook on 11/5/22.
//

import SwiftUI

struct BorderedTextSection: View {
    var backgroundColor: Color = Color.clear,
        textColor: Color = Colors.permanent_white.0,
        borderColor: Color = Colors.primary_1.0,
        font: FontRepository = .body_S,
        fontWeight: Font.Weight = .medium,
        message: (String?, LocalizedStringKey?),
        borderWidth: CGFloat = 2,
        verticalPadding: CGFloat = 4,
        borderTrailingPadding: CGFloat = 6,
        maxHeight: CGFloat? = 150
    
    @ObservedObject var expansionController: TextSectionExpansionController
    
    var isExpanded: Bool {
        return expansionController.expanded
    }
    var expansionIndicatorAngle: Angle {
        return Angle(degrees: (isExpanded ? 180 : 0))
    }
    
    var body: some View {
        VStack {
            HStack {
                Rectangle()
                    .fill(borderColor)
                    .frame(width: borderWidth)
                    .padding(.trailing, borderTrailingPadding)
                ScrollView {
                    if let message = message.0 {
                        Text(message)
                            .withFont(font)
                            .fontWeight(fontWeight)
                            .padding([.top, .bottom], verticalPadding / 2)
                    }
                    else if let message = message.1 {
                        Text(message)
                            .withFont(font)
                            .fontWeight(fontWeight)
                            .padding([.top, .bottom], verticalPadding / 2)
                    }
                }
                .background(
                    backgroundColor
                )
            }
            .onTapGesture {
                expand()
            }
            .animation(.spring(),
                       value: isExpanded)
            .frame(maxHeight: isExpanded ? nil : maxHeight)
            .fixedSize(horizontal: false,
                       vertical: true)
        }
    }
    
    func expand() {
        guard expansionController.canViewExpand() else { return }
        
        expansionController.toggle()
    }
}


/// Controls the expansion of this text section by keeping track of the expansion state and original view size to enable  size restoration
class TextSectionExpansionController: ObservableObject {
    @Published var expanded: Bool
    @State private var enableExpansion: Bool
    
    init(expanded: Bool = false,
         enableExpansion: Bool = true) {
        self.expanded = expanded
        self.enableExpansion = enableExpansion
    }
    
    func canViewExpand() -> Bool {
        return enableExpansion
    }
    
    func toggle() {
        HapticFeedbackDispatcher.textSectionExpanded()
        expanded.toggle()
    }
}

struct BorderedTextSection_Previews: PreviewProvider {
    static var previews: some View {
        BorderedTextSection(message: ("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", nil),
                            expansionController: .init())
    }
}
