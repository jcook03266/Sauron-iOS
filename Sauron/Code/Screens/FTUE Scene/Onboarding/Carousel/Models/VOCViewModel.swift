//
//  VOCViewModel.swift
//  Inspec
//
//  Created by Justin Cook on 11/5/22.
//

import SwiftUI

// MARK: - Main Carousel
class VOCViewModel: NavigableGenericViewModel {
    let id: UUID = UUID()
    typealias coordinator = OnboardingCoordinator
    
    // MARK: - Observed
    var coordinator: OnboardingCoordinator
    /// Note: The progress bar is the source of truth for the current page and overall progress of the carousel
    @ObservedObject var progressBar: PartitionedProgressBarViewModel = .init()
    @ObservedObject private var observedArray: ObservableArray = ObservableArray<VOCPageViewModel>()
    
    // MARK: - Published
    /// The current page of the onboarding carousel which corresponds to the positioning of the progress bar
    @Published var currentPage: Int = 0
    
    var pages: [VOCPageViewModel] {
        get {
            return observedArray.array
        }
        set {
            observedArray.array = newValue
        }
    }
    var pageDispatcher: OnboardingPages {
        return .init(pageManager: self)
    }
    var pageCount: Int {
        return pages.count
    }
    var isOnFirstPage: Bool {
        return progressBar.currentPage == 1
    }
    var isOnLastPage: Bool {
        return progressBar.currentPage == pages.count
    }
    
    // MARK: - Dependencies
    struct Dependencies: InjectableServices {
        var ftueService: FTUEService = inject()
    }
    internal var dependencies = Dependencies()
    
    // MARK: - Actions
    var goToHomeScreen: (() -> Void) {
        return {
            self.dependencies.ftueService.completeOnboardingFTUE()
            
            self.coordinator.pushView(with: .home)
        }
    }
    
    init(coordinator: OnboardingCoordinator)
    {
        // Initializing variables
        self.coordinator = coordinator
        
        // Setting expected values
        self.pages = pageDispatcher.getAllPages()
        self.progressBar = PartitionedProgressBarViewModel(progressBarCount: pageCount)
        self.currentPage = pages.count >= 1 ? 1 : 0
        self.observedArray = ObservableArray(array: pages,
                                             parentObjectWillChange: self.objectWillChange)
        
        setPageProperties()
    }
    
    // MARK: - Setting properties
    private func setPageProperties() {
        for page in pages {
            page.manager = self
        }
        
        observedArray.observeChildren()
    }
    
    func getProgressBarFor(pageID: Int) -> ProgressBarModel{
        if let targetProgressBar = progressBar.getProgressBarModel(for: pageID) {
            return targetProgressBar
        }
        else {
            preconditionFailure("The given page ID: \(pageID) does not have an assigned progress bar, \(#function)")
        }
    }
    
    /// Note: Adding or removing a page resets the carousel and the progress bar
    func addPages(pages: [VOCPageViewModel]) {
        for page in pages {
            guard !doesContainPage(page), isValidPageNumber(pageNumber: page.pageNumber) else { return }
            
            self.pages.append(page)
        }
        
        progressBar.updateModels(using: pages.count)
        currentPage = 1
        
        setPageProperties()
    }
    
    func addPage(page: VOCPageViewModel) {
        guard !doesContainPage(page), isValidPageNumber(pageNumber: page.pageNumber) else { return }
        
        pages.append(page)
        
        progressBar.updateModels(using: pages.count)
        currentPage = 1
        
        setPageProperties()
    }
    
    func removePages(pages: [VOCPageViewModel]) {
        for page in pages {
            guard doesContainPage(page), isPageWithinBounds(page: page) else { return }
            
            self.pages.removeAll(where: {
                $0 === page
            })
        }
        
        progressBar.updateModels(using: pages.count)
        currentPage = pages.count >= 1 ? 1 : 0
        
        setPageProperties()
    }
    
    func removePage(page: VOCPageViewModel) {
        guard doesContainPage(page), isPageWithinBounds(page: page) else { return }
        
        pages.removeAll(where: {
            $0 === page
        })
        
        progressBar.updateModels(using: pages.count)
        currentPage = pages.count >= 1 ? 1 : 0
        
        setPageProperties()
    }
    
    // MARK: - State control and boundary conditions
    func updateCurrentPage(with pageNumber: Int) {
        guard pageNumber <= pageCount && pageNumber >= 1 else { return }
        
        currentPage = pageNumber
    }
    
    private func doesContainPage(_ page: VOCPageViewModel) -> Bool {
        return pages.contains(where: {
            $0 === page
        })
    }
    
    private func isPageNumberWithinBounds(pageNumber: Int) -> Bool {
        return pageNumber >= 1 && pageNumber <= pageCount
    }
    
    private func isPageWithinBounds(page: VOCPageViewModel) -> Bool {
        return isPageNumberWithinBounds(pageNumber: page.pageNumber)
    }
    
    // The pages must have sequential numbers, so this ensures that the next page follows the previous page's number sequentially
    private func isValidPageNumber(pageNumber: Int) -> Bool {
        return pageNumber >= 1 && pageNumber <= pageCount + 1
    }
    
    // MARK: - Navigation
    func moveForward() {
        updateCurrentPage(with: currentPage + 1)
    }
    
    func moveBackward() {
        updateCurrentPage(with: currentPage - 1)
    }
    
    func skipToFirst() {
        updateCurrentPage(with: 1)
    }
    
    func skipToLast() {
        updateCurrentPage(with: pageCount)
    }
}
