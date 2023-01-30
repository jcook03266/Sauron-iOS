//
//  MiniHistoricalChartViewModel.swift
//  Sauron
//
//  Created by Justin Cook on 1/29/23.
//

import SwiftUI

class MiniHistoricalChartViewModel: GenericViewModel {
    // MARK: - Published
    @Published var coinModel: CoinModel
    @Published var chartData: [Double] = []
    
    // MARK: - Chart Bounds
    // Y-axis
    var y_axis: Double {
        return maxY - minY
    }
    
    // Y-axis Range
    var maxY: Double = 0
    var minY: Double = 0
    
    // MARK: - Convenience
    var dataPointCount: Int {
        return chartData.count
    }
    
    var priceChange: Double {
        return (chartData.last ?? 0) - (chartData.first ?? 0)
    }
    
    var wasPriceChangePositive: Bool {
        return priceChange >= 0
    }
    
    // MARK: - Data Stores
    struct DataStores: InjectableStores {
        let portfolioManager: PortfolioManager = inject()
        let coinStore: CoinStore = inject()
    }
    let dataStores = DataStores()
    
    // MARK: - Styling
    // Colors
    let backgroundGraphLineColor: Color = Colors.neutral_100.0
    
    var backgroundColor: Color = Colors.white.0.opacity(0.8)
    
    // Closed Path Coloring
    var closedPathFillColor: Color {
        return lineColor
    }
    
    var closedPathFillGradient: LinearGradient? = nil
    
    // Open Path Coloring
    /// Line Color changes depending on the performance of the coin over the specified data range
    var lineColor: Color {
        return wasPriceChangePositive ? positiveTrendLineColor : negativeTrendLineColor
    }
    
    var lineGradient: LinearGradient? = nil
    
    var positiveTrendLineColor: Color {
        return dataStores.coinStore.getThemeColor(for: coinModel) ?? Colors.primary_2.0
    }
    
    var negativeTrendLineColor: Color {
        return Colors.attention.0
    }
    
    init(coinModel: CoinModel) {
        self.coinModel = coinModel
        
        loadChartData()
    }
    
    // MARK: - Data Loader
    private func loadChartData() {
        self.chartData = coinModel.sparklineIn7D.price ?? []
        self.maxY = chartData.max().unwrap(defaultValue: maxY)
        self.minY = chartData.min().unwrap(defaultValue: minY)
    }
    
    // MARK: - Graph Step Size calculation
    func calculateHorizontalStepSize(using width: CGFloat) -> CGFloat {
        return width / CGFloat(dataPointCount - 1)
    }
    
    func calculateVerticalStepSize(using height: CGFloat) -> CGFloat {
        return height / CGFloat(y_axis)
    }
    
    // MARK: - Graph data point coordinate system calculator
    func calculateXPosition(at index: Int,
                            for width: CGFloat) -> CGFloat {
        // The data count starts at 1 so the index has to add 1 to match it
        let x_pos = width / CGFloat(dataPointCount) * CGFloat(index + 1)
        
        return x_pos
    }
    
    func calculateYPosition(at index: Int,
                            for height: CGFloat) -> CGFloat {
        // Note: Subtracting by 1 inverts the graph b/c point 0,0 is at the top left instead of the bottom left, as well as the other points due to the nature of the screen's coordinate space
        let y_pos = (1 - (chartData[index] - minY) / y_axis) * height
        
        return y_pos
    }
}
