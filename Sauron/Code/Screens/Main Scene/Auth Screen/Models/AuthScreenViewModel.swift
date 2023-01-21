//
//  AuthScreenViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/17/23.
//

import SwiftUI
import Combine

/// View model for the auth screen | Interfaces with the authentication service to provide the user with a fluid GUI for accessing the application securely when auth is enabled
class AuthScreenViewModel: CoordinatedGenericViewModel {
    typealias coordinator = MainCoordinator
    
    // MARK: - Observed
    @ObservedObject var coordinator: MainCoordinator
    
    // MARK: - Published
    @Published var passcodeResetInProgress: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var passcodeTextEntry: String = ""
    @Published var verificationAttemptsRemaining: UInt = SRNUserAuthenticator.maxAuthAttempts
    @Published var userEnteredIncorrectPasscode: Bool = false
    @Published var disableUserEntry: Bool = false
    @Published var retryCountDown: UInt = 0
    
    // MARK: - Temporary variables
    /// Maintain the last state when the user presses the cancel button
    private var userDidEnterIncorrectPasscode: Bool = false
    
    // MARK: - Subscription
    var cancellables: Set<AnyCancellable> = []
    let scheduler: DispatchQueue = DispatchQueue.main,
        dismissalDelay: TimeInterval = 2 // Delays the dismissal in order to display any last special UI updates
    
