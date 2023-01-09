//
//  PreferenceBottomSheetSelectionChipView.swift
//  Sauron
//
//  Created by Justin Cook on 1/8/23.
//

import SwiftUI

struct PreferenceBottomSheetSelectionChipView<T: Coordinator>: View {
    // MARK: - Observed
    @StateObject var model: PreferenceBottomSheetViewModel<T>.PreferenceBottomSheetSelectionChipViewModel
    @ObservedObject var parentModel: PreferenceBottomSheetViewModel<T>
       
       // MARK: - Dimensions
    private let size: CGSize = .init(width: 70, height: 30),
                cornerRadius: CGFloat = 10
    
    // MARK: - Padding
    private let horizontalPadding: CGFloat = 5,
                verticalPadding: CGFloat = 5
       
       // MARK: - Styling
       // Shadow
       private var shadowOffset: CGSize {
           return model.isSelected ? .init(width: 0, height: 3) : .zero
       }
       private var shadowColor: Color {
           return model.isSelected ? Colors.shadow_1.0 : Color.clear
       }
       private var shadowRadius: CGFloat {
           return model.isSelected ? 2 : 0
       }
    
    // MARK: - Subviews
    var backgroundView: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(model.backgroundColor)
            .shadow(color: model.shadowColor,
                    radius: shadowRadius,
                    x: shadowOffset.width,
                    y: shadowOffset.height)
    }
    
    var textView: some View {
        Text(model.label)
            .withFont(model.font)
            .fontWeight(model.fontWeight)
            .foregroundColor(model.foregroundColor)
            .minimumScaleFactor(0.1)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .padding([.top, .bottom], verticalPadding)
            .padding([.leading, .trailing], horizontalPadding)
    }
    
    // MARK: - Sections
    var chipBody: some View {
        Button {
            HapticFeedbackDispatcher.genericButtonPress()
            model.action()
            
            parentModel.currentlySelectedChip = model
        } label: {
            ZStack(alignment: .center) {
                backgroundView
                textView
            }
        }
        .buttonStyle(.genericSpringyShrink)
        .frame(width: size.width,
               height: size.height)
    }
    
    var body: some View {
        chipBody
            .onChange(of: parentModel.currentlySelectedChip) { newChip in
                
                /// Updates all rows depending on the newest selected row
                if newChip != model {
                    model.isSelected = false
                }
                else {
                    model.isSelected = true
                }
            }
    }
}

struct PreferenceBottomSheetSelectionChipView_Previews: PreviewProvider {
    static var previews: some View {
        let parentModel = BottomSheetDispatcher.getCurrencyPreferenceModel(using: OnboardingCoordinator())
        
        PreferenceBottomSheetSelectionChipView(model: parentModel.defaultChip, parentModel: parentModel)
            .previewLayout(.sizeThatFits)
            .padding(20)
    }
}
