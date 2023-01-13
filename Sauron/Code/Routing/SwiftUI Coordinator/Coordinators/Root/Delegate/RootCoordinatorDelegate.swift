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
    var onboardingRootRoute: OnboardingRoutes {
        guard dependencies.featureFlagService.isOnboardingScreenEnabled
        else { return .home }
        
        return dependencies.ftueService.shouldDisplayOnboarding ? .onboarding : .home
    }
    var launchScreenRootRoute: LaunchScreenRoutes = .main
    var mainRootRoute: OnboardingRoutes = .onboarding
    
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
                    
                    return self.dependencies.ftueService.shouldDisplayFTUE
                }
                
                let trueChild = BinaryDecisionTree<RootCoordinatorDispatcher.RootCoordinators>.Node(value: RootCoordinatorDispatcher.RootCoordinators.onboardingCoordinator)
                
                let falseChild = BinaryDecisionTree<RootCoordinatorDispatcher.RootCoordinators>.Node(value: RootCoordinatorDispatcher.RootCoordinators.onboardingCoordinator)
                
                builder.addTrueChild(child: trueChild)
                builder.addFalseChild(child: falseChild)
            }
        
        return BinaryDecisionTree<RootCoordinatorDispatcher.RootCoordinators>(root: rootNode)
    }
    
    /// Transitions the user to the specified scene, with that scene handling any transition animations
    func switchActiveRoot(to root: RootCoordinatorDispatcher.RootCoordinators) {
        guard root != self.activeRoot else { return }
        
        activeRoot = root
        activeRootCoordinator = dispatcher.getRootCoordinatorFor(root: root)
    }
    
    // MARK: - Convenience functions
    func switchToLaunchScreenScene() {
        switchActiveRoot(to: .launchScreenCoordinator)
    }
    
    func switchToOnboardingScene() {
        switchActiveRoot(to: .onboardingCoordinator)
    }
    
    func switchToMainScene() {
        switchActiveRoot(to: .mainCoordinator)
    }
}