    // MARK: - Static
    /// The amount of attempts remaining the user should be at or below to trigger the display of the attempts remaining counter
    let verificationAttemptLabelVisibilityThreshold: UInt = SRNUserAuthenticator.maxAuthAttempts - 1,
        maxPasscodeLength: Int = PasscodeValidator.maxPasscodeLength
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let validationManager: ValidatorManager = inject()
        let authService: SRNUserAuthenticator = inject()
        let userManager: UserManager = inject()
    }
    let dependencies = Dependencies()
    
    // MARK: - Styling
    // Colors / Gradients
    let backgroundColor: Color = Colors.white.0,
        titleColor: Color = Colors.black.0,
        verticalDividerColor: Color = Colors.primary_3.0,
        passcodeIndicatorActiveGradientColor: LinearGradient = Colors.gradient_1,
        passcodeIndicatorInactiveColor: Color = Colors.neutral_200.0,
        shadowColor: Color = Colors.shadow_1.0,
        bottomCTAButtonBackgroundGradient: LinearGradient = Colors.gradient_1,
        bottomCTAButtonTextColor: Color = Colors.permanent_white.0,
        attemptsRemainingTextColor: Color = Colors.attention.0,
        retryCoolDownTextColor: Color = Colors.black.0,
        loadingOverlayBackgroundColor: Color = Colors.backdrop.0
    
    // Fonts
    let titleFont: FontRepository = .heading_2,
        bottomCTAButtonFont: FontRepository = .body_L_Bold,
        counterLabelFont: FontRepository = .body_L_Bold
    
    // MARK: - Assets
    let loadingOverlayAppIcon: Image = Icons.getIconImage(named: .app_icon_transparent),
        loadingAnimation: LottieAnimationRepository = .radial_grid
    
    // MARK: - Actions
    var bottomCTAButtonPressed: (() -> Void) {
        HapticFeedbackDispatcher.interstitialCTAButtonPress()
        
        return shouldDisplayForgotPasscodeBottomCTAText ? ForgotPasscode : cancelPasscodeReset
    }
    
    /// Cancels the current operation
    var cancelPasscodeReset: (() -> Void) {
        return { [weak self] in
            guard let self = self,
                  !self.shouldDisplayForgotPasscodeBottomCTAText
            else { return }
            
            self.passcodeResetInProgress = false
            self.userEnteredIncorrectPasscode = self.userDidEnterIncorrectPasscode
            self.dependencies.authService.resetPasscodeResetParameters()
            
            // If the user is trying to set a passcode then clear all auth attempts as they don't count
            if self.shouldSetPasscode {
                self.dependencies
                    .authService
                    .resetAuthAttempts()
            }
        }
    }
    
    /// Triggers the passcode reset protocol, available after the user verifies with faceID of course
    var ForgotPasscode: (() -> Void) {
        return { [weak self] in
            guard let self = self,
                  self.shouldDisplayForgotPasscodeBottomCTAText
            else { return }
            
            self.dependencies
                .authService
                .authenticateWithFaceID()
                .receive(on: self.scheduler)
                .sink { authSuccessful in
                    if authSuccessful {
                        self.passcodeResetInProgress = true
                        self.userDidEnterIncorrectPasscode = self.userEnteredIncorrectPasscode
                        self.userEnteredIncorrectPasscode = false
                        self.dependencies.authService.userMustResetPasscode = true
                    }
                }
                .store(in: &self.cancellables)
        }
    }
    
    // MARK: - Convenience variables
    /// Prevent the user from adding more digits to their passcode if the max length is met
    var canAddDigit: Bool {
        guard !dependencies.authService.userMustWait
        else { return dependencies.authService.userMustWait}
        
        return passcodeTextEntry.count < maxPasscodeLength
    }
    
    var isPasscodeEmpty: Bool {
        return passcodeTextEntry.isEmpty
    }
    
    var shouldDisplayAuthAttempts: Bool {
        return verificationAttemptsRemaining <= verificationAttemptLabelVisibilityThreshold && !shouldDisplayRetryCountDown &&
        !passcodeResetInProgress
    }
    
    var shouldDisplayRetryCountDown: Bool {
        return dependencies
            .authService
            .userMustWait
    }
    
    /// Determines which localized copy to display by default for returning users
    var usePasscode: Bool {
        return dependencies
            .userManager
            .currentUser
            .userPreferredAuthMethod == .passcode
    }
    
    var useFaceID: Bool {
        return dependencies
            .userManager
            .currentUser
            .userPreferredAuthMethod == .faceID
    }
    
    var shouldSetPasscode: Bool {
        return !dependencies
            .userManager
            .currentUser
            .hasPasscode
        && !passcodeResetInProgress
    }
    
    var isConfirmingPasscodeEdit: Bool {
        return dependencies
            .authService
            .isVerifyingNewPasscode
    }
    
    /// Don't enable the forgot your passcode prompt when the user doesn't have a passcode
    var shouldDisableBottomCTA: Bool {
        return shouldSetPasscode && !isConfirmingPasscodeEdit
    }
    
    var shouldDisplayForgotPasscodeBottomCTAText: Bool {
        return (!passcodeResetInProgress
                || shouldSetPasscode) && !isConfirmingPasscodeEdit
    }
    
    var isUserInCoolDown: Bool {
        return dependencies
            .authService
            .userMustWait
    }
    
    /// Informs the view that its buttons should be disabled when the following condition is met
    var shouldDisableButtons: Bool {
        return disableUserEntry || isAuthenticated
    }
    
    // MARK: - Localized Text
    let resetPasscodeTitle: String = LocalizedStrings.getLocalizedString(for: .AUTH_SCREEN_TITLE_RESET_PASSCODE_NEWLINE),
        setPasscodeTitle: String = LocalizedStrings.getLocalizedString(for: .AUTH_SCREEN_TITLE_SET_PASSCODE_NEWLINE),
        incorrectPasscodeTitle: String = LocalizedStrings.getLocalizedString(for: .AUTH_SCREEN_TITLE_INCORRECT_PASSCODE_NEWLINE),
        passcodeConfirmationTitle: String = LocalizedStrings.getLocalizedString(for: .AUTH_SCREEN_TITLE_PASSCODE_CONFIRMATION_NEWLINE),
        continueWithPasscodeTitle: String = LocalizedStrings.getLocalizedString(for: .AUTH_SCREEN_TITLE_CONTINUE_WITH_PASSCODE_NEWLINE),
        continueWithFaceIDTitle: String = LocalizedStrings.getLocalizedString(for: .AUTH_SCREEN_TITLE_CONTINUE_WITH_FACEID_NEWLINE),
        authenticationSuccessfulTitle: String = LocalizedStrings.getLocalizedString(for: .AUTH_SCREEN_TITLE_AUTHENTICATION_SUCCESSFUL_NEWLINE),
        coolDownTitle: String = LocalizedStrings.getLocalizedString(for: .AUTH_SCREEN_TITLE_COOL_DOWN_NEWLINE),
        forgotPasscodeBottomCTAText: String = LocalizedStrings.getLocalizedString(for: .AUTH_SCREEN_BOTTOM_CTA_FORGOT_PASSCODE),
        cancelPasscodeEditingBottomCTAText: String = LocalizedStrings.getLocalizedString(for: .CANCEL)
    
    var retryCounterLabelText: String {
        /// Get the latest elapsed time since the user last opened up the application, if this isn't provided then the cool down duration's max time is shown instead first
        if let timeElapsed = dependencies
            .authService
            .loadRetryCoolDownPeriod() {
            let timeLeft = SRNUserAuthenticator.retryCoolDownDuration - timeElapsed
            
            return LocalizedStrings.getLocalizedString(for: .AUTH_SCREEN_RETRY_TIME_REMAINING_COUNTER) + " " + IntToTimeConversionHelper.convertIntToTimeStamp(number: timeLeft,
                                                                                                                                                               with: .short)
        }
        
        return LocalizedStrings.getLocalizedString(for: .AUTH_SCREEN_RETRY_TIME_REMAINING_COUNTER) + " " + IntToTimeConversionHelper.convertIntToTimeStamp(number: retryCountDown,
                                                                                                                                                           with: .short)
    }
    
    var attemptsRemainingCounterLabelText: String {
        if verificationAttemptsRemaining == 1 {
            return "\(verificationAttemptsRemaining) " + LocalizedStrings.getLocalizedString(for: .AUTH_SCREEN_ATTEMPTS_REMAINING_COUNTER_SINGULAR)
        }
        else {
            return "\(verificationAttemptsRemaining) " + LocalizedStrings.getLocalizedString(for: .AUTH_SCREEN_ATTEMPTS_REMAINING_COUNTER_PLURAL)
        }
    }
    
    /// Variable text display dependent on the current state of the auth screen
    var title: String {
        if isUserInCoolDown {
            return coolDownTitle
        }
        
        if isAuthenticated {
            return authenticationSuccessfulTitle
        }
        else if passcodeResetInProgress {
            return userEnteredIncorrectPasscode ? incorrectPasscodeTitle : (isConfirmingPasscodeEdit ? passcodeConfirmationTitle : resetPasscodeTitle)
        }
        else if shouldSetPasscode {
            return userEnteredIncorrectPasscode ? incorrectPasscodeTitle : (isConfirmingPasscodeEdit ? passcodeConfirmationTitle : setPasscodeTitle)
        }
        else if userEnteredIncorrectPasscode {
            return incorrectPasscodeTitle
        }
        
        // Return the standard title for passcode / faceID auth if no other protocol / state is currently active
        return useFaceID ? continueWithFaceIDTitle : continueWithPasscodeTitle
    }
    
    var bottomCTAButtonTitle: String {
        return shouldDisplayForgotPasscodeBottomCTAText ? forgotPasscodeBottomCTAText : cancelPasscodeEditingBottomCTAText
    }
    
    // MARK: - Models
    var obfuscatedPasscodeSegmentModels: [ObfuscatedPasscodeSegmentViewModel] = [
        .init(correspondingTextLength: 1),
        .init(correspondingTextLength: 2),
        .init(correspondingTextLength: 3),
        .init(correspondingTextLength: 4)
    ]
    
    // Key pad specific models
    var keyPadNumberKeys: [PasscodeKeyPadNumberButtonViewModel] {
        return [
            .init(authScreenViewModel: self,
                  assignedNumber: .one),
            .init(authScreenViewModel: self,
                  assignedNumber: .two),
            .init(authScreenViewModel: self,
                  assignedNumber: .three),
            .init(authScreenViewModel: self,
                  assignedNumber: .four),
            .init(authScreenViewModel: self,
                  assignedNumber: .five),
            .init(authScreenViewModel: self,
                  assignedNumber: .six),
            .init(authScreenViewModel: self,
                  assignedNumber: .seven),
            .init(authScreenViewModel: self,
                  assignedNumber: .eight),
            .init(authScreenViewModel: self,
                  assignedNumber: .nine),
            .init(authScreenViewModel: self,
                  assignedNumber: .zero)
        ]
    }
    
    var keyPadUtilityKeys: [PasscodeKeyPadUtilityButtonViewModel] {
        return [
            .init(authScreenViewModel: self,
                  utilityType: .faceID),
            .init(authScreenViewModel: self,
                  utilityType: .deletion)
        ]
    }
    
    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
        
        addSubscribers()
    }
    
    // MARK: - Subscriptions
    func addSubscribers() {
        let authService = dependencies.authService
        
        // Listen for changes to the text entry, when a valid entry is achieved pass the value on to the authenticator
        $passcodeTextEntry
            .sink { [weak self] in
                guard let self = self
                else { return }
                // Update UI
                for model in self.obfuscatedPasscodeSegmentModels {
                    model.toggleWith(text: $0)
                }
                
                // Validation
                let isValidPasscode = self.dependencies
                    .validationManager
                    .passcodeValidator
                    .validate($0)
                
                if isValidPasscode {
                    self.tryAuthentication()
                }
            }
            .store(in: &cancellables)
        
        // Update the amount of auth attempts remaining
        authService
            .$authenticationAttempts
            .receive(on: scheduler)
            .sink { [weak self] in
                guard let self = self
                else { return }
                
                self.verificationAttemptsRemaining = authService.getRemainingPasscodeAttempts
                
                self.userEnteredIncorrectPasscode = self.verificationAttemptsRemaining < SRNUserAuthenticator.maxAuthAttempts
                
                if $0 > 0 {
                    self.incorrectPasscodeEntered()
                }
            }
            .store(in: &cancellables)
        
        // Disable the UI when the user has to wait for the cool down period to expire
        authService
            .$userMustWait
            .receive(on: scheduler)
            .sink(receiveValue: { [weak self] in
                guard let self = self
                else { return }
                
                self.disableUserEntry = $0
                
                if $0 { self.clearAll() }
            })
            .store(in: &cancellables)
        
        // Sync the retry count down with the published values being emitted from the auth service
        authService
            .$coolDownPeriodCountDown
            .receive(on: scheduler)
            .assign(to: &$retryCountDown)
    }
}

