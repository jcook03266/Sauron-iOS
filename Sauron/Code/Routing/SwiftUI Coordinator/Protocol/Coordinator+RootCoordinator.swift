//
//  Coordinator+RootCoordinator.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI

/// The coordinator pattern is used to greatly simplify the navigational logic of the application by abstracting the task of routing to new scenes, presenting popovers, bottom sheets, and web views, to a respective controller 'Coordinator'. This coordinator has child coordinators which it can manage, as well as be managed by a parent coordinator responsible for itself. At the top of the hierarchy is the root coordinator which is the first coordinator used to navigate the user through the application
// MARK: - Coordinator Protocol
public protocol Coordinator: ObservableObject {
    associatedtype Router: Routable
    associatedtype Body: View
    
    var parent: any Coordinator { get }
    var children: [any Coordinator] { get set }
    var rootRoute: Router.Route! { get }
    var rootView: AnyView! { get set } // View at the bottom of the navigation state corresponding to this coordinator
    var dispatcher: CoordinatorDispatcher { get }
    var deferredDismissalActionStore: [Router.Route : (() -> Void)?] { get set } // Stores closures to be executed when a view is dismissed later on after being presented
    var currentRoute: Router.Route { get }
    
    // MARK: - Published instance variables
    var router: Router! { get set }
    var navigationPath: [Router.Route] { get set } // Keeps track of all current values in the nav path (active navigation paths)
    var sheetItem: Router.Route? { get set }
    var fullCoverItem: Router.Route? { get set }
    var statusBarHidden: Bool { get set }
    
    @ViewBuilder
    func start() -> Void // Any abstract logic to be executed when the coordinator is first initialized
}

extension Coordinator {
    var currentRoute: Router.Route { return navigationPath.last ?? rootRoute }
}

/// Custom view used to hold the states of items currently being presented by the embedded coordinator
protocol CoordinatedView: View {
    associatedtype Router: Routable
    associatedtype Coordinator: RootCoordinator
    
    // MARK: - StateObject, implement independently inside the view itself, the view owns this coordinator and persists its state throughout view updates
    // var coordinator: Coordinator { get set }
    
    // MARK: - Navigation States (Necessary for navigation, you can't update published values in view updates)
    var sheetItemState: Router.Route? { get set }
    var fullCoverItemState: Router.Route? { get set }
    
    // MARK: - Animation States for blending root switches
    var show: Bool { get set }
    
    var rootSwitchAnimationBlendDuration: CGFloat { get set }
    var rootSwitchAnimation: Animation { get }
}

extension CoordinatedView {
    func synchronize(published: Binding<Router.Route?>,
                     with state: Binding<Router.Route?>,
                     using content: @escaping () -> any View) -> some View {
        AnyView(content())
            .onChange(of: published.wrappedValue) { published in
                state.wrappedValue = published
            }
    }
    
    func synchronize(publishedValues: [Binding<Router.Route?>],
                     with states: [Binding<Router.Route?>],
                     using content: @escaping () -> any View) -> some View {
        
        var view = AnyView(content())
        
        guard publishedValues.count == states.count
        else { return view }
        
        for (index, _) in publishedValues.enumerated() {
            let publishedValue = publishedValues[index]
            let state = states[index]
            
            view = AnyView(
                synchronize(published: publishedValue,
                            with: state) {
                                view
                            }
            )
        }
        
        return view
    }
}

// MARK: - Router interface + Coordinator on-init logic execution stub
extension Coordinator {
    func start() {}
    
    func view(for route: Router.Route) -> Self.Body {
        return router.view(for: route) as! Self.Body
    }
    
    var dispatcher: CoordinatorDispatcher {
        return CoordinatorDispatcher(parentCoordinator: self)
    }
}

// MARK: - Child coordinator life cycle management
extension Coordinator {
    /// Present the given coordinator which will take over the current root view and define its own view hierarchy
    public func present(coordinator: any Coordinator,
                        onPresent: (() -> Void)? = nil) {
        dismissSheet()
        dismissFullScreenCover()
        clearDismissalActionStore()
        
        addChild(coordinator)
        coordinator.start()
        self.rootView = coordinator.rootView
        
        completionHandler(onPresent)
    }
    
