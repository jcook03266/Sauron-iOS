//
//  SauronApp.swift
//  Sauron
//
//  Created by Justin Cook on 12/16/22.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    return true
  }
}

@main
struct SauronApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // MARK: - Observed
    @StateObject var rootCoordinatorDelegate: RootCoordinatorDelegate = .shared
    @StateObject var appService: AppService = .shared
    
    // MARK: - Convenience variables
    var activeRootCoordinator: any RootCoordinator {
        return appService.rootCoordinatorDelegate.activeRootCoordinator
    }
    var deepLinkManager: DeepLinkManager {
        return appService.deepLinkManager
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if AppService.isDebug {
                    OnboardingCoordinator(rootCoordinatorDelegate: .init()).view(for: .home)
                }
                else {
                    appService.activeRootCoordinator.coordinatorView()
                }
            }
            .onOpenURL { url in
                appService.deepLinkTarget = deepLinkManager.manage(url: url)
            }
            .onAppear {}
        }
    }
}