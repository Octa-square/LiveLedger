//
//  AnalyticsView.swift
//  LiveLedger
//
//  LiveLedger - DYNAMIC Sales Analytics with Grid Containers
//

import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var localization: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod: TimePeriod = .today
    @State private var comparePlatform1: String = ""
    @State private var comparePlatform2: String = ""
    @State private var compareProduct1: String = ""
    @State private var compareProduct2: String = ""
    @State private var analyticsExportURL: URL?
    @State private var showAnalyticsShareSheet = false
    
    // Green grid container styling (same as Home page)
    private let containerCornerRadius: CGFloat = 12
    private let containerBorderColor = Color(red: 0, green: 0.8, blue: 0.53) // #00cc88
    private let containerBorderWidth: CGFloat = 2
    private let containerBackground = Color.black.opacity(0.75)
    private let horizontalMargin: CGFloat = 11
    
    enum TimePeriod: String, CaseIterable {
        case today = "Today"
        case week = "Week"
        case month = "Month"
        
        func localized(_ manager: LocalizationManager) -> String {
            switch self {
            case .today: return manager.localized(.today)
            case .week: return manager.localized(.week)
            case .month: return manager.localized(.month)
            }
        }
    }
    
    // MARK: - CSV Export Builders
    private var summaryStatsCSV: String {
        "Metric,Value\n\"\(localization.localized(.revenue))\",\"$\(String(format: "%.2f", totalRevenue))\"\n\"\(localization.localized(.orders))\",\(totalOrders)\n\"\(localization.localized(.avgOrder))\",\"$\(String(format: "%.2f", avgOrderValue))\"\n\"\(localization.localized(.itemsSold))\",\(totalItemsSold)"
    }
    private var salesPerformanceCSV: String {
        let rows = dailyChartData.map { "\"\($0.label)\",\($0.value)" }.joined(separator: "\n")
        return "Period,Sales\n\(rows)"
    }
    private var platformBreakdownCSV: String {
        let rows = platformData.map { "\"\($0.platform)\",\(String(format: "%.2f", $0.revenue)),\(String(format: "%.1f", $0.percentage))" }.joined(separator: "\n")
        return "Platform,Revenue,Percentage\n\(rows)"
    }
    private var topProductsCSV: String {
        let rows = topSellingProducts.enumerated().map { i, p in "\(i+1),\"\(p.name)\",\(p.unitsSold),\(String(format: "%.2f", p.revenue))" }.joined(separator: "\n")
        return "Rank,Product,Units Sold,Revenue\n\(rows)"
    }
    private var platformComparisonCSV: String {
        guard !comparePlatform1.isEmpty, !comparePlatform2.isEmpty else { return "" }
        let s1 = (orders: viewModel.orders.filter { $0.platform.name == comparePlatform1 }, name: comparePlatform1)
        let s2 = (orders: viewModel.orders.filter { $0.platform.name == comparePlatform2 }, name: comparePlatform2)
        let r1 = s1.orders.reduce(0) { $0 + $1.totalPrice }; let c1 = s1.orders.count; let a1 = c1 > 0 ? r1/Double(c1) : 0.0
        let r2 = s2.orders.reduce(0) { $0 + $1.totalPrice }; let c2 = s2.orders.count; let a2 = c2 > 0 ? r2/Double(c2) : 0.0
        return "Platform,Revenue,Orders,Avg Order\n\"\(s1.name)\",\(String(format: "%.2f", r1)),\(c1),\(String(format: "%.2f", a1))\n\"\(s2.name)\",\(String(format: "%.2f", r2)),\(c2),\(String(format: "%.2f", a2))"
    }
    private var productComparisonCSV: String {
        guard !compareProduct1.isEmpty, !compareProduct2.isEmpty else { return "" }
        let s1 = viewModel.orders.filter { $0.productName == compareProduct1 }; let r1 = s1.reduce(0) { $0 + $1.totalPrice }; let u1 = s1.reduce(0) { $0 + $1.quantity }
        let s2 = viewModel.orders.filter { $0.productName == compareProduct2 }; let r2 = s2.reduce(0) { $0 + $1.totalPrice }; let u2 = s2.reduce(0) { $0 + $1.quantity }
        return "Product,Revenue,Units Sold\n\"\(compareProduct1)\",\(String(format: "%.2f", r1)),\(u1)\n\"\(compareProduct2)\",\(String(format: "%.2f", r2)),\(u2)"
    }

    // MARK: - Export Helper
    private func exportAnalytics(csv: String, filename: String) {
        guard let data = csv.data(using: .utf8) else { return }
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL)
            analyticsExportURL = fileURL
            showAnalyticsShareSheet = true
        } catch { }
    }

    // MARK: - Grid Container (Same as Home Page)
    private func gridContainer<Content: View>(title: String, exportCSV: String? = nil, exportFilename: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(containerBorderColor)
                Spacer()
                if let csv = exportCSV, let filename = exportFilename {
                    Button {
                        exportAnalytics(csv: csv, filename: filename)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14))
                            .foregroundColor(containerBorderColor)
                    }
                }
            }

            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: containerCornerRadius)
                .fill(containerBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: containerCornerRadius)
                .strokeBorder(containerBorderColor, lineWidth: containerBorderWidth)
        )
        .padding(.horizontal, horizontalMargin)
    }
    
    private var dateStamp: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd_HHmm"; return f.string(from: Date())
    }

    // MARK: - Dynamic Data Computed Properties
    
    var filteredOrders: [Order] {
        let now = Date()
        let calendar = Calendar.current
        
        return viewModel.orders.filter { order in
            switch selectedPeriod {
            case .today:
                return calendar.isDateInToday(order.timestamp)
            case .week:
                let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
                return order.timestamp >= weekAgo
            case .month:
                return calendar.isDate(order.timestamp, equalTo: now, toGranularity: .month)
            }
        }
    }
    
    var totalRevenue: Double {
        filteredOrders.reduce(0) { $0 + $1.totalPrice }
    }
    
    var totalOrders: Int {
        filteredOrders.count
    }
    
    var totalItemsSold: Int {
        filteredOrders.reduce(0) { $0 + $1.quantity }
    }
    
    var avgOrderValue: Double {
        totalOrders > 0 ? totalRevenue / Double(totalOrders) : 0
    }
    
    // Platform breakdown - REAL DATA
    var platformData: [PlatformChartData] {
        var platformTotals: [String: Double] = [:]
        
        for order in filteredOrders {
            let platformName = order.platform.name
            platformTotals[platformName, default: 0] += order.totalPrice
        }
        
        let total = platformTotals.values.reduce(0, +)
        
        return platformTotals.map { platform, revenue in
            let percentage = total > 0 ? (revenue / total) * 100 : 0
            let color: Color = {
                switch platform.lowercased() {
                case "tiktok": return .pink
                case "instagram": return .purple
                case "facebook": return .blue
                default: return .orange
                }
            }()
            return PlatformChartData(platform: platform, percentage: percentage, revenue: revenue, color: color)
        }.sorted { $0.revenue > $1.revenue }
    }
    
    // Top selling products - REAL DATA
    var topSellingProducts: [TopProduct] {
        var productStats: [String: (units: Int, revenue: Double)] = [:]
        
        for order in filteredOrders {
            let name = order.productName
            let current = productStats[name] ?? (0, 0)
            productStats[name] = (current.units + order.quantity, current.revenue + order.totalPrice)
        }
        
        return productStats.map { name, stats in
            TopProduct(name: name, unitsSold: stats.units, revenue: stats.revenue)
        }
        .sorted { $0.revenue > $1.revenue }
        .prefix(10)
        .map { $0 }
    }
    
    // Daily sales for bar chart - REAL DATA
    var dailyChartData: [ChartItem] {
        let calendar = Calendar.current
        var dailySales: [String: Double] = [:]
        let now = Date()
        
        switch selectedPeriod {
        case .today:
            // Hourly breakdown
            for hour in 0..<24 {
                dailySales[String(format: "%02d", hour)] = 0
            }
            for order in filteredOrders {
                let hour = calendar.component(.hour, from: order.timestamp)
                let label = String(format: "%02d", hour)
                dailySales[label, default: 0] += order.totalPrice
            }
        case .week:
            // Last 7 days
            for dayOffset in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "EEE"
                    let label = formatter.string(from: date)
                    let dayOrders = filteredOrders.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
                    dailySales[label] = dayOrders.reduce(0) { $0 + $1.totalPrice }
                }
            }
        case .month:
            // Last 30 days grouped by week
            for weekOffset in 0..<4 {
                let weekStart = calendar.date(byAdding: .day, value: -(weekOffset * 7), to: now) ?? now
                let weekEnd = calendar.date(byAdding: .day, value: -((weekOffset + 1) * 7), to: now) ?? now
                let weekOrders = filteredOrders.filter { $0.timestamp <= weekStart && $0.timestamp > weekEnd }
                dailySales["W\(4 - weekOffset)"] = weekOrders.reduce(0) { $0 + $1.totalPrice }
            }
        }
        
        return dailySales.map { ChartItem(label: $0.key, value: Int($0.value)) }
            .sorted { $0.label < $1.label }
    }
    
    // Available platforms for comparison
    var availablePlatforms: [String] {
        let platforms = Set(viewModel.orders.map { $0.platform.name })
        return Array(platforms).sorted()
    }
    
    // Available products for comparison
    var availableProducts: [String] {
        let products = Set(viewModel.orders.map { $0.productName })
        return Array(products).sorted()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Time Period Selector
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.localized(localization)).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, horizontalMargin)
                
                // CONTAINER 1: Summary Stats (green border)
                gridContainer(title: "📊 \(localization.localized(.salesAnalytics))", exportCSV: summaryStatsCSV, exportFilename: "LiveLedger_Summary_\(selectedPeriod.rawValue)_\(dateStamp).csv") {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatBox(title: localization.localized(.revenue), value: "$\(String(format: "%.2f", totalRevenue))", color: .green)
                        StatBox(title: localization.localized(.orders), value: "\(totalOrders)", color: .blue)
                        StatBox(title: localization.localized(.avgOrder), value: "$\(String(format: "%.2f", avgOrderValue))", color: .purple)
                        StatBox(title: localization.localized(.itemsSold), value: "\(totalItemsSold)", color: .orange)
                    }
                }
                
                // CONTAINER 2: Bar Chart - Sales Performance (green border)
                gridContainer(title: "📈 Sales Performance", exportCSV: salesPerformanceCSV, exportFilename: "LiveLedger_SalesPerformance_\(selectedPeriod.rawValue)_\(dateStamp).csv") {
                    if dailyChartData.isEmpty || dailyChartData.allSatisfy({ $0.value == 0 }) {
                        EmptyDataView(message: "No sales data for this period")
                    } else {
                        BarChartView(data: dailyChartData, accentColor: containerBorderColor)
                            .frame(height: 180)
                    }
                }
                
                // CONTAINER 3: Pie Chart - Platform Breakdown (green border)
                gridContainer(title: "🥧 Sales by Platform", exportCSV: platformBreakdownCSV, exportFilename: "LiveLedger_PlatformBreakdown_\(selectedPeriod.rawValue)_\(dateStamp).csv") {
                    if platformData.isEmpty {
                        EmptyDataView(message: "No platform data available")
                    } else {
                        HStack(spacing: 20) {
                            // Pie Chart
                            PieChartView(data: platformData)
                                .frame(width: 120, height: 120)
                            
                            // Legend
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(platformData, id: \.platform) { item in
                                    HStack(spacing: 8) {
                                        Circle().fill(item.color).frame(width: 10, height: 10)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.platform)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white)
                                            Text("\(String(format: "%.1f", item.percentage))% | $\(String(format: "%.2f", item.revenue))")
                                                .font(.system(size: 10))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                
                                Divider().background(containerBorderColor)
                                
                                Text("Total: $\(String(format: "%.2f", totalRevenue))")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(containerBorderColor)
                            }
                        }
                    }
                }
                
                // CONTAINER 4: Top Selling Products (green border)
                gridContainer(title: "🏆 Top Selling Products", exportCSV: topProductsCSV, exportFilename: "LiveLedger_TopProducts_\(selectedPeriod.rawValue)_\(dateStamp).csv") {
                    if topSellingProducts.isEmpty {
                        EmptyDataView(message: "No products sold yet")
                    } else {
                        VStack(spacing: 8) {
                            ForEach(Array(topSellingProducts.prefix(5).enumerated()), id: \.offset) { index, product in
                                TopProductRow(rank: index + 1, product: product, accentColor: containerBorderColor)
                            }
                        }
                    }
                }
                
                // CONTAINER 5: Platform Comparison (green border)
                gridContainer(title: "⚖️ Platform Comparison", exportCSV: platformComparisonCSV.isEmpty ? nil : platformComparisonCSV, exportFilename: platformComparisonCSV.isEmpty ? nil : "LiveLedger_PlatformCompare_\(dateStamp).csv") {
                    if availablePlatforms.count < 2 {
                        EmptyDataView(message: "Need 2+ platforms with sales to compare")
                    } else {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Picker("Platform 1", selection: $comparePlatform1) {
                                    Text("Select").tag("")
                                    ForEach(availablePlatforms, id: \.self) { platform in
                                        Text(platform).tag(platform)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(8)
                                
                                Text("vs")
                                    .foregroundColor(.gray)
                                
                                Picker("Platform 2", selection: $comparePlatform2) {
                                    Text("Select").tag("")
                                    ForEach(availablePlatforms, id: \.self) { platform in
                                        Text(platform).tag(platform)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(8)
                            }
                            
                            if !comparePlatform1.isEmpty && !comparePlatform2.isEmpty {
                                PlatformComparisonView(
                                    platform1: comparePlatform1,
                                    platform2: comparePlatform2,
                                    orders: viewModel.orders,
                                    accentColor: containerBorderColor
                                )
                            }
                        }
                    }
                }
                
                // CONTAINER 6: Product Comparison (green border)
                gridContainer(title: "📦 Product Comparison", exportCSV: productComparisonCSV.isEmpty ? nil : productComparisonCSV, exportFilename: productComparisonCSV.isEmpty ? nil : "LiveLedger_ProductCompare_\(dateStamp).csv") {
                    if availableProducts.count < 2 {
                        EmptyDataView(message: "Need 2+ products with sales to compare")
                    } else {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Picker("Product 1", selection: $compareProduct1) {
                                    Text("Select").tag("")
                                    ForEach(availableProducts, id: \.self) { product in
                                        Text(product).tag(product)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(8)
                                
                                Text("vs")
                                    .foregroundColor(.gray)
                                
                                Picker("Product 2", selection: $compareProduct2) {
                                    Text("Select").tag("")
                                    ForEach(availableProducts, id: \.self) { product in
                                        Text(product).tag(product)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(8)
                            }
                            
                            if !compareProduct1.isEmpty && !compareProduct2.isEmpty {
                                ProductComparisonView(
                                    product1: compareProduct1,
                                    product2: compareProduct2,
                                    orders: viewModel.orders,
                                    accentColor: containerBorderColor
                                )
                            }
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.top, 16)
        }
        .navigationTitle(localization.localized(.analytics))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showAnalyticsShareSheet, onDismiss: {
            if let url = analyticsExportURL {
                try? FileManager.default.removeItem(at: url)
            }
            analyticsExportURL = nil
        }) {
            if let url = analyticsExportURL {
                ShareSheet(items: [url])
            }
        }
        .onAppear {
            // Initialize comparison dropdowns
            if comparePlatform1.isEmpty, let first = availablePlatforms.first {
                comparePlatform1 = first
            }
            if comparePlatform2.isEmpty, let last = availablePlatforms.last, last != comparePlatform1 {
                comparePlatform2 = last
            }
            if compareProduct1.isEmpty, let first = availableProducts.first {
                compareProduct1 = first
            }
            if compareProduct2.isEmpty, let last = availableProducts.last, last != compareProduct1 {
                compareProduct2 = last
            }
        }
    }
}

// MARK: - Supporting Views

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
    }
}

