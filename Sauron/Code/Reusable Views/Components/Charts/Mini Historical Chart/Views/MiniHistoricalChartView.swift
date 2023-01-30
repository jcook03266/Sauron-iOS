//
//  MiniHistoricalChartView.swift
//  Sauron
//
//  Created by Justin Cook on 1/29/23.
//

import SwiftUI

struct MiniHistoricalChartView: View {
    // MARK: - Observed
    @ObservedObject var model: MiniHistoricalChartViewModel
    
    // MARK: - States
    @State private var drawPath: Bool = false
    
    // MARK: - Dimensions
    var lineWidth: CGFloat = 1,
        backgroundGraphlineWidth: CGFloat = 1,
        size: CGSize = .init(width: 300, height: 300),
        verticalPadding: CGFloat = 10
    
    // MARK: - Properties
    /// The amount of lines per axis
    var chartBackgroundLineDensity: Int = 5,
        chartBackgroundDashInterval: CGFloat = 2,
        chartBackgroundDashPhase: CGFloat = 2,
        /// Toggle this on and off to enable and disable the background lines behind the line graph
        useBackground: Bool = true,
        /// Toggles cubic bezier curves for the line graph
        curvedPath: Bool = true,
        /// Toggles open and closed shapes for the final path, a closed shape can be filled in with a color or gradient
        isPathOpen: Bool = true,
        animationsEnabled: Bool = true,
        /// Enable / Disable line shadows
        glowEnabled: Bool = false
    
    
    var body: some View {
        ZStack {
            chartView
                .background(model.backgroundColor)
                .background(.ultraThinMaterial)
        }
        .onAppear {
            drawPath = animationsEnabled
        }
        .onDisappear {
            drawPath = false
        }
        .animation(.spring()
            .speed(0.25),
                   value: model.chartData)
        .animation(.spring()
            .speed(0.25),
                   value: drawPath)
    }
}

// MARK: - View Combination
extension MiniHistoricalChartView {
    var chartView: some View {
        ZStack {
            if useBackground {
                chartBackground
            }
            
            chartPath
                .padding(.vertical,
                         verticalPadding)
        }
        .frame(width: size.width,
               height: size.height)
    }
    
    var chartBackground: some View {
        GeometryReader { geom in
            Path { path in
                let localWidth = geom.size.width,
                    localHeight = geom.size.height
                
                for index in 0...chartBackgroundLineDensity {
                    // Horizontal Lines
                    /// Part / Whole, the percentage of the height this line should be placed at
                    let lineSubdivisionRatio = CGFloat(index) / CGFloat(chartBackgroundLineDensity)
                    
                    let y_pos = localHeight * lineSubdivisionRatio
                    
                    path.move(to: .init(x: 0,
                                        y: y_pos))
                    path.addLine(to: .init(x: localWidth,
                                           y: y_pos))
                    
                    // Vertical Lines
                    let x_pos = localWidth * lineSubdivisionRatio
                    
                    path.move(to: .init(x: x_pos,
                                        y: 0))
                    path.addLine(to: .init(x: x_pos,
                                           y: localHeight))
                }
            }
            .trim(from: 0, to: drawPath || !animationsEnabled ? 1 : 0)
            .stroke(model.backgroundGraphLineColor,
                    style: StrokeStyle(lineWidth: backgroundGraphlineWidth,
                                       lineCap: .round,
                                       lineJoin: .round,
                                       dash: [chartBackgroundDashInterval],
                                       dashPhase: chartBackgroundDashPhase))
        }
    }
}

// MARK: - Bezier Path Generation
extension MiniHistoricalChartView {
    var openPath: Path {
        let horizontalStepSize = model.calculateHorizontalStepSize(using: size.width),
            verticalStepSize = model.calculateVerticalStepSize(using: size.height - (verticalPadding * 2))
        
        let data = model.chartData
        
        return curvedPath ?
        Path.quadCurvedPathWithPoints(points: data,
                                      step: .init(x: horizontalStepSize,
                                                  y: verticalStepSize))
        :
        Path.linePathWithPoints(points: data,
                                step: .init(x: horizontalStepSize,
                                            y: verticalStepSize))
    }
    
    var closedPath: Path {
        let horizontalStepSize = model.calculateHorizontalStepSize(using: size.width),
            verticalStepSize = model.calculateVerticalStepSize(using: size.height - (verticalPadding * 2))
        
        let data = model.chartData
        
        return curvedPath ?
        Path.quadClosedCurvedPathWithPoints(points: data,
                                            step: .init(x: horizontalStepSize,
                                                        y: verticalStepSize))
        :
        Path.closedLinePathWithPoints(points: data,
                                      step: .init(x: horizontalStepSize,
                                                  y: verticalStepSize))
    }
    
    var chartPath: some View {
        Group {
            if isPathOpen {
                openPath
                    .trim(from: 0, to: drawPath || !animationsEnabled ? 1 : 0)
                    .stroke(model.lineColor,
                            style: StrokeStyle(lineWidth: lineWidth,
                                               lineCap: .round,
                                               lineJoin: .round))
                    .if(model.lineGradient != nil) {
                        $0.applyGradient(gradient: model.lineGradient!)
                    }
            }
            else {
                closedPath
                    .trim(from: 0, to: drawPath || !animationsEnabled ? 1 : 0)
                    .fill(model.closedPathFillColor)
                    .if(model.closedPathFillGradient != nil) {
                        $0.applyGradient(gradient: model.closedPathFillGradient!)
                    }
            }
        }
        /// Invert the graph to reflect the correct orientation
        .rotationEffect(.degrees(180),
                        anchor: .center)
        .rotation3DEffect(.degrees(180),
                          axis: (x: 0,
                                 y: 1,
                                 z: 0))
        .if(glowEnabled) {
            $0.shadow(color: model.lineColor,
                      radius: 1,
                      x: 0,
                      y: 2.5)
            .shadow(color: model.lineColor.opacity(0.5),
                    radius: 1,
                    x: 0,
                    y: 5)
            .shadow(color: model.lineColor.opacity(0.25),
                    radius: 1,
                    x: 0,
                    y: 7.5)
            .shadow(color: model.lineColor.opacity(0.125),
                    radius: 1,
                    x: 0,
                    y: 10)
        }
    }
}

struct MiniHistoricalChartView_Previews: PreviewProvider {
    static func getDevEnv() -> DevEnvironment {
        let env = DevEnvironment.shared
        env.parseJSONIntoModel()
        
        return env
    }
    
    static var previews: some View {
        let env = getDevEnv()
        let coin = env.testCoinModel!
        
        MiniHistoricalChartView(model: .init(coinModel: coin))
    }
}
