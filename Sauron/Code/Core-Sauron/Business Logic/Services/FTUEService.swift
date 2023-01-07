//
//  FTUEService.swift
//  Sauron
//
//  Created by Justin Cook on 12/25/22.

/// First time user experience service that manages the app state responsible for displaying the relevant scenes and performing necessary runtime logic when the app is first installed and used by a user
protocol FTUEServiceProtocol {
    // MARK: - Static States
    /// True - Onboarding root coordinator : False - Main
    var isComplete: Bool { get }
    /// True - Display Onboarding : False - Don't
    var didCompleteOnboarding: Bool { get }
    /// Setting this to false overrides the state and disables the app's FTUE logic
    var isEnabled: Bool { get }
    /// Used to determine whether or not FTUE logic should be triggered at app startup
    var shouldDisplayFTUE: Bool { get }
    /// Decides whether or not to skip the onboarding route based on if the user has viewed that set of screens yet
    var shouldDisplayOnboarding: Bool { get }
    
    // MARK: - Functions
    func completeFTUE()
    func completeOnboardingFTUE()
}

class FTUEService: FTUEServiceProtocol {
    // MARK: - Static States
    private(set) var isEnabled: Bool = true
    
    private(set) var isComplete: Bool {
        get {
            return dependencies.userDefaultsService.getValueFor(type: Bool.self,
                                                                key: .didCompleteFTUE())
        }
        set {
            dependencies.userDefaultsService.setValueFor(type: Bool.self,
                                                         key: .didCompleteFTUE(), value: newValue)
        }
    }
    
    private(set) var didCompleteOnboarding: Bool {
        get {
            return dependencies.userDefaultsService.getValueFor(type: Bool.self,
                                                                key: .didCompleteOnboarding())
        }
        set {
            dependencies.userDefaultsService.setValueFor(type: Bool.self,
                                                         key: .didCompleteOnboarding(), value: newValue)
        }
    }
    
    var shouldDisplayFTUE: Bool {
        return isEnabled && !isComplete
    }
    var shouldDisplayOnboarding: Bool {
        return shouldDisplayFTUE && !didCompleteOnboarding
    }
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let userDefaultsService: UserDefaultsService = inject()
    }
    let dependencies = Dependencies()
    
    // MARK: - State Mutating Functions
    func completeFTUE() {
        self.isComplete = true
    }
    func completeOnboardingFTUE() {
        self.didCompleteOnboarding = true
    }
}