struct EmptyDataView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 32))
                .foregroundColor(.gray.opacity(0.5))
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Text("Add orders to see analytics")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(30)
    }
}

struct BarChartView: View {
    let data: [ChartItem]
    let accentColor: Color
    
    var body: some View {
        let maxValue = max(data.map { $0.value }.max() ?? 1, 1)
        
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(data.prefix(12), id: \.label) { item in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [accentColor, accentColor.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(
                            width: 20,
                            height: max(CGFloat(item.value) / CGFloat(maxValue) * 140, 4)
                        )
                    
                    Text(item.label)
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PieChartView: View {
    let data: [PlatformChartData]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    PieSlice(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index),
                        color: item.color
                    )
                }
            }
        }
    }
    
    func startAngle(for index: Int) -> Angle {
        let total = data.reduce(0) { $0 + $1.percentage }
        let precedingTotal = data.prefix(index).reduce(0) { $0 + $1.percentage }
        return .degrees(total > 0 ? (precedingTotal / total) * 360 - 90 : -90)
    }
    
    func endAngle(for index: Int) -> Angle {
        let total = data.reduce(0) { $0 + $1.percentage }
        let includingCurrent = data.prefix(index + 1).reduce(0) { $0 + $1.percentage }
        return .degrees(total > 0 ? (includingCurrent / total) * 360 - 90 : -90)
    }
}

struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2
                
                path.move(to: center)
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.closeSubpath()
            }
            .fill(color)
            .overlay(
                Path { path in
                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    let radius = min(geometry.size.width, geometry.size.height) / 2
                    
                    path.move(to: center)
                    path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    path.closeSubpath()
                }
                .stroke(Color.black, lineWidth: 2)
            )
        }
    }
}

struct TopProductRow: View {
    let rank: Int
    let product: TopProduct
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text("#\(rank)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Text("\(product.unitsSold) units sold")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("$\(String(format: "%.2f", product.revenue))")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(accentColor)
        }
        .padding(10)
        .background(accentColor.opacity(0.1))
        .cornerRadius(8)
    }
}

struct PlatformComparisonView: View {
    let platform1: String
    let platform2: String
    let orders: [Order]
    let accentColor: Color
    
    var stats1: (revenue: Double, orders: Int, avgOrder: Double) {
        let filtered = orders.filter { $0.platform.name == platform1 }
        let revenue = filtered.reduce(0) { $0 + $1.totalPrice }
        let count = filtered.count
        return (revenue, count, count > 0 ? revenue / Double(count) : 0)
    }
    
    var stats2: (revenue: Double, orders: Int, avgOrder: Double) {
        let filtered = orders.filter { $0.platform.name == platform2 }
        let revenue = filtered.reduce(0) { $0 + $1.totalPrice }
        let count = filtered.count
        return (revenue, count, count > 0 ? revenue / Double(count) : 0)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ComparisonColumn(title: platform1, revenue: stats1.revenue, orders: stats1.orders, avgOrder: stats1.avgOrder, isWinner: stats1.revenue > stats2.revenue, accentColor: accentColor)
                ComparisonColumn(title: platform2, revenue: stats2.revenue, orders: stats2.orders, avgOrder: stats2.avgOrder, isWinner: stats2.revenue > stats1.revenue, accentColor: accentColor)
            }
            
