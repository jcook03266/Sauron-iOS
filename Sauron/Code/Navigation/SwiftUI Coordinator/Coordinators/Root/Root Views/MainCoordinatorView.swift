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
    typealias ChildTabCoordinator = Sauron.Coordinator
    
    // MARK: - Observed
    @StateObject var coordinator: MainCoordinator
    @StateObject var tabbarModel: SRNTabbarViewModel
    
    // MARK: - Styling
    private let backgroundGradient: LinearGradient = Colors.gradient_6
    private var backgroundColor: Color {
        return currentTab != .settings ?
        Color.clear :
        Colors.permanent_black.0
    }
    
    // MARK: - Convenience
    var currentChildTabCoordinator: any ChildTabCoordinator {
        return coordinator
            .getTabCoordinator(for: currentTab)
    }
    
    var currentTab: SRNTabbarViewModel.tabs {
        return tabbarModel.currentTab
    }
    
    var statusBarVisibilityForCurrentTab: Bool {
        return currentChildTabCoordinator.statusBarHidden
    }
    
    // MARK: - Navigation States (Part of protocol | can't be privatized)
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
                ZStack {
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
                        .id(tabbarModel.currentTab)
                        .zIndex(1)
                        .transition(
                            .asymmetric(insertion: .slideBackwards,
                                        removal: .offset(x: 1000)))
                    
                    tabbar
                        .zIndex(2)
                }
                .background(backgroundColor)
                .background(backgroundGradient)
                .animation(.easeInOut,
                           value: tabbarModel.currentTab)
        }
                    .opacity(show ? 1 : 0)
                    .onAppear {
                        withAnimation(rootSwitchAnimation) {
                            show = true
                        }
                    }
                    .statusBarHidden(statusBarVisibilityForCurrentTab)
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
                            tabbarModel: .init(coordinator: .init(),
                                               router: .init(coordinator: .init())))
    }
}

