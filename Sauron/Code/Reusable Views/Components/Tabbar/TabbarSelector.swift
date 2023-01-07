//
//  TabbarSelector.swift
//  Inspec
//
//  Created by Justin Cook on 11/4/22.
//

import SwiftUI
import UIKit

///// Selector that dispatches a custom preconfigured tabbar 
//struct TabbarSelector {
//    let coordinator: MainCoordinator
//    
//    private var floatingTabbar: FloatingTabbar {
//        return FloatingTabbar(coordinator: self.coordinator)
//    }
//    
//    init(coordinator: MainCoordinator) {
//        self.coordinator = coordinator
//    }
//    
//    private func getTabbar(for tabbar: Tabbars) -> some View {
//        switch tabbar {
//        case .FloatingTabbar:
//            return AnyView(self.floatingTabbar)
//        }
//    }
//    
//    func getTabbarFromUserPreference() -> some View {
//        return self.getTabbar(for: .FloatingTabbar)
//    }
//
//}
//
//enum Tabbars: String, CaseIterable {
//    case FloatingTabbar
//}