// MARK: - Passcode Mutation
extension AuthScreenViewModel {
    func addDigit(digit: PasscodeKeyPadNumberButtonViewModel.Numbers) {
        guard canAddDigit else { return }
        
        passcodeTextEntry.append(digit.rawValue)
    }
    
    func clearLast() {
        guard !isPasscodeEmpty else { return }
        
        passcodeTextEntry.removeLast()
    }
    
    /// Clear the entered passcode in an animated fashion, usually triggered when the user has been put in a cool down
    func clearAll() {
        guard !isPasscodeEmpty else { return }
        
        // Note: The time interval wrapper only works properly w/ multiplication, division results in unexpected behavior
        for index in 0..<passcodeTextEntry.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(0.1 * Double(index))) { [weak self] in
                guard let self = self
                else { return }
                
                self.clearLast()
            }
        }
    }
}

// MARK: - Business Logic
extension AuthScreenViewModel {
    /// A user can select different authentication methods to gain authorization into the application,
    /// this method explores the routes beyond the passcode immediately and tries to get an authentication token for those methods
    func determineAuthVector() {
        isAuthenticated = false
        
        switch dependencies.userManager.currentUser.userPreferredAuthMethod {
        case .passcode:
            break
        case .faceID:
            useFaceIDToAuthenticate()
        case .none:
            isAuthenticated = dependencies.authService.authenticateUnsecuredUser()
            dismiss()
        }
    }
    
