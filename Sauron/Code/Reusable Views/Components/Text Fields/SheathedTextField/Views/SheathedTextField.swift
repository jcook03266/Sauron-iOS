//
//  SheathedTextField.swift
//  Inspec
//
//  Created by Justin Cook on 11/23/22.
//

import SwiftUI

struct SheathedTextField: View {
    @Namespace private var sheathedTextField
    
    // MARK: - Observed
    @StateObject var model: SheathedTextFieldModel
    
    // MARK: - States
    @FocusState var textFieldFocused: Bool
    
    // MARK: - View Properties
    var animationDuration: CGFloat = 0.3
    var placeholderText: String {
        return model.placeholderText.isEmpty ? model.title : model.placeholderText
    }
    
    // MARK: - Dimensions
    var mainSize: CGSize = CGSize(width: 370, height: 60)
    var textFieldContainerSize: CGSize {
        return model.unsheathed && model.icon != nil ? CGSize(width: mainSize.width - (sideIconUnsheathedTrailingPadding * 0.8),
                                         height: mainSize.height) : mainSize
    }
    var textFieldSize: CGSize {
        return CGSize(width: model.inFieldButtonIcon != nil ? (textFieldContainerSize.width - (inFieldButtonTrailingPadding * 4)) : (textFieldContainerSize.width - (inFieldButtonTrailingPadding * 2)),
                      height: textFieldContainerSize.height)
    }
    var sheatheSize: CGSize {
        return model.unsheathed ? .zero : CGSize(width: textFieldContainerSize.width * 0.6,
                                                 height: textFieldContainerSize.height)
    }
    var sideIconBackgroundSize: CGSize {
        return CGSize(width: 60,
                      height: 40)
    }
    var sideIconSize: CGSize {
        return sideIconBackgroundSize.scaleBy(0.4)
    }
    var inFieldButtonSize: CGSize {
        return CGSize(width: 25,
                      height: 25)
    }
    var cornerRadius: CGFloat = 40,
        buttonCornerRadius: CGFloat = 40,
        borderWidth: CGFloat = 2
    
    // MARK: - Padding
    var textFieldLeadingPadding: CGFloat = 22,
        textFieldTrailingPadding: CGFloat = 22,
        inFieldButtonTrailingPadding: CGFloat = 22,
        titlePadding: CGFloat = 10,
        titleViewTrailingPadding: CGFloat = 5
    
    var sideIconLeadingPadding: CGFloat {
        return model.unsheathed ? 0 : 28
    }
    var sideIconUnsheathedTrailingPadding: CGFloat {
        return sideIconSize.width * 2.5
    }
    var sideIconTrailingPadding: CGFloat {
        return model.unsheathed ? sideIconUnsheathedTrailingPadding : 10
    }
    
    // MARK: - Subviews
    var sideIcon: some View {
        IconView_Circle_Fill(iconImage: model.icon,
                             iconColor: model.iconColor ?? .white,
                             backgroundColor: model.sheatheColor,
                             iconSize: sideIconSize,
                             backgroundSize: sideIconBackgroundSize,
                             enableShadow: model.unsheathed)
    }
    
    var inFieldButton: some View {
        Group {
            if model.inFieldButtonIcon != nil
                && model.inFieldButtonAction != nil {
                Button {
                    if model.unsheathed {
                        HapticFeedbackDispatcher.textFieldInFieldButtonPressed()
                        model.inFieldButtonAction?()
                    }
                } label: {
                    IconView_Circle_Fill(iconImage: model.inFieldButtonIcon,
                                         iconColor: model.inFieldButtonIconTint ?? .white,
                                         backgroundColor: .clear,
                                         iconSize: inFieldButtonSize,
                                         backgroundSize: inFieldButtonSize)
                }
                .buttonStyle(.genericSpringyShrink)
            }
        }
    }
    
