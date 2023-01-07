////
////  FloatingTabbar.swift
////  Inspec
////
////  Created by Justin Cook on 10/28/22.
////
//
//import SwiftUI
//
//struct FloatingTabbar: View {
//    @Namespace private var tabbarContainer
//
//    // MARK: - Observed
////    @ObservedObject var coordinator: MainCoordinator
//
//    // MARK: - States
//    @State private var animate: Bool = false
//
//    var cornerRadius: CGFloat = 40,
//        height: CGFloat = 40,
//        color: Color = Colors.white.0,
//        shadowColor: Color = Colors.shadow_1.0
//
//    let itemSpacing: CGFloat = 5
//
//    var tabButtons: some View {
//        ForEach(TabbarRoutes.allCases, id: \.rawValue) { tab in
//            if tab != .command_center {
//                VStack(alignment: .leading) {
//                    VStack(spacing: 9) {
//
//                        coordinator.tabbarDispatcher.getTabViewFor(tab: tab)
//                            .zIndex(0)
//                            .onTapGesture {
//                                withAnimation(.spring()) {
//                                    coordinator.navigateTo(tab: tab)
//
//                                    // Trigger animation
//                                    animate.toggle()
//
//                                    HapticFeedbackDispatcher.tabbarButtonPress()
//                                }
//                            }
//
//                        if coordinator.currentTab == tab && tab != .command_center {
//                            TabbarButtonUnderlineView()
//                                .zIndex(0)
//                                .matchedGeometryEffect(id: "underline", in: tabbarContainer)
//                                .animation(.easeInOut(duration: 0.2), value: animate)
//
//                            Spacer()
//                        }
//                    }
//                    .fixedSize()
//                }
//                .padding([.leading], tab == .inbox ? -10 : 0)
//                .frame(width: 60)
//                .fixedSize()
//            }
//            else {
//                coordinator.tabbarDispatcher.getTabViewFor(tab: tab)
//                        .zIndex(1)
//                        .frame(width: 70)
//                        .onTapGesture {
//                            withAnimation(.spring()) {
//                                coordinator.navigateTo(tab: tab)
//
//                                // Trigger animation
//                                animate.toggle()
//
//                                HapticFeedbackDispatcher.tabbarButtonPress()
//                            }
//                        }
//                        .padding([.leading], 5)
//                        .padding([.trailing], -5)
//                        .fixedSize()
//            }
//        }
//    }
//
//    var body: some View {
//        VStack {
//            Spacer()
//            HStack {
//                GeometryReader { geom in
//                    HStack(spacing: itemSpacing) {
//                        Spacer()
//
//                        tabButtons
//
//                        Spacer()
//                    }
//                    .background(RoundedRectangle(cornerRadius: cornerRadius)
//                        .foregroundColor(color)
//                        .frame(width: geom.size.width * 0.95, height: height, alignment: .center)
//                        .shadow(color: shadowColor,
//                                radius: 2,
//                                x: 0,
//                                y: 2))
//                    .frame(width: geom.size.width, height: height, alignment: .center)
//                }
//            }
//            .offset(y: -20)
//            .frame(height: height)
//            .withFont(.body_3XS)
//        }
//    }
//}
//
//struct FloatingTabbar_Previews: PreviewProvider {
//    static var previews: some View {
//        FloatingTabbar(coordinator: MainCoordinator())
//    }
//}
