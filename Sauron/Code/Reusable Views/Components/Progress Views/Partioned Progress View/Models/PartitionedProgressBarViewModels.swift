//
//  PartitionedProgressBarViewModels.swift
//  Inspec
//
//  Created by Justin Cook on 11/5/22.
//

import SwiftUI
import Combine

// MARK: - Partitioned Progress Bar View Model
class PartitionedProgressBarViewModel: UncoordinatedNavigableGenericViewModel {
    // Observed
    /// Observes changes in the published array in this observable object and notifies the publisher of changes
    @ObservedObject private var observedArray: ObservableArray = ObservableArray<ProgressBarModel>()
    var progressBarModels: [ProgressBarModel] {
        get {
            return observedArray.array
        }
        set {
            observedArray.array = newValue
        }
    }
    
    // Published
    /// Corresponding 'page' the progress bar is on, used when embedded in a view with paging capabilities
    @Published var currentPage: Int = 0 // 1-indexed
    /// Joins all bars together to form one single bar when all bars are completed
    @Published var joinProgressBarViews: Bool = true
    
    let id: UUID = UUID(),
        maxProgress: CGFloat = 1,
        minProgress: CGFloat = 0
    
    var progressBarCount: Int,
        firstPageExclusive: Bool = true
    
    /// Closures triggered when an individual progress bar is tapped, a forward or backward action is triggered if the bar is currently complete or incomplete respectively
    var onProgressBarTapForwardAction: (() -> Void)? = nil,
        onProgressBarTapBackwardAction: (() -> Void)? = nil

    /// Decides whether or not the first page is marked as complete when the progress bar is first created, true by default
    var completeFirstPage: Bool {
        get {
            return true
        }
        set {
            progressBarModels.first?.isComplete.wrappedValue = newValue
        }
    }
    
    /// Total progress of the partitioned system from 0.0 to 1.0
    var currentProgress: CGFloat {
        var totalProgress: CGFloat = 0
        
        for progressBar in progressBarModels {
            totalProgress += progressBar.currentProgress
        }
        
        let systemProgress = totalProgress / CGFloat(progressBarModels.count)
        
        assert(systemProgress <= maxProgress
               && systemProgress >= minProgress)
        
        return systemProgress
    }
    
    var isComplete: Bool {
        return currentProgress == maxProgress
    }
    
    /// Returns the current incomplete progress bar or the last completed progress bar in the collection, or nothing if the collection is empty
    var currentProgressBarModel: ProgressBarModel? {
        return progressBarModels.last(where: {
            $0.isComplete.wrappedValue == true
        }) ?? progressBarModels.first(where: {
            $0.isComplete.wrappedValue == false
        })
    }
    
    init(progressBarCount: Int = 0,
         currentProgress: CGFloat = 0) {
        self.progressBarCount = progressBarCount
        self.observedArray = ObservableArray(array: progressBarModels,
                                             parentObjectWillChange: self.objectWillChange)
        
        populateModels()
        observedArray.observeChildren()
        setCurrentPage()
    }
    
    // MARK: - Getters and setters for progress bar models
    private func populateModels() {
        var currID: Int = 0
        progressBarModels = []
        
        for _ in 0..<progressBarCount {
            let model = ProgressBarModel(id: currID,
                                         currentProgress: 0)
            
            if currID == 0 {
                model.isComplete.wrappedValue = completeFirstPage
            }
            else {
                model.isComplete.wrappedValue = false
            }
            
            currID += 1
            progressBarModels.append(model)
        }
    }
    
    // Resets the model array with new progress incomplete bars of the specified count
    func updateModels(using progressBarCount: Int) {
        self.progressBarCount = progressBarCount
        
        populateModels()
    }
    
    func getProgressBarModel(for id: Int) -> ProgressBarModel? {
        return progressBarModels.first(where: {
            $0.id == id
        })
    }
    
    func getProgressBarModel(at index: Int) -> ProgressBarModel? {
        guard index < progressBarModels.count else { return nil }
        
        return progressBarModels[index]
    }
    