    /// Dismiss the current coordinator, making sure that it's not the root coordinator because the root is the basis of the entire view hierarchy, it can't be dismissed
    public func dismiss(coordinator: any Coordinator,
                        onDismiss: (() -> Void)? = nil) {
        guard self.parent !== coordinator.parent
        else { return }
        
        // Note: Data is persisted when the root view is set back to its original route
        self.rootView = AnyView(self.view(for: rootRoute))
        removeChild(coordinator)
        
        completionHandler(onDismiss)
    }
    
    /// Check to see if the given coordinator is an active child of this coordinator
    public func doesChildExist(_ child: any Coordinator) -> Bool {
        return children.contains(where: { $0 === child })
    }
    
    public func getChild(for coordinator: any Coordinator) -> (any Coordinator)? {
        return children.first {
            $0 === coordinator
        }
    }
    
    public func getChild(at index: Int) -> (any Coordinator)? {
        return children[index]
    }
    
    public func addChild(_ child: any Coordinator) {
        guard !doesChildExist(child)
        else { return }
        
        children.append(child)
    }
    
    /// Remove child from children by testing to see if the given child exists in the array at the same point in memory as an identical child
    private func removeChild(_ child: any Coordinator) {
        guard let index = children.firstIndex(where: {
            $0 === child
        }) else {
            return
        }
        
        children.remove(at: index)
    }
    
    private func removeLastChild() {
        children.removeLast()
    }
    
    private func removeAllChildren() {
        children.removeAll()
    }
}

// MARK: - Modal + Navigation Stack presentation
extension Coordinator {
    /// Pushes a new view onto the navigation stack with the given route
    func pushView(with route: Router.Route,
                  onPresent: (() -> Void)? = nil) {
        addPath(with: route)
        completionHandler(onPresent)
    }
    
    /// Pops the topmost view off of the navigation stack
    func popView(onDismiss: (() -> Void)? = nil) {
        removeLastPathValue()
        completionHandler(onDismiss)
    }
    
    /// Pops the specified view off of the navigation stack
    func popView(with route: Router.Route,
                 onDismiss: (() -> Void)? = nil) {
        removePath(with: route)
        completionHandler(onDismiss)
    }
    
    /// Goes back to the root view in the navigation stack
    func popToRootView(onDismiss: (() -> Void)? = nil) {
        navigationPath.removeAll()
        completionHandler(onDismiss)
    }
    
    /// Pops to a specific view in the view hierarchy by dismissing all the views on top of it, cannot pop to the root view because the root is not a path in the navigation path
    func popToView(with route: Router.Route,
                   onDismiss: (() -> Void)? = nil) {
        guard navigationPath.count > 0 else { return }
        
        for value in navigationPath.reversed() {
            if value != route {
                popView(with: value)
            }
        }
        
        assert(navigationPath.count != 0)
        completionHandler(onDismiss)
    }
    
    /** Pops the current view and presents the given view asynchronously afterwards*/
    func popAndPush(to route: Router.Route,
                    onDismiss: (() -> Void)? = nil,
                    onPresent: (() -> Void)? = nil,
                    withDelay: Bool = true) {
        guard navigationPath.count > 0 else { return }
        
        // Note: 0.55 [s] is the min duration that allows the push to occur
        let delay: CGFloat = 0.55
        
        popView(onDismiss: onDismiss)
        
        if withDelay {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self
                else { return }
                
                self.pushView(with: route, onPresent: onPresent)
            }
        }
        else {
            pushView(with: route, onPresent: onPresent)
        }
    }
    
    // MARK: - Fullscreen cover presentation
    func presentFullScreenCover(with route: Router.Route,
                                onPresent: (() -> Void)? = nil,
                                onDismiss: (() -> Void)? = nil) {
        clearDismissalActionStore()
        deferredDismissalActionStore[route] = onDismiss
        
        fullCoverItem = route
        completionHandler(onPresent)
    }
    func dismissFullScreenCover(onDismiss: (() -> Void)? = nil) {
        fullCoverItem = nil
        completionHandler(onDismiss)
    }
    
    // MARK: - Sheet presentation
    func presentSheet(with route: Router.Route,
                      onPresent: (() -> Void)? = nil,
                      onDismiss: (() -> Void)? = nil) {
        clearDismissalActionStore()
        deferredDismissalActionStore[route] = onDismiss
        
        sheetItem = route
        completionHandler(onPresent)
    }
    func dismissSheet(onDismiss: (() -> Void)? = nil) {
        deferredCompletionHandler(for: sheetItem)
        
        sheetItem = nil
        completionHandler(onDismiss)
    }
    
    /// Unwraps a stored dismissal action, executes it, and removes it from the dismissal action store
    private func deferredCompletionHandler(for item: Router.Route?) {
        guard let item = item,
              let deferredDismissAction = deferredDismissalActionStore[item]
        else { return }
        
        completionHandler(deferredDismissAction)
        deferredDismissalActionStore.removeValue(forKey: item)
    }
    
    private func clearDismissalActionStore() {
        deferredDismissalActionStore.removeAll()
    }
    
    private func completionHandler(_ closure: (() -> Void)?) {
        closure?()
    }
    
    // MARK: - Navigation path management
    private func addPath(with route: Router.Route) {
        navigationPath.append(route)
    }
    
    /// Removes the first path in the navigation path
    private func removeFirstPathValue() {
        navigationPath.removeFirst()
    }
    
    /// Removes the last path in the navigation path
    private func removeLastPathValue() {
        guard !navigationPath.isEmpty else { return }
        
        navigationPath.removeLast()
    }
    
    /// Not to be used by itself, this doesn't align with the FIFO behavior associated with the navigation path object
    private func removePath(with route: Router.Route) {
        navigationPath.removeAll { containedRoute in
            containedRoute == route
        }
    }
    
    /// Removes all paths from the navigation stack
    private func removeAllPaths() {
        navigationPath.removeAll()
    }
}

