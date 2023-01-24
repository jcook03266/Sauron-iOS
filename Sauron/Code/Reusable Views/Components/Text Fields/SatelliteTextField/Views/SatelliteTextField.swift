//
//  SatelliteTextField.swift
//  Sauron
//
//  Created by Justin Cook on 1/6/23.
//

import SwiftUI

struct SatelliteTextField: View {
    @Namespace private var satelliteTextField
    
    // MARK: - Observed
    @StateObject var model: SatelliteTextFieldModel
    
    // MARK: - States
    @FocusState private var textFieldFocused: Bool
    @State private var clearTextFieldButtonPressed: Bool = false
    @State private var clearTextFieldButtonRotationAmount: CGFloat = 0
    
    // MARK: - View Properties
    var animationDuration: CGFloat = 0.3
    var placeholderText: String {
        return model.placeholderText.isEmpty ? model.title : model.placeholderText
    }
    
    // MARK: - Dimensions
    var textFieldContainerSize: CGSize = CGSize(width: 325, height: 50)
    
    var textFieldSize: CGSize {
        return CGSize(width: textFieldContainerSize.width * 0.8,
                      height: textFieldContainerSize.height)
    }
    
    var satelliteButtonSize: CGSize {
        return CGSize(width: textFieldContainerSize.height,
                      height: textFieldContainerSize.height)
    }
    
    var clearTextFieldButtonSize: CGSize {
        return CGSize(width: 30, height: 30)
    }
    
    var clearTextFieldButtonOffset: CGSize {
        return CGSize(width: clearTextFieldButtonSize.width/4,
                      height: -clearTextFieldButtonSize.height/2)
    }
    
    var cornerRadius: CGFloat = 10,
        textFieldBorderWidth: CGFloat = 1.5
    
    // MARK: - Padding
    var textFieldLeadingPadding: CGFloat = 15,
        textFieldInteriorPadding: CGFloat = 15
    
    // MARK: - Subviews
    var clearTextFieldButton: some View {
        Group {
            if model.clearButtonEnabled
                && model.focused {
                CircularUtilityButton(action: {
                    clearTextFieldButtonPressed.toggle()
                    changeClearTextFieldButtonRotation()
                    
                    model.clearTextFieldButtonAction()
                },
                                      icon: model.clearTextFieldButtonIcon,
                                      backgroundColor: model.clearTextFieldButtonBackgroundColor,
                                      backgroundGradient: model.clearTextFieldButtonGradient,
                                      foregroundColor: model.clearTextFieldButtonIconTintColor,
                                      shadowColor: model.clearTextFieldButtonShadowColor,
                                      size: clearTextFieldButtonSize,
                                      isEnabled: .constant(!model.isEmpty()),
                                      animate: $model.focused)
                .zIndex(1)
                .transition(.scale.animation(.spring()))
                .rotationEffect(.degrees(clearTextFieldButtonRotationAmount))
                .animation(.spring(),
                           value: clearTextFieldButtonPressed)
                .offset(clearTextFieldButtonOffset)
            }
        }
    }
    
    var satelliteButton: some View {
        CircularUtilityButton(action: model.satelliteButtonAction,
                              icon: model.activeIcon,
                              backgroundColor: model.satelliteButtonBackgroundColor,
                              foregroundColor: model.satelliteButtonIconTint,
                              shadowColor: model.satelliteButtonShadowColor,
                              size: satelliteButtonSize,
                              isEnabled: .constant(true),
                              animate: $model.focused)
        .id(model.focused)
        .transition(.scale)
    }
    
    var textField: some View {
        TextField(placeholderText,
                  text: model.boundTextEntry)
        .foregroundColor(model.textFieldTextColor)
        .textInputAutocapitalization(model.textInputAutocapitalization)
        .textContentType(model.textContentType)
        .keyboardType(model.keyboardType)
        .autocorrectionDisabled(model.autoCorrectionDisabled)
        .focused($textFieldFocused)
        .submitLabel(model.submitLabel)
        .onSubmit { model.onSubmitAction?() }
        .padding([.leading, .trailing],
                 textFieldInteriorPadding)
    }
    
    var textFieldContainer: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(model.borderColor,
                          lineWidth: textFieldBorderWidth)
            .if(model.borderGradient != nil,
                transform: {
                $0.applyGradient(gradient: model.borderGradient!)
            })
    }
    
    var textFieldContainerInterior: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(model.fieldBackgroundColor)
            .shadow(color: model.shadowColor,
                    radius: model.shadowRadius ?? 0,
                    x: model.shadowOffset?.width ?? 0,
                    y: model.shadowOffset?.height ?? 0)
    }
    
    // MARK: - View Combinations
    var textFieldView: some View {
        ZStack(alignment: .center) {
            textFieldContainer
                .background(
                    textFieldContainerInterior
                )
                .overlay {
                    VStack {
                        HStack {
                            Spacer()
                            
                            clearTextFieldButton
                        }
                     Spacer()
                    }
                }
            
            textField
        }
        .frame(width: textFieldSize.width,
               height: textFieldSize.height)
        .zIndex(1)
        .padding([.leading],
                 textFieldLeadingPadding)
    }
    
    var mainContainer: some View {
        HStack(spacing: 0) {
            satelliteButton
            
            textFieldView
        }
        .onTapGesture {
            triggerFocusAction()
        }
        .onLongPressGesture(perform: {
            triggerFocusAction()
        })
        .onChange(of: textFieldFocused) { newValue in
            model.focused = newValue
        }
        .onChange(of: model.focused) { newValue in
            textFieldFocused = newValue
        }
        .animation(.easeInOut(duration: animationDuration),
                   value: model.focused)
    }
    
    var body: some View {
        mainContainer
    }
    
    /// Rotates the clear button ccw 360 degrees continuously without reversing
    private func changeClearTextFieldButtonRotation() {
        let debounceInterval: CGFloat = 0.1
        clearTextFieldButtonRotationAmount = -360
        
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval) {
            clearTextFieldButtonRotationAmount = 0
        }
    }
    
    private func triggerFocusAction() {
        guard model.enabled else { return }
        
        withAnimation(.easeInOut(duration: animationDuration)) {
            HapticFeedbackDispatcher.textFieldPressed()
            
            model.satelliteButtonAction()
            
            DispatchQueue.main.async {
                textFieldFocused = model.focused
            }
        }
    }
}

struct SatelliteTextField_Previews: PreviewProvider {
    static func getModel() -> SatelliteTextFieldModel {
        let searchBarTextFieldModel: SatelliteTextFieldModel = .init()
        
        searchBarTextFieldModel.configurator { model in
            // Main properties
            model.title = "Search Bar"
            model.placeholderText = "Search for assets"
            model.satelliteButtonInActiveIcon = Icons.getIconImage(named: .magnifyingglass)
            model.satelliteButtonActiveIcon = Icons.getIconImage(named: .xmark)
            
            // Satellite button
            model.satelliteButtonAction = {
                model.focused.toggle()
                
                model.shadowColor = model.focused ? Colors.shadow_1.0 : Colors.shadow_2.0
                model.satelliteButtonShadowColor = model.focused ?
                Colors.shadow_1.0 : Colors.shadow_2.0
            }
        }
        
        return searchBarTextFieldModel
    }
    
    static var previews: some View {
        SatelliteTextField(model: getModel())
            .previewDisplayName("Satellite TextField")
            .previewLayout(.sizeThatFits)
            .padding(20)
    }
}
