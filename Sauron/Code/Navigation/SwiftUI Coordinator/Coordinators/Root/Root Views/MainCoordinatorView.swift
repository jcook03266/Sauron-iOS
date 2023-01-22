//
//  MainCoordinatorView.swift
//  Sauron
//
//  Created by Justin Cook on 1/17/23.
//

import SwiftUI

struct MainCoordinatorView: CoordinatedView {
    typealias Router = MainRouter
    typealias Coordinator = MainCoordinator
    
    // MARK: - Observed
    @StateObject var coordinator: MainCoordinator
    @StateObject var tabbarModel: SRNTabbarViewModel
    
    // MARK: - Navigation States
    @State var sheetItemState: MainRoutes? = nil
    @State var fullCoverItemState: MainRoutes? = nil
    
    // MARK: - Animation States for blending root switches
    @State var show: Bool = false
    
    var rootSwitchAnimationBlendDuration: CGFloat = RootCoordinatorDelegate.rootSwitchAnimationBlendDuration
    var rootSwitchAnimation: Animation {
        return .linear(duration: rootSwitchAnimationBlendDuration)
    }
    
    var body: some View {
        synchronize(publishedValues: [$coordinator.fullCoverItem, $coordinator.sheetItem],
                    with: [$fullCoverItemState, $sheetItemState]) {
            NavigationStack(path: $coordinator.navigationPath) {
                ZStack {
                tabbar
                
                coordinator.rootView
                    .fullScreenCover(item: $fullCoverItemState,
                                     onDismiss: {
                        DispatchQueue.main.async {
                            coordinator.dismissFullScreenCover()
                        }
                    },
                                     content: { route in coordinator.router.view(for: route) })
                    .sheet(item: $sheetItemState,
                           onDismiss: {
                        DispatchQueue.main.async {
                            coordinator.dismissSheet()
                        }
                    },
                           content: { route in coordinator.router.view(for: route) })
                    .navigationDestination(for: Router.Route.self,
                                           destination: { route in coordinator.router.view(for: route) })
            }
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

// MARK: - Tabbar Implementation
extension MainCoordinatorView {
    var tabbar: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Spacer()
                SRNTabbar(model: tabbarModel)
            }
                
            Spacer()
        }
    }
}

struct MainCoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        MainCoordinatorView(coordinator: .init(),
                            tabbarModel: .init(coordinator: .init(), router: .init(coordinator: .init())))
    }
}

