//
//  RootCoordinator.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI

class RootCoordinatorDelegate: ObservableObject {
    // MARK: - Published
    @Published var activeRoot: RootCoordinatorDispatcher.RootCoordinators!
    
    // MARK: - Root Coordinator management
    var dispatcher: RootCoordinatorDispatcher!
    var activeRootCoordinator: (any RootCoordinator)!
    
    // MARK: - Singleton Instance to prevent reinstantiation at runtime
    static let shared: RootCoordinatorDelegate = .init()
    
    // MARK: - Launch Screen Manager
    private var launchScreenManager: LaunchScreenManager = .shared
    
    // MARK: - Reference values to be used whenever needed
    static var rootSwitchAnimationBlendDuration: CGFloat = 0.75
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        var ftueService: FTUEService = inject(),
            featureFlagService: FeatureFlagService = inject()
    }
    internal var dependencies = Dependencies()
    
    // MARK: - Active Root Coordinator Decision Tree
    private lazy var decisionTree: BinaryDecisionTree<RootCoordinatorDispatcher.RootCoordinators> = buildDecisionTree()
    // In case the decision tree falls through, this is the fallback root
    private let defaultRoot = RootCoordinatorDispatcher.RootCoordinators.mainCoordinator
    
    // MARK: - Root Routes for Root Coordinators
    var launchScreenRootRoute: LaunchScreenRoutes = .main
    var onboardingRootRoute: OnboardingRoutes {
        guard dependencies
            .featureFlagService
            .isOnboardingScreenEnabled
        else { return .getStarted }
        
        return dependencies.ftueService.shouldDisplayOnboarding ? .main : .getStarted
    }
    var mainRootRoute: MainRoutes = .home
    
    // MARK: - Convenience
    var canNavigateToMainScene: Bool {
        return !dependencies.ftueService.shouldDisplayFTUE
    }
    
    var canNavigateToOnboardingScene: Bool {
        return dependencies.ftueService.shouldDisplayFTUE
    }
    
    private init() {
        self.dispatcher = .init(delegate: self)
        
        performOnLoadTasks()
    }
    
    func performOnLoadTasks() {
        switchToLaunchScreenScene()
        performLaunchScreenBridge()
    }
    
    func performLaunchScreenBridge() {
        launchScreenManager.onComplete { [weak self] in
            guard let self = self else { return }
            
            // The decision tree decides which scene to navigate to when the launch screen is done
            let activeRootNode = self.decisionTree.execute()
            if let activeRoot = activeRootNode?.value {
                self.switchActiveRoot(to: activeRoot)
            }
            else {
                self.switchActiveRoot(to: self.defaultRoot)
            }
        }
    }
    
    private func buildDecisionTree() -> BinaryDecisionTree<RootCoordinatorDispatcher.RootCoordinators> {
        let rootNode = BinaryDecisionTree<RootCoordinatorDispatcher.RootCoordinators>.Node<RootCoordinatorDispatcher.RootCoordinators>()
        
        rootNode
            .build { builder in
                builder.addDecision { [weak self] in
                    guard let self = self else { return false }
                    return self.canNavigateToOnboardingScene
                }
                
                // Onboarding Coordinator
                let trueChild = BinaryDecisionTree<RootCoordinatorDispatcher.RootCoordinators>.Node(value: RootCoordinatorDispatcher.RootCoordinators.onboardingCoordinator)
                
                // Main Coordinator
                let falseChild = BinaryDecisionTree<RootCoordinatorDispatcher.RootCoordinators>.Node(value: RootCoordinatorDispatcher.RootCoordinators.mainCoordinator)
                
                builder.addTrueChild(child: trueChild)
                builder.addFalseChild(child: falseChild)
            }
        
        return BinaryDecisionTree<RootCoordinatorDispatcher.RootCoordinators>(root: rootNode)
    }
    
    /// Transitions the user to the specified scene, with that scene handling any transition animations
    func switchActiveRoot(to root: RootCoordinatorDispatcher.RootCoordinators) {
        guard root != self.activeRoot else { return }
        
        // prevent the user from access restricted scenes
        if root == .mainCoordinator && !canNavigateToMainScene
            || root == .onboardingCoordinator && !canNavigateToOnboardingScene
        { return }
        
        activeRoot = root
        activeRootCoordinator = dispatcher.getRootCoordinatorFor(root: root)
    }
    
    // MARK: - Convenience functions
    func switchToLaunchScreenScene() {
        /// Switching to the launch screen after it has already been presented is only available in a debugging environment, no deeplinking is provided
        switchActiveRoot(to: .launchScreenCoordinator)
    }
    
    func switchToOnboardingScene() {
        /// Only first time users can access the onboarding screen
        guard canNavigateToOnboardingScene
        else { return }
        
        switchActiveRoot(to: .onboardingCoordinator)
    }
    
    func switchToMainScene() {
        /// Ensure that the user has completed the FTUE first, they can't bypass the hard lock
        guard canNavigateToMainScene
        else { return }
        
        switchActiveRoot(to: .mainCoordinator)
    }
}
