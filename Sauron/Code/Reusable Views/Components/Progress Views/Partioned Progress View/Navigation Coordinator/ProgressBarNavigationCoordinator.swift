//
//  ProgressBarNavigationCoordinator.swift
//  Inspec
//
//  Created by Justin Cook on 11/12/22.
//

import SwiftUI

/// Coordinates in-view navigation between a progress bar and the view it’s embedded in, essentially a middle man that makes sure both objects are on the same page
class ProgressBarNavigationCoordinator<ViewModel>: ObservableObject, GenericNavigationProtocol where ViewModel: NavigableGenericViewModel{
    // Observed
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var progressBar: PartitionedProgressBarViewModel
    
    // States
    @State var enabled: Bool = true
    
    // Published
    @Published var currentPage: Int // 1-indexed

    init(viewModel: any ObservableObject,
         progressBar: PartitionedProgressBarViewModel,
         currentPage: Int = 0) {
        
        guard let viewModel = viewModel as? ViewModel
        else {
            preconditionFailure("Error: Could not cast viewModel to type ViewModel.type, make sure the model being passed conforms to protocol GenericViewModel, Function: \(#function)")
        }
        
        self.viewModel = viewModel
        self.progressBar = progressBar
        self.currentPage = currentPage
    }
    
    func injectProgressViewOnTapActions() {
        progressBar.onProgressBarTapForwardAction = { [weak self] in
            guard let self = self else { return }
            
            self.moveForward()
        }
        progressBar.onProgressBarTapBackwardAction = { [weak self] in
            guard let self = self else { return }
            
            self.moveBackward()
        }
    }
    
    // MARK: - Navigation
    func moveForward() {
        viewModel.moveForward()
        progressBar.moveForward()
        
        currentPage = progressBar.currentPage
    }
    
    func moveBackward() {
        viewModel.moveBackward()
        progressBar.moveBackward()
        
        currentPage = progressBar.currentPage
    }
    
    func skipToFirst() {
        viewModel.skipToFirst()
        progressBar.skipToFirst()
        
        currentPage = progressBar.currentPage
    }
    
    func skipToLast() {
        viewModel.skipToLast()
        progressBar.skipToLast()
        
        currentPage = progressBar.currentPage
    }
}
