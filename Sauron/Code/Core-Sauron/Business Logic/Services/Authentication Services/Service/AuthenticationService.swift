//
//  AuthenticationService.swift
//  Sauron
//
//  Created by Justin Cook on 1/16/23.
//

import Foundation
import CryptoSwift
import Darwin
import Combine

/// An authenticator service that provides a secure gateway into the application through whichever method the user selects
class SRNUserAuthenticator: ObservableObject {
    // MARK: - Authenticator Life Cycle Properties
    /// To prevent abuse a set amount of passcode attempts is enumerated.
    /// The expiration date of this retry wait period is persisted so the user cannot get out of waiting by restarting the device, what they can do is uninstall the app and reinstall it but that would wipe all data anyways
    @Published private(set) var authenticationAttempts: Int = 0
    @Published var retryCoolDownCountDown: Timer.TimerPublisher? = nil
    /// Restricts publically accessible methods from functioning and forces the UI to wait for the retry cool down to expire
    @Published var userMustWait: Bool = false
    
    private let maxAuthAttempts: Int = 5
    private let retryCoolDownDuration: Int = 300 // In seconds (5 mins)
    private var retryCoolDownExpirationDate: Date? = nil
    
    // MARK: - Reset passcode tracking
    /// Flag to tell the authenticator the passcode is currently being reset by the user
    @Published var userMustResetPasscode: Bool = false
    @Published var newPasscode: String? = nil
    /// Used to verify the new passcode by making the user enter it again
    @Published var newPasscodeVerification: String? = nil
    /// A temp buffer for the salt used by the new passcode to verify the second entry
    private var newPasscodeSalt: [UInt8]? = nil
    /// Flag tells the encryptor to use the newPasscodeSalt buffer
    private var isVerifyingNewPasscode: Bool {
        return newPasscodeSalt != nil && userMustResetPasscode
    }
    
    // MARK: - Token Life Cycle Properties
    /// Keeping track of all past tokens
    private var pastTokens: Set<PasscodeAuthToken> = []
    static let defaultAuthMethod: AuthMethod = .none
    static let defaultAuthTokenLifeCycleDuration: AuthTokenLifeCycle = .minutes_30
    
    /// The current credential, this is needed to grant the user access to the app's main content
    @Published private(set) var currentAuthCredential: PasscodeAuthToken? = nil
    
    // MARK: - Subscriptions
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Singleton instance for a single source of truth
    static let shared: SRNUserAuthenticator = .init()
    
    // MARK: - Convenience Methods
    var currentUser: SRNUser {
        return dependencies.userManager.currentUser
    }
    
    var isUserAuthorized: Bool {
        return currentAuthCredential != nil
    }
    
    var getRemainingPasscodeAttempts: Int {
        return maxAuthAttempts - authenticationAttempts
    }
    
