//
//  LaunchScreenCoordinatorView.swift
//  Sauron
//
//  Created by Justin Cook on 12/23/22.
//

import SwiftUI

struct LaunchScreenCoordinatorView: CoordinatedView {
    typealias Router = LaunchScreenRouter
    typealias Coordinator = LaunchScreenCoordinator
    
    // MARK: - Observed
    @StateObject var coordinator: LaunchScreenCoordinator
    
    // MARK: - Navigation States
    @State var sheetItemState: LaunchScreenRoutes? = nil
    @State var fullCoverItemState: LaunchScreenRoutes? = nil
    
    // MARK: - Animation States for blending root switches
    @State var show: Bool = true // This view has to be shown immediately, so no animation
    
    var rootSwitchAnimationBlendDuration: CGFloat = RootCoordinatorDelegate.rootSwitchAnimationBlendDuration
    var rootSwitchAnimation: Animation {
        return .linear(duration: rootSwitchAnimationBlendDuration)
    }
    
    var body: some View {
        synchronize(publishedValues: [$coordinator.fullCoverItem, $coordinator.sheetItem],
                    with: [$fullCoverItemState, $sheetItemState]) {
            NavigationStack(path: $coordinator.navigationPath) {
                coordinator.rootView
                    .fullScreenCover(item: $fullCoverItemState,
                                     content: { route in coordinator.router.view(for: route) })
                    .sheet(item: $sheetItemState,
                           content: { route in coordinator.router.view(for: route) })
                    .navigationDestination(for: Router.Route.self,
                                           destination: { route in coordinator.router.view(for: route) })
            }
        }
                    .opacity(show ? 1 : 0)
                    .onAppear {
                        withAnimation(rootSwitchAnimation) {
                            show = true
                        }
                    }
                    .statusBarHidden(coordinator.statusBarHidden)
    }
}
