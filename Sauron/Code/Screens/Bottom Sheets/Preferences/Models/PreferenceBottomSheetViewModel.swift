//
//  PreferenceBottomSheetViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/8/23.
//

import SwiftUI
import Combine

/// View model for the preferences bottom sheet which allows a user to customize their user preferences in an intuitive and responsive UX
class PreferenceBottomSheetViewModel<T: Coordinator>: CoordinatedGenericViewModel {
    typealias coordinator = T
    
    // MARK: - Observed
    @ObservedObject var coordinator: T
    
    // MARK: - Published
    @Published var previewContent: (() -> String) = { return LocalizedStrings.getLocalizedString(for: .BOTTOM_SHEET_PREVIEW_TEXT_LANGUAGE_PREFERENCE) }
    @Published var searchBarTextFieldModel: SatelliteTextFieldModel!
    @Published var currentlySelectedChip: PreferenceBottomSheetSelectionChipViewModel!
    
    // Selection Button Chips
    @Published var selectionChips: [PreferenceBottomSheetSelectionChipViewModel] = []
    @Published private var selectionChipsDataProvider: [PreferenceBottomSheetSelectionChipViewModel] = []
    
    // MARK: - Properties
    var defaultChip: PreferenceBottomSheetSelectionChipViewModel /// The default chip to fall back on in case no chips are selected for some reason
    
    // MARK: - Localized Text
    /// Default search bar copy
    var searchBarPlaceholder: String = LocalizedStrings.getLocalizedString(for: .SEARCH),
        title: String = "",
        optionalAdvisoryText: String = ""
    
    let dismissButtonTitle: String = LocalizedStrings.getLocalizedString(for: .DISMISS)
    
    // MARK: - Styling
    // Colors
    let previewTextBackgroundGradient: LinearGradient = Colors.gradient_1,
        previewTextForegroundColor: Color = Colors.permanent_white.0,
        titleForegroundColor: Color = Colors.black.0,
        informationSectionIndicatorGradient: LinearGradient = Colors.gradient_1,
        informationSectionForegroundColor: Color = Colors.neutral_600.0,
        dismissButtonBackgroundColor: Color = Colors.black.0,
        dismissButtonForegroundColor: Color = Colors.white.0,
        horizontalDividerGradient: LinearGradient = Colors.gradient_1,
        backgroundColor: Color = Colors.white.0,
        shadowColor: Color = Colors.shadow_1.0
    
    // Fonts
    let titleFont: FontRepository = .heading_3,
        titleFontWeight: Font.Weight = .medium,
        previewTextFont: FontRepository = .heading_4,
        previewTextFontWeight: Font.Weight = .semibold,
        informationSectionFont: FontRepository = .body_S,
        dismissButtonFont: FontRepository = .body_L_Bold
    
    // MARK: - Actions
    var dismissAction: (() -> Void) {
        return { [weak self] in
            guard let self = self else { return }
            
            self.coordinator.dismissSheet()
        }
    }
    
    // MARK: - Models
    private var builtSearchBarTextFieldModel: SatelliteTextFieldModel {
        let searchBarTextFieldModel: SatelliteTextFieldModel = .init()
        
        searchBarTextFieldModel.configurator { model in
            // Main properties
            model.title = "Search Bar"
            model.placeholderText = self.searchBarPlaceholder
            model.satelliteButtonInActiveIcon = Icons.getIconImage(named: .magnifyingglass)
            model.satelliteButtonActiveIcon = Icons.getIconImage(named: .xmark)
            model.satelliteButtonBackgroundColor = Colors.primary_2.0
            
            // Satellite button
            model.satelliteButtonAction = {
                model.focused.toggle()
                
                let shadowColor = model.focused ? Colors.shadow_2.0 : Colors.shadow_1.0
                model.satelliteButtonShadowColor = shadowColor
                model.shadowColor = shadowColor
            }
        }
        
        return searchBarTextFieldModel
    }
    
    // MARK: - Convenience
    var canDisplayAdvisory: Bool {
        return optionalAdvisoryText.isEmpty
    }
    
    init(coordinator: T,
         selectionChips: [PreferenceBottomSheetSelectionChipViewModel],
         defaultChip: PreferenceBottomSheetSelectionChipViewModel)
    {
        self.coordinator = coordinator
        self.selectionChips = selectionChips
        self.defaultChip = defaultChip
        self.searchBarTextFieldModel = builtSearchBarTextFieldModel
        self.selectionChipsDataProvider = selectionChips
        self.currentlySelectedChip = getSelectedChip()
        
        addSubscribers()
    }
    
    private func getSelectedChip() -> PreferenceBottomSheetSelectionChipViewModel {
        return selectionChips.first { $0.isSelected } ?? defaultChip
    }
    
    /// Filter the chips using the search bar's published text
    func addSubscribers() {
        searchBarTextFieldModel
            .$textEntry
            .combineLatest($selectionChipsDataProvider)
            .map(filterSelectionChips)
            .assign(to: &$selectionChips)
        
        $currentlySelectedChip
            .combineLatest($selectionChips)
            .map(moveSelectedChipToFront)
            .assign(to: &$selectionChips)
    }
    
    /// Shift the selected chip to the front to make it easier for the user to see their selection next time they want to change it
    private func moveSelectedChipToFront(selectedChip: PreferenceBottomSheetSelectionChipViewModel?,
                                         selectionChips: [PreferenceBottomSheetSelectionChipViewModel]) -> [PreferenceBottomSheetSelectionChipViewModel]
    {
        guard let selectedChip = selectedChip,
              let selectionIndex = self.selectionChips.firstIndex(of: selectedChip)
        else { return selectionChips }
        
        self.selectionChips.swapAt(0, selectionIndex)
        
        return self.selectionChips
    }
    
    /// Selection Button Filtering
    private func filterSelectionChips(using query: String,
                                      on unfilteredChips: [PreferenceBottomSheetSelectionChipViewModel]) -> [PreferenceBottomSheetSelectionChipViewModel]
    {
        guard !query.isEmpty else { return unfilteredChips }
        
        let lowercasedQuery = query.lowercased()
        
        let filteredChips = unfilteredChips.filter { (chip) -> Bool in
            let condition = chip.label.lowercased().contains(lowercasedQuery)
            
            return condition
        }
        
        return filteredChips
    }
    
    class PreferenceBottomSheetSelectionChipViewModel: GenericViewModel, Hashable, Equatable {
        // MARK: - Publishers
        @Published var isSelected: Bool = false
        
        // MARK: - Properties
        let id: UUID = .init(),
            action: (() -> Void),
            label: String
        
        // MARK: - Styling
        // Colors
        var backgroundColor: Color {
            return isSelected ? Colors.black.0 : Colors.neutral_300.0
        }
        var shadowColor: Color {
            return isSelected ? Colors.shadow_1.0 : .clear
        }
        let foregroundColor: Color = Colors.white.0
        
        // Fonts
        let font: FontRepository = .body_S,
            fontWeight: Font.Weight = .semibold
        
        // MARK: - Protocol Conformance
        static func == (lhs: PreferenceBottomSheetViewModel.PreferenceBottomSheetSelectionChipViewModel,
                        rhs: PreferenceBottomSheetViewModel.PreferenceBottomSheetSelectionChipViewModel) -> Bool
        {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(label)
        }
        
        init(isSelected: Bool,
             action: @escaping () -> Void,
             label: String)
        {
            self.isSelected = isSelected
            self.action = action
            self.label = label
        }
    }
}
