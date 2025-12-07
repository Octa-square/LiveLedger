//
//  AnalyticsView.swift
//  LiveLedger
//
//  LiveLedger - DYNAMIC Sales Analytics (Real-Time Data)
//

import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var localization: LocalizationManager
    @State private var selectedPeriod: TimePeriod = .today
    @State private var hoveredPlatform: String? = nil
    
    enum TimePeriod: String, CaseIterable {
        case today = "Today"
        case week = "Week"
        case month = "Month"
    }
    
    // MARK: - Dynamic Data Computed Properties
    
    // Filter orders by selected time period
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
    
    // Total revenue from filtered orders
    var totalRevenue: Double {
        filteredOrders.reduce(0) { $0 + $1.totalPrice }
    }
    
    // Total order count
    var totalOrders: Int {
        filteredOrders.count
    }
    
    // Total items sold
    var totalItemsSold: Int {
        filteredOrders.reduce(0) { $0 + $1.quantity }
    }
    
    // Average order value
    var avgOrderValue: Double {
        totalOrders > 0 ? totalRevenue / Double(totalOrders) : 0
    }
    
    // Platform breakdown for pie chart - REAL DATA
    var platformData: [PlatformChartData] {
        var platformTotals: [String: Double] = [:]
        
        // Sum revenue by platform
        for order in filteredOrders {
            let platformName = order.platform.name
            platformTotals[platformName, default: 0] += order.totalPrice
        }
        
        let total = platformTotals.values.reduce(0, +)
        
        // Convert to chart data
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
            return PlatformChartData(
                platform: platform,
                percentage: percentage,
                revenue: revenue,
                color: color
            )
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
    
    // Daily sales for chart - REAL DATA
    var chartData: [ChartItem] {
        let calendar = Calendar.current
        var dailySales: [String: Double] = [:]
        
        let days: Int
        switch selectedPeriod {
        case .today:
            // Hourly breakdown for today
            for order in filteredOrders {
                let hour = calendar.component(.hour, from: order.timestamp)
                let label = "\(hour):00"
                dailySales[label, default: 0] += order.totalPrice
            }
            return dailySales.map { ChartItem(label: $0.key, value: Int($0.value)) }
                .sorted { $0.label < $1.label }
        case .week:
            days = 7
        case .month:
            days = 30
        }
        
        // Get daily totals for week/month
        let now = Date()
        for dayOffset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let dayOrders = filteredOrders.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
            let total = dayOrders.reduce(0) { $0 + $1.totalPrice }
            
            let formatter = DateFormatter()
            formatter.dateFormat = selectedPeriod == .week ? "EEE" : "d"
            let label = formatter.string(from: date)
            dailySales[label] = total
        }
        
        return dailySales.map { ChartItem(label: $0.key, value: Int($0.value)) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Period Selector
                Picker("Period", selection: $selectedPeriod) {
                    Text(localization.localized(.today)).tag(TimePeriod.today)
                    Text(localization.localized(.week)).tag(TimePeriod.week)
                    Text(localization.localized(.month)).tag(TimePeriod.month)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // DYNAMIC Summary Cards
                HStack(spacing: 12) {
                    AnalyticCard(
                        title: localization.localized(.revenue),
                        value: "$\(String(format: "%.2f", totalRevenue))",
                        icon: "dollarsign.circle.fill",
                        color: .green
                    )
                    
                    AnalyticCard(
                        title: localization.localized(.orders),
                        value: "\(totalOrders)",
                        icon: "bag.fill",
                        color: .blue
                    )
                }
                .padding(.horizontal)
                
                HStack(spacing: 12) {
                    AnalyticCard(
                        title: localization.localized(.avgOrder),
                        value: "$\(String(format: "%.2f", avgOrderValue))",
                        icon: "chart.bar.fill",
                        color: .purple
                    )
                    
                    AnalyticCard(
                        title: localization.localized(.itemsSold),
                        value: "\(totalItemsSold)",
                        icon: "shippingbox.fill",
                        color: .orange
                    )
                }
                .padding(.horizontal)
                
                // DYNAMIC Pie Chart - Platform Breakdown
                if !platformData.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📊 Sales by Platform")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            // Pie Chart
                            ZStack {
                                ForEach(Array(platformData.enumerated()), id: \.offset) { index, data in
                                    PieSlice(
                                        startAngle: startAngle(for: index),
                                        endAngle: endAngle(for: index),
                                        color: data.color
                                    )
                                }
                            }
                            .frame(width: 120, height: 120)
                            
                            // Legend with real data
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(platformData, id: \.platform) { data in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(data.color)
                                            .frame(width: 12, height: 12)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(data.platform)
                                                .font(.system(size: 12, weight: .medium))
                                            Text("\(String(format: "%.1f", data.percentage))% | $\(String(format: "%.2f", data.revenue))")
                                                .font(.system(size: 10))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                
                // DYNAMIC Bar Chart - Sales Trend
                VStack(alignment: .leading, spacing: 12) {
                    Text(localization.localized(.salesTrend))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if chartData.isEmpty {
                        Text("No sales data for this period")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        HStack(alignment: .bottom, spacing: 8) {
                            let maxValue = max(chartData.map { $0.value }.max() ?? 1, 1)
                            ForEach(chartData.prefix(12), id: \.label) { item in
                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(
                                            LinearGradient(
                                                colors: [.green, .green.opacity(0.6)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(
                                            width: 24,
                                            height: max(CGFloat(item.value) / CGFloat(maxValue) * 100, 4)
                                        )
                                    
                                    Text(item.label)
                                        .font(.system(size: 8))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // DYNAMIC Top Products
                VStack(alignment: .leading, spacing: 12) {
                    Text("🏆 \(localization.localized(.topSelling))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if topSellingProducts.isEmpty {
                        Text("No products sold yet")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        VStack(spacing: 8) {
                            ForEach(Array(topSellingProducts.prefix(5).enumerated()), id: \.offset) { index, product in
                                TopProductRow(
                                    rank: index + 1,
                                    name: product.name,
                                    sales: product.unitsSold,
                                    revenue: product.revenue,
                                    soldText: localization.localized(.sold)
                                )
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer(minLength: 100) // Space for bottom nav
            }
            .padding(.top)
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Helper functions for pie chart angles
    func startAngle(for index: Int) -> Angle {
        let total = platformData.reduce(0) { $0 + $1.percentage }
        let precedingTotal = platformData.prefix(index).reduce(0) { $0 + $1.percentage }
        return .degrees(total > 0 ? (precedingTotal / total) * 360 - 90 : -90)
    }
    
    func endAngle(for index: Int) -> Angle {
        let total = platformData.reduce(0) { $0 + $1.percentage }
        let includingCurrent = platformData.prefix(index + 1).reduce(0) { $0 + $1.percentage }
        return .degrees(total > 0 ? (includingCurrent / total) * 360 - 90 : -90)
    }
}

// MARK: - Supporting Data Structures

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

// MARK: - Supporting Views

struct AnalyticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Spacer()
            }
            
            HStack {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                Spacer()
            }
            
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TopProductRow: View {
    let rank: Int
    let name: String
    let sales: Int
    let revenue: Double
    let soldText: String
    
    var body: some View {
        HStack {
            Text("\(rank)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                Text("\(sales) \(soldText)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("$\(String(format: "%.2f", revenue))")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
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
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AnalyticsView(viewModel: SalesViewModel(), localization: LocalizationManager.shared)
    }
}
