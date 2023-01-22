//
//  UserManager.swift
//  Sauron
//
//  Created by Justin Cook on 1/14/23.
//

import Foundation
import Combine

/// A general manager that allows for a higher level interface with the current user model
class UserManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var currentUser: SRNUser!
    /// Keeps track of how long the user has been using the application
    @Published private(set) var currentSessionDuration: Double = 0 // In seconds
    @Published var isUserAuthenticated: Bool = false
    
    // MARK: - Singleton
    static let shared: UserManager = .init()
    
    // MARK: - Subscriptions
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        lazy var authenticator: SRNUserAuthenticator = UserManager.Dependencies.inject()
    }
    var dependencies = Dependencies()
    
    private init() {
        setup()
    }
    
    // MARK: - Setup
    private func addSubscribers() {
        // Track the session duration
        Timer.publish(every: 1,
                      on: .main,
                      in: .default)
        .autoconnect()
        .sink { [weak self] _ in
            guard let self = self
            else { return }
            
            self.currentSessionDuration += 1
        }
        .store(in: &cancellables)
    }
    
    private func setup() {
        getUser()
    }
    
    // MARK: - User Data Mutation
    func changeUserPeferredAuthMethod(to method: SRNUserAuthenticator.AuthMethod) {
        currentUser.userPreferredAuthMethod = method
    }
    
    func changeUserPreferredAuthTokenLifeCycleDuration(to duration: SRNUserAuthenticator.AuthTokenLifeCycle) {
        // A non-auth user can't change their auth token life cycle duration because the token is immortal
        guard canAuthenticate()
        else { return }
        
        currentUser.userPreferredAuthTokenLifeCycleDuration = duration
    }
    
    // MARK: - User Life Cycle Methods
    /// Revoke the user's current authorization state and force them to re-auth to regain access
    func logout() {
        /// Logging out does nothing if the user doesn't have to authenticate
        guard currentUser.userPreferredAuthMethod != .none
        else { return }
        
        dependencies.authenticator.revokeUserAuthStatus()
    }
    
    /// Triggered when the user has authenticated themselves successfully
    func didAuthenticate() {
        self.isUserAuthenticated = true
        startSession()
    }
    
    func getUserAuthPreference() -> SRNUserAuthenticator.AuthMethod {
        return currentUser.userPreferredAuthMethod
    }
    
    /// Only users that have selected an auth method can authenticate themselves
    func canAuthenticate() -> Bool {
        return getUserAuthPreference() != .none
    }
    
    private func startSession() {
        currentSessionDuration = 0
        addSubscribers()
    }
    
    private func getUser() {
        self.currentUser = SRNUser()
    }
}
