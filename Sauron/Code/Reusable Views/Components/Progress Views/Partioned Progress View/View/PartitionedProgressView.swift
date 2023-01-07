//
//  PartitionedProgressView.swift
//  Inspec
//
//  Created by Justin Cook on 11/5/22.
//

import SwiftUI

/// Collection of separated progress bars that fill in sequentially to form one progress bar
struct PartitionedProgressView: View {
    @ObservedObject var viewModel: PartitionedProgressBarViewModel
    
    var progressBarFillColor: Color = Colors.primary_1.0,
        progressBarBackgroundColor: Color = Colors.neutral_300.0,
        barHeight: CGFloat = 100,
        barWidth: CGFloat = 10,
        barCornerRadius: CGFloat = 20,
        barSpacing: CGFloat = 8,
        orientation: PartitionedProgressViewOrientation = .vertical
    
    var shouldJoin: Bool {
        return viewModel.joinProgressBarViews && viewModel.isComplete
    }
    
    let jointBarSpacing: CGFloat = -8
    
    var body: some View {
        switch orientation {
        case .vertical:
            VStack(spacing: shouldJoin ?
                   jointBarSpacing : barSpacing) {
                Spacer()
                ForEach(viewModel.progressBarModels, id: \.id) { model in
                    ProgressBar(viewModel: model,
                                manager: viewModel,
                                fillColor: progressBarFillColor,
                                backgroundColor: progressBarBackgroundColor,
                                width: barWidth,
                                height: barHeight,
                                cornerRadius: barCornerRadius,
                                orientation: orientation)
                }
                Spacer()
            }
            .animation(.spring(), value: viewModel.currentProgress)
            .fixedSize()
        case .horizontal:
            //Height becomes width, and width becomes height
            HStack(spacing: shouldJoin ?
                   jointBarSpacing : barSpacing) {
                Spacer()
                ForEach(viewModel.progressBarModels, id: \.id) { model in
                    ProgressBar(viewModel: model,
                                manager: viewModel,
                                fillColor: progressBarFillColor,
                                backgroundColor: progressBarBackgroundColor,
                                width: barHeight,
                                height: barWidth,
                                cornerRadius: barCornerRadius,
                                orientation: orientation)
                }
                Spacer()
            }
            .animation(.spring(), value: viewModel.currentProgress)
            .fixedSize()
        }
    }
}

enum PartitionedProgressViewOrientation: String, CaseIterable {
    case vertical,
    horizontal
}

/// Rounded rectangle that acts as a progress bar
private struct ProgressBar: View {
    @ObservedObject var viewModel: ProgressBarModel
    @ObservedObject var manager: PartitionedProgressBarViewModel
    
    var fillColor: Color = Colors.primary_1.0,
        backgroundColor: Color = Colors.neutral_300.0,
        width: CGFloat = 10,
        height: CGFloat = 100,
        cornerRadius: CGFloat = 20,
        orientation: PartitionedProgressViewOrientation,
        springAnimationResponse: CGFloat = 1.5
    
    var body: some View {
        ZStack(alignment: orientation == .horizontal ? .leading : .top) {
            RoundedRectangle(cornerRadius: cornerRadius,
                             style: .continuous)
            .fill(backgroundColor)
            
            RoundedRectangle(cornerRadius: cornerRadius,
                             style: .continuous)
            .fill(fillColor)
            .frame(width: orientation == .horizontal ? width * viewModel.currentProgress : width,
                   height: orientation == .vertical ? height * viewModel.currentProgress : height)
        }
        .onTapGesture {
            // If the progress bar is incomplete move forwards if complete move backwards
            if !viewModel.isComplete.wrappedValue {
                manager.onProgressBarTapForwardAction?()
            }
            else {
                manager.onProgressBarTapBackwardAction?()
            }
        }
        .frame(width: width,
               height: height)
        .animation(.spring(response: springAnimationResponse),
                   value: viewModel.currentProgress)
    }
}

struct PartitionedProgressView_Previews: PreviewProvider {
    static var model: PartitionedProgressBarViewModel {
        let vm = PartitionedProgressBarViewModel(progressBarCount: 4)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            vm.moveForward()
        }
        
        return vm
    }
    
    static var previews: some View {
        PartitionedProgressView(viewModel: model)
            .previewDisplayName("Partitioned Progress View")
            .previewLayout(.sizeThatFits)
            .padding(.all, 50)
    }
}