    // Returns the next progress bar that needs to be completed, nil if all are complete
    private func nextProgressBarModel() -> ProgressBarModel? {
        return progressBarModels.first(where: {
            $0.isComplete.wrappedValue == false
        })
    }
    
    // Returns the last progress bar that was completed, nil if none are complete
    private func lastProgressBarModel() -> ProgressBarModel? {
        return progressBarModels.last(where: {
            $0.isComplete.wrappedValue == true
        })
    }
    
    // MARK: - State control of the system's progress bars
    // Completes progress bars forwards up until the specified ID (inclusive)
    func complete(upto progressBarID: Int) {
        guard progressBarModels.contains(where: {
            $0.id == progressBarID
        }) else { return }
        
        for model in progressBarModels {
            if model.id > progressBarID { return }
            else {
                model.complete()
            }
        }
        
        setCurrentPage()
    }
    
    // Sets all progress bars to 1.0 (100%)
    func complete() {
        for model in progressBarModels {
            model.complete()
        }
        
        setCurrentPage()
    }
    
    // Resets progress bars backwards up until the specified ID (inclusive)
    func reset(upto progressBarID: Int) {
        guard progressBarModels.contains(where: {
            $0.id == progressBarID
        }) else { return }
        
        for model in progressBarModels {
            if model.id >= progressBarID {
                model.reset()
            }
        }
        
        setCurrentPage()
    }
    
    // Sets all progress bars to 0.0 (0%)
    func reset() {
        for model in progressBarModels {
            model.reset()
        }
        
        setCurrentPage()
    }
    
    func setCurrentPage() {
        guard progressBarCount != 0,
              let currentProgressBarModel = self.currentProgressBarModel
        else {
            currentPage = 0
            return 
        }
        
        currentPage = currentProgressBarModel.id + 1
    }
    
    // MARK: - Navigation
    func moveForward() {
        guard !isComplete,
        let next = nextProgressBarModel()
        else { return }
        
        next.complete()
        setCurrentPage()
    }
    
    func moveBackward() {
        guard let lastBarID = lastProgressBarModel()?.id, !(firstPageExclusive && lastBarID == 0)
        else { return }
        
        reset(upto: lastBarID)
    }
    
    func skipToFirst() {
        self.reset(upto: firstPageExclusive ? 1 : 0)
    }
    
    func skipToLast() {
        guard !isComplete else { return }
        
        self.complete(upto: self.progressBarCount - 1)
    }
}

// MARK: - Generic Progress Bar Model, can be used by other progress bars for managing and tracking progress
class ProgressBarModel: ObservableObject, Identifiable {
    let id: Int,
        maxProgress: CGFloat = 1,
        minProgress: CGFloat = 0
    
    @Published var currentProgress: CGFloat
    
    // Determines if the progress bar is currently complete, also allows for setting which triggers the reset or complete functions which changes the current progress
    var isComplete: Binding<Bool> {
        Binding { [self] in
            return currentProgress == maxProgress
        } set: { [self] updatedBool in
            updatedBool ? complete() : reset()
        }
    }
    var progressRemaining: CGFloat {
        return maxProgress - currentProgress
    }
    var progressCompleted: CGFloat {
        return currentProgress
    }
    
    init(id: Int,
         currentProgress: CGFloat) {
        self.id = id
        self.currentProgress = currentProgress
    }
    
    // Sets progress to 100% aka 1.0
    func complete() {
        currentProgress = 1
    }
    // Resets progress to 0% aka 0.0
    func reset() {
        currentProgress = 0
    }
    
    // CGFloats from -1.0 to 0.0 to 1.0
    func updateProgress(by amount: CGFloat) {
        if (amount > maxProgress) || (currentProgress + amount >= maxProgress) {
            complete()
        }
        else if (currentProgress + amount <= minProgress) {
            reset()
        }
        else {
            currentProgress += amount
        }
    }
}