protocol RootCoordinator: Coordinator {
    var rootCoordinatorDelegate: RootCoordinatorDelegate { get set }
    
    func navigateTo(targetRoute: Router.Route)
    
    @ViewBuilder
    func coordinatorView() -> AnyView // A view that displays the coordinator's rootView, responsible for reflecting changes in the rootview hierarchy
    
    func coordinatedView() -> any CoordinatedView // View to be used to access the specific properties of each coordinator view
}

extension RootCoordinator {
    func navigateTo(targetRoute: Router.Route) {
        let path = router.getPath(to: targetRoute)
        
        guard let currentRouteIndex = path.firstIndex(of: currentRoute),
              let targetRouteIndex = path.firstIndex(of: targetRoute)
        else {
            if targetRoute == rootRoute {
                popToRootView()
            }
            
            ErrorCodeDispatcher.DeeplinkingErrors
                .printErrorCode(for: .routeUnreachableFromCurrentRoute)
            
            // The target route is unreachable from the current route
            return
        }
        
        let isRouteBeforeCurrentRoute = currentRouteIndex >= targetRouteIndex
        
        if isRouteBeforeCurrentRoute {
            // Traverse Backwards in the navigation stack
            popToView(with: targetRoute)
        }
        else {
            // Traverse Forwards in the navigation stack
            // Remove the routes already traversed, aka the ones at and before the current route, only the routes after the current route need to be added to the view hierarchy
            let pathToTraverse = path.enumerated().filter { (index, route) in
                index > currentRouteIndex
            }
            
            for route in pathToTraverse {
                self.pushView(with: route.element)
            }
        }
    }
}

protocol TabbarCoordinator: RootCoordinator {
    /// Returns the coordinator for the specified tabbar tab route, should be contained in the children store, if not then it will be instantiated and added to the children store
    func getCoordinatorFor(route: TabbarRoutes) -> any Coordinator
}

extension TabbarCoordinator {
//    func getCoordinatorFor(route: TabbarRoutes) -> any Coordinator {
//        var coordinator: any Coordinator
//        
//        switch route {
//        case .builds:
//            coordinator = dispatcher.buildsCoordinator
//        case .components:
//            coordinator = dispatcher.componentsCoordinator
//        case .command_center:
//            coordinator = dispatcher.commandCenterCoordinator
//        case .explore:
//            coordinator = dispatcher.exploreCoordinator
//        case .inbox:
//            coordinator = dispatcher.inboxCoordinator
//        }
//        
//        return coordinator
//    }
    
    /// The tabbar has specific children it manages, these children are never discarded throughout the tabbar's lifecycle so they're constant
//    func populateChildren() {
//        for route in MainRouter.Route.allCases {
//            let child = getCoordinatorFor(route: route)
//            addChild(child)
//        }
//    }
}
