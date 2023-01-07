////
////  TabbarTabs.swift
////  Inspec
////
////  Created by Justin Cook on 10/29/22.
////
//
//import Foundation
//import SwiftUI
//
//// MARK: - Dispatcher
///// Structure that dispatches preconfigured tabbar views to be installed into a tabbar body view
//struct TabbarTabDispatcher {
//    @ObservedObject var coordinator: MainCoordinator
//    
//    /// Returns the tab button view for this tab
//    func getTabViewFor(tab: TabbarRoutes) -> some View {
//        return ZStack {
//            switch tab {
//            case .builds:
//                buildsTab
//            case .components:
//                componentsTab
//            case .command_center:
//                commandCenterTab
//            case .explore:
//                exploreTab
//            case .inbox:
//                inboxTab
//            }
//        }
//    }
//    
//    var buildsTab: TabbarTabButtonView {
//        let tab = Tab(title: LocalizedStrings.getLocalizedStringKey(for: .TABBAR_BUTTON_BUILDS),
//                      image: Icons.getIconImage(named: .circle_hexagongrid_fill),
//                      id: 0,
//                      assignedTab: .builds,
//                      coordinator: coordinator)
//        
//        return TabbarTabButtonView(tab: tab)
//    }
//    var componentsTab: TabbarTabButtonView {
//        let tab = Tab(title: LocalizedStrings.getLocalizedStringKey(for: .TABBAR_BUTTON_COMPONENTS),
//                      image: Icons.getIconImage(named: .rectangle_3_group_fill),
//                      id: 1,
//                      assignedTab: .components,
//                      coordinator: coordinator)
//        
//        return TabbarTabButtonView(tab: tab)
//    }
//    var commandCenterTab: TabbarCenterTabButtonView {
//        let tab = Tab(title: LocalizedStrings.getLocalizedStringKey(for: .TABBAR_BUTTON_COMMAND_CENTER),
//                      image: nil,
//                      id: 2,
//                      assignedTab: .command_center,
//                      coordinator: coordinator)
//        
//        return TabbarCenterTabButtonView(tab: tab)
//    }
//    var exploreTab: TabbarTabButtonView {
//        let tab = Tab(title: LocalizedStrings.getLocalizedStringKey(for: .TABBAR_BUTTON_EXPLORE),
//                      image: Icons.getIconImage(named: .point_3_filled_connected_trianglepath_dotted),
//                      id: 3,
//                      assignedTab: .explore,
//                      coordinator: coordinator)
//        
//        return TabbarTabButtonView(tab: tab)
//    }
//    var inboxTab: TabbarTabButtonView {
//        let tab = Tab(title: LocalizedStrings.getLocalizedStringKey(for: .TABBAR_BUTTON_INBOX),
//                      image: Icons.getIconImage(named: .chat),
//                      id: 4,
//                      assignedTab: .inbox,
//                      coordinator: coordinator)
//        
//        return TabbarTabButtonView(tab: tab)
//    }
//    
//    var allTabs: [any View] {
//        return [buildsTab,
//                componentsTab,
//                commandCenterTab,
//                exploreTab,
//                inboxTab]
//    }
//}
//
//// MARK: - View Model for tab views
//class Tab: Identifiable, Hashable, ObservableObject {
//    let title: LocalizedStringKey,
//        image: Image?,
//        id: Int,
//        assignedTab: TabbarRoutes
//    
//    @ObservedObject var coordinator: MainCoordinator
//    
//    init(title: LocalizedStringKey,
//         image: Image?,
//         id: Int,
//         assignedTab: TabbarRoutes,
//         coordinator: MainCoordinator) {
//        
//        self.title = title
//        self.image = image
//        self.id = id
//        self.assignedTab = assignedTab
//        self.coordinator = coordinator
//    }
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    
//    static func == (lhs: Tab, rhs: Tab) -> Bool {
//        let condition = lhs.title == rhs.title
//        && lhs.image == rhs.image
//        && lhs.id == rhs.id
//        && lhs.assignedTab == rhs.assignedTab
//        
//        return condition
//    }
//}
//
//// MARK: - Views
///// The button in the center of the tab bar
//struct TabbarCenterTabButtonView: View {
//    @StateObject var tab: Tab
//    
//    /// Shape Dimensions and colors to be displayed an animated around the center icon
//    let circleDiameter: CGFloat = 70,
//        image: Image = Images.Characters.getImage(named: .Ian_Portrait)
//    var gradient: LinearGradient = Colors.gradient_1,
//        solidColor: Color = Colors.primary_1.0,
//        circleLineWidth: CGFloat = 5,
//        shadowColor: Color = Colors.shadow_1.0
//    
//    var body: some View {
//        ZStack {
//            Circle()
//                .strokeBorder(
//                    gradient,
//                    lineWidth: circleLineWidth
//                )
//                .shadow(color: shadowColor,
//                        radius: 2,
//                        x: 0,
//                        y: -1)
//            
//            GeometryReader { geom in
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: geom.size.width * 0.9,
//                           height: geom.size.height * 0.9)
//                    .position(x: geom.size.width/2,
//                              y: geom.size.height/2)
//            }
//            
//        }
//        .frame(width: circleDiameter, height: circleDiameter)
//    }
//}
//
///// Other tab bar buttons
//struct TabbarTabButtonView: View {
//    @StateObject var tab: Tab
//    
//    let underlineBottomSpacing: CGFloat = 3,
//        shadowColor: Color = Colors.shadow_1.0
//    
//    var isActive: Bool {
//        return tab.coordinator.currentTab == tab.assignedTab
//    }
//    var notificationsPending: Bool {
//        return false
//    }
//    var textColor: Color {
//        return self.isActive ? Colors.primary_1.0 : Colors.black.0
//    }
//    var iconBubbleOffset: CGSize {
//        return CGSize(width: 0, height: -10)
//    }
//    var image: Image {
//        return tab.image ?? Image("")
//    }
//    
//    var iconBubble: some View {
//        VStack {
//            if notificationsPending && isActive {
//                notificationIndicator
//                    .offset(x: 10, y: -25)
//                    .zIndex(1)
//                    .transition(AnyTransition.push(from: .bottom).animation(.easeInOut(duration: 0.5)))
//            }
//            
//            if isActive {
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .background(
//                        Circle()
//                            .fill(Colors.primary_1.0)
//                            .frame(width: 40, height: 40)
//                    )
//                    .frame(width: 20, height: 20)
//                    .shadow(color: shadowColor,
//                            radius: 2,
//                            x: 0,
//                            y: 1)
//                    .foregroundColor(Colors.icon_white.0)
//                    .offset(iconBubbleOffset)
//                    .fixedSize()
//                    .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.2)))
//            }
//        }
//    }
//    var notificationIndicator: some View {
//        Circle()
//            .stroke(
//                Colors.gradient_2,
//                lineWidth: 1)
//            .background(
//                Circle()
//                    .fill(Colors.gradient_2))
//            .frame(width: 10, height: 10)
//            .shadow(color: shadowColor,
//                    radius: 2,
//                    x: 0,
//                    y: 4)
//    }
//    
//    var body: some View {
//        VStack {
//            Spacer()
//            
//            iconBubble
//            
//            Text(tab.title)
//                .foregroundColor(textColor)
//                .lineLimit(1)
//                .scaledToFill()
//                .minimumScaleFactor(0.5)
//        }
//    }
//}
//
//struct TabbarButtonUnderlineView: View {
//    var color: Color = Colors.getColor(named: .primary_1),
//        height: CGFloat = 3,
//        cornerRadius: CGFloat = 40
//    
//    var body: some View {
//        RoundedRectangle(cornerRadius: cornerRadius)
//            .fill(color)
//            .frame(height: height)
//    }
//}
