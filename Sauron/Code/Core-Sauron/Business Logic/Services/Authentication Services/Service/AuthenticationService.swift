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
import LocalAuthentication

/// An authenticator service that provides a secure gateway into the application through whichever method the user selects
class SRNUserAuthenticator: ObservableObject {
    // MARK: - Authenticator Life Cycle Properties
    /// To prevent abuse a set amount of passcode attempts is enumerated.
    /// The expiration date of this retry wait period is persisted so the user cannot get out of waiting by restarting the device, what they can do is uninstall the app and reinstall it but that would wipe all data anyways
    @Published private(set) var authenticationAttempts: UInt = 0
    
    /// Restricts publically accessible methods from functioning and forces the UI to wait for the retry cool down to expire
    @Published var userMustWait: Bool = false
    @Published var coolDownPeriodCountDown: UInt = SRNUserAuthenticator.retryCoolDownDuration
    @Published var timeElapsed: UInt = 0
    
    static let maxAuthAttempts: UInt = 5
    static let retryCoolDownDuration: UInt = 300 // In seconds (5 mins)
    private var retryCoolDownExpirationDate: Date? = nil
    
    // MARK: - Reset passcode tracking
    /// Flag to tell the authenticator the passcode is currently being reset by the user
    @Published var userMustResetPasscode: Bool = false
    @Published var newPasscode: String? = nil
    /// Used to verify the new passcode by making the user enter it again
    @Published var newPasscodeVerification: String? = nil
    /// A temp buffer for the salt used by the new passcode to verify the second entry
    private var newPasscodeSalt: [UInt8]? = nil
    /// Flag tells the encryptor to use the newPasscodeSalt temp buffer
    var isVerifyingNewPasscode: Bool {
        return newPasscodeSalt != nil && userMustResetPasscode
    }
    
    // MARK: - Token Life Cycle Properties
    /// Keeping track of all past tokens
    private var pastTokens: Set<PasscodeAuthToken> = []
    static let defaultAuthMethod: AuthMethod = .none
    static let defaultAuthTokenLifeCycleDuration: AuthTokenLifeCycle = .minutes_30
    
    /// The current credential, this is needed to grant the user access to the app's main content
    @Published private(set) var currentAuthCredential: PasscodeAuthToken? = nil
    
    // MARK: - Hashing Algorithm Constants
    /// These are optimized values fed to the scrypt function to ensure a fast yet secure hashing process ~ 1 Second
    private let hashIterations: Int = 2048,
                blocksize: Int = 4,
                parallelismFactor: Int = 1,
                derivedKeyLength: Int = 32
    
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
    