            // Winner announcement
            Text(stats1.revenue > stats2.revenue
                ? "\(platform1) leads by $\(String(format: "%.2f", stats1.revenue - stats2.revenue))"
                : stats2.revenue > stats1.revenue
                ? "\(platform2) leads by $\(String(format: "%.2f", stats2.revenue - stats1.revenue))"
                : "Both platforms tied!")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(accentColor)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(accentColor.opacity(0.2))
                .cornerRadius(8)
        }
    }
}

struct ProductComparisonView: View {
    let product1: String
    let product2: String
    let orders: [Order]
    let accentColor: Color
    
    var stats1: (revenue: Double, units: Int) {
        let filtered = orders.filter { $0.productName == product1 }
        let revenue = filtered.reduce(0) { $0 + $1.totalPrice }
        let units = filtered.reduce(0) { $0 + $1.quantity }
        return (revenue, units)
    }
    
    var stats2: (revenue: Double, units: Int) {
        let filtered = orders.filter { $0.productName == product2 }
        let revenue = filtered.reduce(0) { $0 + $1.totalPrice }
        let units = filtered.reduce(0) { $0 + $1.quantity }
        return (revenue, units)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ProductComparisonColumn(title: product1, revenue: stats1.revenue, units: stats1.units, isWinner: stats1.revenue > stats2.revenue, accentColor: accentColor)
                ProductComparisonColumn(title: product2, revenue: stats2.revenue, units: stats2.units, isWinner: stats2.revenue > stats1.revenue, accentColor: accentColor)
            }
            
