//
//  BottomSheetDispatcher.swift
//  Sauron
//
//  Created by Justin Cook on 1/8/23.
//

import Foundation

/// Object responsible for instantiating and providing the data models for reusable bottom sheets
/// This removes the need to repeat complex model definitions across different coordinators and routers
struct BottomSheetDispatcher {
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        let fiatCurrencyManager: FiatCurrencyManager = inject()
    }
    static let dependencies = Dependencies()
    
    static func getCurrencyPreferenceModel<T: Coordinator>(using coordinator: T) -> PreferenceBottomSheetViewModel<T> {
        var selectionChips: [PreferenceBottomSheetViewModel<T>.PreferenceBottomSheetSelectionChipViewModel] = []
        
        for currency in FiatCurrencyManager.SupportedFiatCurrencies.allCases {
            let label = "\(dependencies.fiatCurrencyManager.getCountryCode(for: currency, uppercased: true)) | \(currency.getSymbol().rawValue)"
            
            let action = { dependencies.fiatCurrencyManager.changePreferredCurrency(to: currency) }
            let isSelected = dependencies.fiatCurrencyManager.isCurrentCurrency(currency: currency)
            
            let selectionChip: PreferenceBottomSheetViewModel<T>.PreferenceBottomSheetSelectionChipViewModel = .init(isSelected: isSelected,
                                                                                                                     action: action,
                                                                                                                     label: label)
            selectionChips.append(selectionChip)
        }
        
        let model = PreferenceBottomSheetViewModel(coordinator: coordinator,
                                                   selectionChips: selectionChips,
                                                   defaultChip: selectionChips.first!,
                                                   searchBarPlaceholder: LocalizedStrings.getLocalizedString(for: .BOTTOM_SHEET_SEARCHBAR_PLACEHOLDER_CURRENCY_PREFERENCE))
        model.title = LocalizedStrings.getLocalizedString(for: .BOTTOM_SHEET_TITLE_CURRENCY_PREFERENCE_NEWLINE)
        model.optionalAdvisoryText = LocalizedStrings.getLocalizedString(for: .BOTTOM_SHEET_ADVISORY_CURRENCY_PREFERENCE)
        model.previewContent = { return dependencies.fiatCurrencyManager.getSampleFormattedNumber() }
        
        return model
    }
}
