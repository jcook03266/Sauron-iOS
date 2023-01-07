//
//  TextOscillator.swift
//  Inspec
//
//  Created by Justin Cook on 11/21/22.
//

import SwiftUI

/// Object used to iterate through a set of strings indefinitely
class TextOscillator: ObservableObject {
    var initialValue: String
    var stringsToCycleThrough: [String] = []
    
    // MARK: - Published
    @Published var currentValue: String
    
    /// Converts the published string to a localized string key so that the subscriber can receive a string and or an LSK at the same time an update happens
    var currentValueAsLocalizedStringKey: LocalizedStringKey {
        return LocalizedStringKey(currentValue)
    }
    
    // MARK: - Time Interval tracking
    var timer: Timer? = nil
    var timeInterval: CGFloat = 2
    
    // MARK: - Iteration tracking
    var maxIndex: Int {
        return stringsToCycleThrough.count - 1
    }
    var minIndex: Int = 0 // Zero-indexed array
    var currentIndex: Int = 0
    var canIterate: Bool {
        // If there's no items in the given array then no oscillation can occur
        return maxIndex >= 0
    }
    // The amount of extra time spent on the last string before the iterator is reset
    var lastElementDelay: CGFloat = 1
    
    init(initialValue: String) {
        self.initialValue = initialValue
        self.currentValue = initialValue
    }
    
    /// Oscillates through the given string array indefinitely for the given interval
    func startOscillating() {
        guard canIterate else { return }
        
        reset()
        flushTimerRunLoops()
        
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] _ in
            guard let self = self
            else { return }
            
            if self.currentIndex <= self.maxIndex {
                self.currentValue = self.stringsToCycleThrough[self.currentIndex]
                self.currentIndex += 1
            }
            else {
                // Resets once the oscillator reaches the last element in the array
                if self.lastElementDelay != 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.lastElementDelay) {
                        self.reset()
                    }
                }
                else { self.reset() }
            }
        }
        timer?.fire()
    }
    
    // MARK: - Controls
    func pause() {
        flushTimerRunLoops()
    }
    
    func resume() {
        timer?.fire()
    }
    
    func stop() {
        flushTimerRunLoops()
        timer = nil
        reset()
    }
    
    // MARK: - State Management
    func reset() {
        currentIndex = minIndex
        currentValue = initialValue
    }
    
    func flushTimerRunLoops() {
        timer?.invalidate()
    }
}