            Text(stats1.revenue > stats2.revenue
                ? "\(product1) leads by $\(String(format: "%.2f", stats1.revenue - stats2.revenue))"
                : stats2.revenue > stats1.revenue
                ? "\(product2) leads by $\(String(format: "%.2f", stats2.revenue - stats1.revenue))"
                : "Both products tied!")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(accentColor)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(accentColor.opacity(0.2))
                .cornerRadius(8)
        }
    }
}

struct ComparisonColumn: View {
    let title: String
    let revenue: Double
    let orders: Int
    let avgOrder: Double
    let isWinner: Bool
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isWinner ? accentColor : .white)
            
            Text("$\(String(format: "%.2f", revenue))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isWinner ? accentColor : .gray)
            
            Text("\(orders) orders")
                .font(.system(size: 11))
                .foregroundColor(.gray)
            
            Text("Avg: $\(String(format: "%.2f", avgOrder))")
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(isWinner ? accentColor.opacity(0.15) : Color.black.opacity(0.3))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(isWinner ? accentColor : Color.clear, lineWidth: 2)
        )
    }
}

struct ProductComparisonColumn: View {
    let title: String
    let revenue: Double
    let units: Int
    let isWinner: Bool
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isWinner ? accentColor : .white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Text("$\(String(format: "%.2f", revenue))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isWinner ? accentColor : .gray)
            
            Text("\(units) units sold")
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(isWinner ? accentColor.opacity(0.15) : Color.black.opacity(0.3))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(isWinner ? accentColor : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Data Structures

struct PlatformChartData: Identifiable {
    let id = UUID()
    let platform: String
    let percentage: Double
    let revenue: Double
    let color: Color
}

struct TopProduct: Identifiable {
    let id = UUID()
    let name: String
    let unitsSold: Int
    let revenue: Double
}

struct ChartItem: Identifiable {
    let id = UUID()
    let label: String
    let value: Int
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AnalyticsView(viewModel: SalesViewModel(), localization: LocalizationManager.shared)
    }
    .preferredColorScheme(.dark)
}