    /// Interfaces with the faceID auth method in the auth service to transform the states encapsulated within this model depending on the outcome of the future
    func useFaceIDToAuthenticate() {
        dependencies
            .authService
            .authenticateWithFaceID()
            .receive(on: scheduler)
            .sink { [weak self] in
                guard let self = self
                else { return }
                
                self.isAuthenticated =  $0
                
                if self.isAuthenticated {
                    self.dismiss()
                }
            }
            .store(in: &cancellables)
    }
    
    /// Try to authenticate the user, if the user is successfully authenticated then transition them into the main app content, if not then prompt them to try again
    func tryAuthentication() {
        let authService = dependencies.authService
        
        if passcodeResetInProgress && !isConfirmingPasscodeEdit || shouldSetPasscode && !isConfirmingPasscodeEdit {
            /// Set / Reset the user's passcode
            Task(priority: .high) {
                await authService
                    .resetPasscode(with: passcodeTextEntry)
                
                /// Clear the passcode and make the user re-enter it to confirm their change
                clearAll()
            }
        }
        else if isConfirmingPasscodeEdit {
            /// Verify that the user wants to reset their passcode
            Task(priority: .high) {
                isAuthenticated = await authService.verifyNewPasscode(with: passcodeTextEntry)
                
                /// Manually trigger an incorrect passcode flag because the auth service doesn't listen for incorrect passcodes when the user is resetting / setting their passcode
                if !isAuthenticated {
                    incorrectPasscodeEntered()
                }
                else {
                    dismiss()
                }
            }
        }
        else {
            /// Verify that the entered passcode matches what's saved
            Task(priority: .high) {
                isAuthenticated = await authService.authenticate(with: passcodeTextEntry)
                
                if isAuthenticated {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - State Mutation
    /// Warn the user of their mistake before they're locked out of the application
    func incorrectPasscodeEntered() {
        HapticFeedbackDispatcher.warningDidOccur()
        clearAll()
        
        userEnteredIncorrectPasscode = true
        userDidEnterIncorrectPasscode = userEnteredIncorrectPasscode
    }
    
    /// Resets all operations and clears the user's progress in this view back to a default state
    /// so that the view can be presented again with a clean slate
    func hardReset() {
        clearAll()
        disableUserEntry = false
        passcodeResetInProgress = false
        userEnteredIncorrectPasscode = false
        userDidEnterIncorrectPasscode = false
        retryCountDown = 0
        verificationAttemptsRemaining = SRNUserAuthenticator.maxAuthAttempts
        
        // Reset the auth service
        dependencies.authService.resetAuthenticationProccesses()
    }
    
    // MARK: - Navigation
    /// Only triggered when the user has been successfully authenticated
    func dismiss() {
        guard isAuthenticated
        else { return }
        
        hardReset()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissalDelay) {
            self.coordinator.dismissFullScreenCover()
        }
    }
}
