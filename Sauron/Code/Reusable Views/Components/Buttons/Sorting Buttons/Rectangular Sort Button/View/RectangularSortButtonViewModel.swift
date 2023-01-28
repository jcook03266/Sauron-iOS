//
//  RectangularSortButtonViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/28/23.
//

import SwiftUI

class RectangularSortButtonViewModel: GenericViewModel {
    // MARK: - Properties
    var sortIconType: ArrowType = .pointer
    
    // MARK: - Published
    @Published var sortOrderIsDescending: Bool = false
    
    // MARK: - Actions
    /// True = Descending Sort Order, False = Ascending Sort Order, Specify a closure that informs this button the final outcome of the implicitly connected sorting algorithm's order
    var userTriggeredDescendingSortOrderToggleAction: () -> Bool
    /// This is passed to the button to run both the user triggered action and other custom object specific logic
    var buttonSortActionPassthrough: (() -> Void) {
        return { [weak self] in
            guard let self = self
            else { return }
            
            HapticFeedbackDispatcher.genericButtonPress()
            
            self.sortOrderIsDescending = self.userTriggeredDescendingSortOrderToggleAction()
        }
    }
    
    // MARK: - Styling
    // Colors + Gradients
    let borderGradient: LinearGradient = Colors.gradient_6,
        backgroundColor: Color = Colors.permanent_black.0,
        fontColor: Color = Colors.permanent_white.0,
        iconGradient: LinearGradient = Colors.gradient_6,
        shadowColor: Color = Colors.shadow_1.0
    // Fonts
    let titleFont: FontRepository = .body_XS_Bold
    
    // MARK: - Assets
    let pointerArrowIconAscending: Image = Icons.getIconImage(named: .arrow_up),
        pointerArrowIconDescending: Image = Icons.getIconImage(named: .arrow_down),
triangularArrowIconAscending: Image = Icons.getIconImage(named: .arrow_up),
triangularArrowIconDescending: Image = Icons.getIconImage(named: .arrow_down)
    
    var currentArrowIcon: Image {
        switch sortIconType {
        case .pointer:
            return sortOrderIsDescending ? pointerArrowIconDescending : pointerArrowIconAscending
        case .triangle:
            return sortOrderIsDescending ? triangularArrowIconDescending : triangularArrowIconAscending
        }
    }
    
    // MARK: - Localized Text
    var title: String
    
    init(sortIconType: ArrowType,
         sortOrderIsDescending: Bool,
         userTriggeredDescendingSortOrderToggleAction: @autoclosure @escaping () -> Bool,
         title: String)
    {
        self.sortIconType = sortIconType
        self.sortOrderIsDescending = sortOrderIsDescending
        self.userTriggeredDescendingSortOrderToggleAction = userTriggeredDescendingSortOrderToggleAction
        self.title = title
    }
    
    // MARK: - Sort Icon Modularity
    enum ArrowType: String, CaseIterable {
        case pointer, triangle
    }
}
