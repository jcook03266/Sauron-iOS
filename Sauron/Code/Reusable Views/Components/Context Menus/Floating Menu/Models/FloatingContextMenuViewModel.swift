//
//  FloatingContextMenuViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/8/23.
//

import Foundation
import SwiftUI

class FloatingContextMenuViewModel: ObservableObject {
    // MARK: - Properties
    var rows: [FloatingContextMenuRow] = [],
        menuTitle: String,
        anchorPoint: CGPoint
    
    // MARK: - Published
    @Published var selectedRow: FloatingContextMenuRow? = nil
    @Published var didTapOutsideOfContentArea: Bool = false
    @Published var shouldDisplay: Bool = false
    @Published var sortInAscendingOrder: Bool = true
    
    // MARK: - Styling
    // Colors
    let menuBodyBackgroundColor: Color = Colors.white.0,
        menuBodyForegroundColor: Color = Colors.black.0,
        sideBarGradient: LinearGradient = Colors.gradient_1,
        menuTitleBackgroundColor: Color = Colors.secondary_2.0,
        menuTitleForegroundColor: Color = Colors.permanent_white.0,
        contextBackdropColor: Color = Colors.backdrop.0,
        shadowColor: Color = Colors.shadow_1.0
    
    // Fonts
    let menuTitleFont: FontRepository = .body_S,
menuTitleFontWeight: Font.Weight = .semibold
    
    // Assets
    var sortIcon: Image {
        return sortInAscendingOrder ? Icons.getIconImage(named: .arrowtriangle_up_fill) : Icons.getIconImage(named: .arrowtriangle_down_fill)
    }
    
    // MARK: - Actions
    func toggleSortingOrder() {
        HapticFeedbackDispatcher.genericButtonPress()
        sortInAscendingOrder.toggle()
    }
    
    func dismissOnTapOutside() {
        HapticFeedbackDispatcher.fullScreenCoverDismissed()
        shouldDisplay = false
    }
    
    init(rows: [FloatingContextMenuRow] = [],
         menuTitle: String = "",
         anchorPoint: CGPoint = .zero)
    {
        self.rows = rows
        self.menuTitle = menuTitle
        self.anchorPoint = anchorPoint
    }
    
    // MARK: - Convenience Methods
    func doesRowPrecedeSelectedRow(row: FloatingContextMenuRow) -> Bool {
        guard let oldRowIndex = rows.firstIndex(of: row),
                let newRowIndex = rows.firstIndex(where: { $0 == selectedRow
        })
        else { return false }
        
        return oldRowIndex <= newRowIndex
    }
 
    /// The rows to be housed within the scrollable context menu
    class FloatingContextMenuRow: GenericViewModel, Equatable {
        // MARK: - Publishers
        @Published var isSelected: Bool = false
        
        // MARK: - Properties
        let id: UUID = .init(),
            action: (() -> Void),
            label: String
        
        var sideBarIcon: Image? = nil
        
        // MARK: - Styling
        // Colors
        let backgroundColor: Color = Colors.neutral_100.0,
            foregroundColor: Color = Colors.black.0,
            iconForegroundColor: Color = Colors.permanent_white.0
        
        var shadowColor: Color {
            return isSelected ? Colors.shadow_1.0 : Color.clear
        }
        
        // Fonts
        let font: FontRepository = .body_XS
        var fontWeight: Font.Weight {
            return self.isSelected ? .regular : .light
        }
        
        // MARK: - Protocol Conformance
        static func == (lhs: FloatingContextMenuViewModel.FloatingContextMenuRow,
                        rhs: FloatingContextMenuViewModel.FloatingContextMenuRow) -> Bool
        {
            return lhs.id == rhs.id
        }
        
        init(action: @escaping () -> Void,
             label: String,
             sideBarIcon: Image? = nil,
             isSelected: Bool)
        {
            self.action = action
            self.label = label
            self.sideBarIcon = sideBarIcon
            self.isSelected = isSelected
        }
    }
    
}