    var sheathe: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(model.sheatheColor)
            .frame(width: sheatheSize.width,
                   height: sheatheSize.height)
    }
    
    var textFieldContainer: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(model.borderColor, lineWidth: borderWidth)
    }
    
    var textFieldContainerInterior: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(model.fieldBackgroundColor)
            .frame(width: textFieldContainerSize.width - borderWidth,
                   height: textFieldContainerSize.height - borderWidth)
            .shadow(color: model.shadowColor ?? .clear,
                    radius: model.shadowRadius ?? 0,
                    x: model.shadowOffset?.width ?? 0,
                    y: model.shadowOffset?.height ?? 0)
    }
    
    var titleView: some View {
        Text(model.title)
            .foregroundColor(model.textColor)
            .withFont(model.textFont)
            .fontWeight(model.fontWeight)
            .minimumScaleFactor(0.1)
    }
    
    var textField: some View {
        Group {
            if !model.protected {
                TextField(placeholderText,
                          text: model.boundTextEntry)
            }
            else {
                SecureField(placeholderText,
                            text: model.boundTextEntry)
            }
        }
        .foregroundColor(model.textFieldTextColor)
        .textInputAutocapitalization(model.textInputAutocapitalization)
        .textContentType(model.textContentType)
        .keyboardType(model.keyboardType)
        .disabled(!model.unsheathed)
        .autocorrectionDisabled(model.autoCorrectionDisabled)
        .focused($textFieldFocused)
        .frame(width: textFieldSize.width,
               height: textFieldSize.height)
        .padding([.leading],
                 textFieldLeadingPadding)
        .padding([.trailing],
                 textFieldTrailingPadding)
        .submitLabel(model.submitLabel)
        .onSubmit { model.onSubmitAction?() }
    }
    
    var mainContainer: some View {
        HStack(alignment: .center) {
            if model.unsheathed {
                Spacer()
            }
            ZStack(alignment: .leading) {
                textFieldContainer
                    .background(
                        textFieldContainerInterior
                    )
                textField
                
                HStack {
                    sheathe
                        .shadow(color: Colors.shadow_1.0,
                                radius: 0,
                                x: 3,
                                y: 0)
                        .overlay {
                            HStack(alignment: .center) {
                                sideIcon
                                    .padding([.leading],
                                             sideIconLeadingPadding)
                                    .padding([.trailing],
                                             sideIconTrailingPadding)
                                
                                if !model.unsheathed {
                                    if model.icon == nil {
                                        Spacer()
                                    }
                                    
                                    titleView.opacity(!model.unsheathed ? 1 : 0)
                                        .transition(.scale
                                            .animation(.easeInOut))
                                        .padding([.trailing], titleViewTrailingPadding)
                                }
                                
                                Spacer()
                            }
                        }
                        .onTapGesture {
                            triggerUnsheatheAction()
                        }
                    
                    Spacer()
                    
                    inFieldButton
                        .padding([.trailing],
                                 inFieldButtonTrailingPadding)
                }
            }
            .frame(width: textFieldContainerSize.width,
                   height: textFieldContainerSize.height)
        }
    }
    
    private func triggerUnsheatheAction() {
        withAnimation(.easeInOut(duration: animationDuration)) {
            if model.enabled {
                HapticFeedbackDispatcher.textFieldPressed()
                model.unsheathed.toggle()
                
                DispatchQueue.main.async {
                    textFieldFocused = model.unsheathed
                }
            }
        }
    }
    
    var body: some View {
        HStack {
            Spacer()
            mainContainer
                .onTapGesture {
                    guard !model.unsheathed else { return }
                    triggerUnsheatheAction()
                }
                .onLongPressGesture(perform: {
                    triggerUnsheatheAction()
                })
                .onChange(of: textFieldFocused) { newValue in
                    model.focused = newValue
                    
                    // Sheathe the textfield when the user unfocuses it to protect any information underneath
                    if model.protected && !model.focused {
                        model.unsheathed = false
                    }
                }
                .onChange(of: model.focused) { newValue in
                    textFieldFocused = newValue
                }
                .animation(.easeInOut(duration: animationDuration),
                           value: model.unsheathed)
            
            Spacer()
        }
    }
}

struct SheathedTextField_Previews: PreviewProvider {
    static func getModel() -> SheathedTextFieldModel {
        let passwordTextFieldModel: SheathedTextFieldModel = .init()
        
        passwordTextFieldModel.configurator { model in
            // Main properties
            model.title = "Password"
            model.placeholderText = "Cr3&TiV3Password!23"
            model.icon = Icons.getIconImage(named: .lock_fill)
            model.entryValidationEnabled = true
            model.validationCondition = { text in
                return text == "hello"
            }
            
            // In-field button
            model.inFieldButtonIcon = Icons.getIconImage(named: .eye_slash)
            model.protected = true
            model.inFieldButtonAction = {
                model.protected.toggle()
                
                model.inFieldButtonIcon = model.protected ? Icons.getIconImage(named: .eye_slash) : Icons.getIconImage(named: .eye)
            }
        }
        
        return passwordTextFieldModel
    }
    
    static var previews: some View {
        let model = getModel()
        
        SheathedTextField(model: model)
            .previewDisplayName("Sheathed TextField")
            .previewLayout(.sizeThatFits)
    }
}