    /// Use this to determine whether or not its the user's first time creating a passcode
    var doesPasswordExist: Bool {
        return currentUser.password != nil
    }
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        lazy var userDefaultsService: UserDefaultsService = SRNUserAuthenticator.Dependencies.inject()
        lazy var keychainManager: KeychainManager = SRNUserAuthenticator.Dependencies.inject()
        lazy var userManager: UserManager = SRNUserAuthenticator.Dependencies.inject()
        lazy var validator: ValidatorManager = SRNUserAuthenticator.Dependencies.inject()
    }
    var dependencies = Dependencies()
    
    private init() {
        setup()
    }
    
    // MARK: - Setup and user management
    private func setup() {
        loadRetryCoolDownPeriod()
        addSubscribers()
    }
    
    // MARK: - Subscriptions
    private func addSubscribers() {
        // Keep track of all authentication attempts and respond accordingly
        $authenticationAttempts
            .sink { [weak self] _ in
                guard let self = self
                else { return }
                
                self.isUserSuspicious()
            }
            .store(in: &cancellables)
        
        // Count down to the end of the cool down period and allow the user to
        retryCoolDownCountDown?
            .autoconnect()
            .scan(0) { [weak self] (timeElapsed, _ ) -> Int in
                guard let self = self
                else { return timeElapsed }
                
                return min(timeElapsed + 1, self.retryCoolDownDuration)
            }
            .sink { [weak self]  timeElapsed in
                guard let self = self
                else { return }
                
                if timeElapsed >= self.retryCoolDownDuration || Date.now >= self.retryCoolDownExpirationDate ?? .distantFuture {
                    self.expireRetryCoolDownPeriod()
                }
            }
            .store(in: &cancellables)
        
        // Observe the life cycle of the current token and invalidate it when it expires
        Timer.publish(every: 1,
                      on: .main,
                      in: .default)
        .autoconnect()
        .sink { [weak self] _ in
            guard let self = self,
                  let currentAuthCredential = self.currentAuthCredential
            else { return }
            
            if !currentAuthCredential.isValid {
                self.invalidateAuthToken()
            }
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Auth Token Life Cycle
    private func generateNewAuthToken() {
        // Ensure the last token was invalidated
        if currentAuthCredential != nil {
            invalidateAuthToken()
        }
        
        let expirationDate: Date = .now.advanced(by: currentUser.userPreferredAuthTokenLifeCycleDuration.getNumericalLiteral())
        
        self.currentAuthCredential = PasscodeAuthToken(expirationDate: expirationDate)
        addSubscribers()
    }
    
    private func invalidateAuthToken() {
        guard let currentAuthCredential = currentAuthCredential
        else { return }
        
        pastTokens.insert(currentAuthCredential)
        self.currentAuthCredential = nil
    }
    
    // MARK: - Security methods
    /// Triggers an invalidation event where the user no longer has access to the main app content unless they authenticate with their respective auth method
    func revokeUserAuthStatus() {
        invalidateAuthToken()
    }
    
    /// Verify the user's authorization status with a passcode (if any)
    /// Important: To authenticate with this method, a prior passcode must be saved and loaded, to create a new passcode use the  reset passcode process
    @discardableResult
    func authenticate(with passcode: String = "") async -> Bool {
        // Ensure the user isn't in a cool down
        guard !userMustWait
        else { return false }
        
        // Automatically allow methods that don't rely on the passcode
        if currentUser.userPreferredAuthMethod != .passcode {
            generateNewAuthToken()
            return true
        }
        
        // Validate that the user's input conforms to what is required by the validator
        guard dependencies.validator.passcodeValidator.validate(passcode)
        else { return false }
        
        guard let storedHashedPasscode = currentUser.password
        else { ErrorCodeDispatcher.AuthenticationErrors.triggerPreconditionFailure(for: .userPasswordDoesNotExist, using: "\(#function) \(#file)")()
        }
        
        guard let newHashedPasscode: String = await encrypt(passcode: passcode,
                                                            loadLastSalt: true).value
        else { return false }
        
        let passcodeMatches = storedHashedPasscode == newHashedPasscode
        
        guard passcodeMatches
        else { return passcodeMatches }
        
        generateNewAuthToken()
        dependencies.userManager.didAuthenticate()
        
        return passcodeMatches
    }
    
    /// Use this to set a temp passcode for the user to finalize as their new passcode choice
    func resetPasscode(with passcode: String) async {
        guard !userMustWait else { return }
        userMustResetPasscode = true
        
        newPasscode = await encrypt(passcode: passcode,
                                    loadLastSalt: false).value
    }
    
    /// Only save the new passcode once it has been verified by the user that they want to change it to that specifically
    @discardableResult
    func verifyNewPasscode(with passcode: String) async -> Bool {
        guard !userMustWait else { return false }
        
        newPasscodeVerification = await encrypt(passcode: passcode,
                                                loadLastSalt: false).value
        
        guard newPasscodeVerification == newPasscode
        else { return false }
        
        /// Save the new password to the keychain
        currentUser.password = newPasscode
        
        // Resetting all reset parameters
        if let newPasscodeSalt = newPasscodeSalt {
            saveSalt(salt: newPasscodeSalt)
        }
        
        resetPasscodeResetParameters()
        
        return await authenticate(with: passcode)
    }
    
    func resetPasscodeResetParameters() {
        guard !userMustWait else { return }
        
        newPasscodeSalt = nil
        newPasscode = nil
        newPasscodeVerification = nil
        userMustResetPasscode = false
    }
    
    private func encrypt(passcode: String,
                         loadLastSalt: Bool) -> Future<String?, Never>
    {
        return Future { [weak self] promise in
            guard let self = self
            else { return }
            
            DispatchQueue.global().async {
                
                var salt = [UInt8](repeating: 0, count: 16)
                arc4random_buf(&salt, salt.count)
                
                if loadLastSalt {
                    guard let lastSalt = self.getLastUsedSalt()
                    else {
                        ErrorCodeDispatcher.AuthenticationErrors.printErrorCode(for: .lastUsedSaltNotFound)
                        
                        return
                    }
                    
                    salt = lastSalt
                }
                else if self.isVerifyingNewPasscode,
                        let newPasscodeSalt = self.newPasscodeSalt {
                    salt = newPasscodeSalt
                }
                
                do {
                    let hashedPasscode = try Scrypt(password: passcode.bytes,
                                                    salt: salt,
                                                    dkLen: 8,
                                                    N: 16384,
                                                    r: 2,
                                                    p: 1)
                        .calculate()
                    
                    if self.userMustResetPasscode && self.newPasscodeSalt == nil {
                        self.newPasscodeSalt = salt
                    }
                    else if !loadLastSalt && !self.userMustResetPasscode {
                        // Only save the salt when there's no new passcode and no flag for loading the last used salt
                        self.saveSalt(salt: salt)
                    }
                    
                    promise(.success(hashedPasscode.toHexString()))
                } catch {
                    ErrorCodeDispatcher.AuthenticationErrors.triggerPreconditionFailure(for: .decryptionFailed, using: error.localizedDescription)()
                }
            }
        }
    }
    
    func deletePasscode() {
        expireRetryCoolDownPeriod()
        
        // Update persistence stores and secure stores
        dependencies.keychainManager.remove(key: .lastUsedSaltKey)
        dependencies.userDefaultsService.removeValueFor(key: .userAuthMethodPreference())
        dependencies.userDefaultsService.removeValueFor(key: .userAuthTokenLifeCyclePreference())
    }
    
    // MARK: - Retry cool down period methods
    private func loadRetryCoolDownPeriod() {
        guard let loadedRetryCoolDownExpirationDate = dependencies.userDefaultsService.getValueFor(key: .savedRetryCoolDownExpirationDate())
        else { return }
        
        self.userMustWait = true
        self.retryCoolDownExpirationDate = loadedRetryCoolDownExpirationDate
    }
    
    /// If the user tries too many times to guess their passcode then they're put in a wait period
    private func isUserSuspicious() {
        userMustWait = authenticationAttempts >= maxAuthAttempts
    }
    
    /// Set the expiration date for the wait period the suspicious user has to wait for
    private func setRetryCoolDown() {
        retryCoolDownExpirationDate = .now.advanced(by: TimeInterval(retryCoolDownDuration))
        
        dependencies.userDefaultsService.setValueFor(key: .savedRetryCoolDownExpirationDate(),
                                                     value: retryCoolDownExpirationDate)
    }
    
    /// Configure the timer publisher to fire every 1 second when the count down is active, this elapses the time up to the required wait duration where the expiration logic is triggered
    private func setRetryCoolDownTimeCountDown() {
        retryCoolDownCountDown = Timer.publish(every: 1,
                                               on: .main,
                                               in: .default)
        
        addSubscribers()
    }
    
    /// The user can now enter their passcode again, the wait period is over and all retry related parameters are invalidated
    private func expireRetryCoolDownPeriod() {
        userMustWait = false
        retryCoolDownExpirationDate = nil
        authenticationAttempts = 0
        retryCoolDownCountDown = nil
        dependencies.userDefaultsService.removeValueFor(key: .savedRetryCoolDownExpirationDate())
        
        addSubscribers()
    }
    
    // MARK: - Salt persistence
    private func getLastUsedSalt() -> [UInt8]? {
        guard let lastUsedSalt: Data = dependencies.keychainManager.load(key: .lastUsedSaltKey)
        else {
            ErrorCodeDispatcher.AuthenticationErrors.printErrorCode(for: .lastUsedSaltNotFound)
            
            // Force the user to reset their passcode if no prior salt was found, the UI must respond to this flag immediately upon this being set
            userMustResetPasscode = true
            
            return nil
        }
        
        return lastUsedSalt.bytes
    }
    
    /// Important: Please keep track of the last salt used to hash the user's passcode, if this isn't maintained then the user has to reset their passcode
    private func saveSalt(salt: [UInt8]) {
        dependencies.keychainManager.save(key: .lastUsedSaltKey, data: Data(salt))
    }
    
    // MARK: - Enum Properties
    // User Selected Authentication Methods
    enum AuthMethod: String, CaseIterable {
        case passcode, faceID, none
    }
    
    enum AuthTokenLifeCycle: String, CaseIterable {
        case minutes_15,
             minutes_30,
             hour_1,
             hour_2,
             never
        
        /// Get the literal number associated with the time interval (in seconds)
        func getNumericalLiteral() -> Double {
            switch self {
            case .minutes_15:
                return 900
            case .minutes_30:
                return 1800
            case .hour_1:
                return 3600
            case .hour_2:
                return 7200
            case .never:
                return .greatestFiniteMagnitude
            }
        }
        
        /// Gets a formatted string version of the time interval
        func getStringLiteral() -> String {
            switch self {
            case .minutes_15:
                return "15m"
            case .minutes_30:
                return "30m"
            case .hour_1:
                return "1h"
            case .hour_2:
                return "2h"
            case .never:
                return "∞"
            }
        }
    }
}
