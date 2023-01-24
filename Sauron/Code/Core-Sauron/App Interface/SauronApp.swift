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
        return rootCoordinatorDelegate.activeRootCoordinator!
    }
    
    var deepLinkManager: DeepLinkManager {
        return appService.deepLinkManager
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if AppService.isDebug {
                    // Notice: Not Deeplinkable, this is an isolated instance
                    MainCoordinator(rootCoordinatorDelegate: rootCoordinatorDelegate).coordinatorView()
                }
                else {
                    activeRootCoordinator.coordinatorView()
                }
            }
            .onOpenURL { url in
                deepLinkManager.manage(url)
            }
            .onAppear {}
        }
    }
}
