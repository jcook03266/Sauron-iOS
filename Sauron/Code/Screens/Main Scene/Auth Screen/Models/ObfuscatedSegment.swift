//
//  ObfuscatedSegment.swift
//  Sauron
//
//  Created by Justin Cook on 1/17/23.
//

import SwiftUI

class ObfuscatedPasscodeSegmentViewModel: GenericViewModel {
    // MARK: - Published
    @Published var isActive: Bool = false
    
    // MARK: - Properties
    /// The required length of the text entry at which this segment will activate
    let correspondingTextLength: Int
    
    // MARK: - Styling
    // Colors
    let activeFillGradient: LinearGradient = Colors.gradient_1,
        inactiveFillColor: Color = Colors.neutral_200.0
    
    init(isActive: Bool = false, correspondingTextLength: Int) {
        self.isActive = isActive
        self.correspondingTextLength = correspondingTextLength
    }
    
    /// Toggles the active state given some string input
    func toggleWith(text: String) {
        let length = text.count
        
        isActive = length >= correspondingTextLength
    }
}