    var getRemainingPasscodeAttempts: UInt {
        guard SRNUserAuthenticator.maxAuthAttempts > authenticationAttempts
        else { return 0 }
        
        return SRNUserAuthenticator.maxAuthAttempts - authenticationAttempts
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
            .sink { [weak self] in
                guard let self = self,
                      $0 > 0
                else { return }
                
                self.isUserSuspicious(from: $0)
            }
            .store(in: &cancellables)
        
        // Count down to the end of the cool down period
        Timer.publish(every: 1,
                      on: .main,
                      in: .default)
        .autoconnect()
        .sink { [weak self] _ in
            guard let self = self,
                  self.userMustWait
            else { return }
            
            self.timeElapsed += 1
            self.coolDownPeriodCountDown = SRNUserAuthenticator.retryCoolDownDuration - UInt(self.timeElapsed)
            
            if self.timeElapsed >= SRNUserAuthenticator.retryCoolDownDuration || Date.now >= self.retryCoolDownExpirationDate ?? .distantFuture {
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
                  let currentAuthCredential = self.currentAuthCredential,
                  !currentAuthCredential.isValid
            else { return }
            
            self.invalidateAuthToken()
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Auth Token Life Cycle
    private func generateNewAuthToken() {
        // Ensure that the last token was invalidated
        if currentAuthCredential != nil {
            invalidateAuthToken()
        }
        
        let expirationDate: Date = .now.advanced(by:10)
        
        self.currentAuthCredential = PasscodeAuthToken(expirationDate: expirationDate)
        dependencies.userManager.didAuthenticate()
        dependencies.userManager.isUserAuthenticated = true
        
        addSubscribers()
    }
    
    private func invalidateAuthToken() {
        guard let currentAuthCredential = currentAuthCredential,
              dependencies.userManager.canAuthenticate()
        else { return }
        
        pastTokens.insert(currentAuthCredential)
        self.currentAuthCredential = nil
        
        dependencies.userManager.isUserAuthenticated = false
    }
    
    // MARK: - Security methods
    /// Triggers an invalidation event where the user no longer has access to the main app content unless they authenticate with their respective auth method
    func revokeUserAuthStatus() {
        // Don't invalidate a non-auth user's token, they have constant access without verification until they specify otherwise
        guard dependencies.userManager.canAuthenticate()
        else { return }
        
        invalidateAuthToken()
    }
    
    @discardableResult
    /// Provides another vector of authentication for the user by allowing them to use biometrics to verify their authorization status
    func authenticateWithFaceID() -> Future<Bool, Never> {
        return Future { [weak self] promise in
            guard let self = self,
                  !self.userMustWait
            else { return }
            
            let context = LAContext()
            var error: NSError?,
                authSuccessful: Bool = false
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                         error: &error) {
                let reason = "The user has selected FaceID biometric verification as their authentication vector for the Authentication Screen"
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                       localizedReason: reason)
                { (success, authError) in
                    authSuccessful = success
                    if authSuccessful { self.generateNewAuthToken() }
                    
                    if let authError = authError {
                        ErrorCodeDispatcher.AuthenticationErrors.printErrorCode(for: .faceIDAuthNotPossible(error: authError.localizedDescription))
                    }
                    else {
                        promise(.success(authSuccessful))
                    }
                    
                    context.invalidate()
                }
            }
        }
    }
    
    @discardableResult
    /// Allows new users and users with no auth method selected to get into the main app without security clearance
    func authenticateUnsecuredUser() -> Bool {
        generateNewAuthToken()
        return true
    }
    
    /// Verify the user's authorization status with a passcode (if any)
    /// Important: To authenticate with this method, a prior passcode must be saved and loaded, to create a new passcode use the  reset passcode process
    @discardableResult
    func authenticate(with passcode: String = "") async -> Bool {
        // Ensure the user isn't in a cool down, and that they have an existing passcode
        guard !userMustWait,
              currentUser.hasPasscode
        else { return false }
        
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
        else {
            self.authenticationAttempts += 1
            return passcodeMatches
        }
        
        generateNewAuthToken()
        
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
    
    func resetAuthAttempts() {
        authenticationAttempts = 0
    }
    
    /// Resets all in progress processes relating to setting / resetting / verifying the user's passcode, note this method doesn't delete persistent data
    func resetAuthenticationProccesses() {
        resetPasscodeResetParameters()
        expireRetryCoolDownPeriod()
    }
    
    /**
     Securely encrypts the passed passcode using salting and iterative hashing
     
     - Scrypt hashing algorithm parameters listed below
     
     - Parameters:
        - N: iterations count (affects memory and CPU usage), e.g. 16384 or 2048
        - r : block size (affects memory and CPU usage), e.g. 8
        - p: parallelism factor (threads to run in parallel - affects the memory, CPU usage), usually 1
        - password: the input password (8-10 chars minimal length is recommended)
        - salt: securely-generated random bytes (64 bits minimum, 128 bits recommended)
        - derived_key_length: how many bytes to generate as output, e.g. 32 bytes (256 bits)
     
     - Returns: A promised value of either an optional string or never
     */
    private func encrypt(passcode: String,
                         loadLastSalt: Bool) -> Future<String?, Never>
    {
        return Future { [weak self] promise in
            guard let self = self
            else { return }
            
            DispatchQueue.global().async {
                var salt = [UInt8](repeating: 0, count: 16)
                
                // Load the last used salt / Use the temp salt when creating a new passcode verification / create a new salt for a new passcode
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
                else {
                    arc4random_buf(&salt, salt.count)
                }
                
                do {
                    let hashedPasscode = try Scrypt(password: passcode.bytes,
                                                    salt: salt,
                                                    dkLen: self.derivedKeyLength,
                                                    N: self.hashIterations,
                                                    r: self.blocksize,
                                                    p: self.parallelismFactor)
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
    @discardableResult
    func loadRetryCoolDownPeriod() -> UInt? {
        guard let loadedRetryCoolDownExpirationDate = dependencies.userDefaultsService.getValueFor(key: .savedRetryCoolDownExpirationDate())
        else { return nil }
        
        self.userMustWait = true
        self.retryCoolDownExpirationDate = loadedRetryCoolDownExpirationDate
        
        // Recalculate the time left until the cool down expires and update it accordingly
        self.timeElapsed = SRNUserAuthenticator.retryCoolDownDuration - UInt(Date.now.distance(to: loadedRetryCoolDownExpirationDate))
        
        return timeElapsed
    }
    
    /// If the user tries too many times to guess their passcode then they're put in a wait period
    private func isUserSuspicious(from attempts: UInt) {
        userMustWait = attempts >= SRNUserAuthenticator.maxAuthAttempts
        
        if userMustWait { setRetryCoolDown() }
    }
    
    /// Set the expiration date for the wait period the suspicious user has to wait for
    private func setRetryCoolDown() {
        retryCoolDownExpirationDate = .now.advanced(by: TimeInterval(SRNUserAuthenticator.retryCoolDownDuration))
        
        dependencies.userDefaultsService.setValueFor(key: .savedRetryCoolDownExpirationDate(),
                                                     value: retryCoolDownExpirationDate)
    }
    
    /// The user can now enter their passcode again, the wait period is over and all retry related parameters are invalidated
    private func expireRetryCoolDownPeriod() {
        userMustWait = false
        timeElapsed = 0
        coolDownPeriodCountDown = SRNUserAuthenticator.retryCoolDownDuration
        retryCoolDownExpirationDate = nil
        authenticationAttempts = 0
        dependencies.userDefaultsService.removeValueFor(key: .savedRetryCoolDownExpirationDate())
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
    
    /// Specifies the duration of a token's life, at the end of this life the token expires and a new one must be generated to grant the user access again
    enum AuthTokenLifeCycle: String, CaseIterable {
        case minutes_5,
             minutes_15,
             minutes_30,
             hour_1,
             hour_2,
             never
        
        /// Get the literal number associated with the time interval (in seconds)
        func getNumericalLiteral() -> Double {
            switch self {
            case .minutes_5:
                return 300
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
            case .minutes_5:
                return "5m"
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
