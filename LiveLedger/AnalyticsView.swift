//
//  AnalyticsView.swift
//  LiveLedger
//
//  LiveLedger - Sales Analytics
//

import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var localization: LocalizationManager = LocalizationManager.shared
    @State private var selectedPeriod: TimePeriod = .week
    @State private var showMonthComparison = false
    
    enum TimePeriod: String, CaseIterable {
        case today = "Today"
        case week = "Week"
        case month = "Month"
    }
    
    // Sample data - in real app, this would come from stored orders
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
                
                // TOP SELLING SECTION - Current Month vs Previous Month
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("🏆 \(localization.localized(.topSelling))")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            showMonthComparison.toggle()
                        } label: {
                            Text(showMonthComparison ? localization.localized(.currentMonth) : localization.localized(.compare))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    if showMonthComparison {
                        // Month Comparison View
                        HStack(spacing: 12) {
                            MonthComparisonCard(
                                title: localization.localized(.currentMonth),
                                products: currentMonthTopSelling,
                                revenue: currentMonthRevenue,
                                isCurrentMonth: true
                            )
                            
                            MonthComparisonCard(
                                title: localization.localized(.previousMonth),
                                products: previousMonthTopSelling,
                                revenue: previousMonthRevenue,
                                isCurrentMonth: false
                            )
                        }
                        .padding(.horizontal)
                    } else {
                        // Top Selling Grid
                        VStack(spacing: 8) {
                            ForEach(Array(currentMonthTopSelling.enumerated()), id: \.offset) { index, product in
                                TopSellingRow(
                                    rank: index + 1,
                                    product: product,
                                    trend: productTrend(product.name),
                                    soldText: localization.localized(.sold)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                
                // Summary Cards
                HStack(spacing: 12) {
                    AnalyticCard(
                        title: localization.localized(.revenue),
                        value: "$\(sampleRevenue)",
                        icon: "dollarsign.circle.fill",
                        color: .green
                    )
                    
                    AnalyticCard(
                        title: localization.localized(.orders),
                        value: "\(sampleOrders)",
                        icon: "bag.fill",
                        color: .blue
                    )
                }
                .padding(.horizontal)
                
                HStack(spacing: 12) {
                    AnalyticCard(
                        title: localization.localized(.avgOrder),
                        value: "$\(sampleOrders > 0 ? sampleRevenue / sampleOrders : 0)",
                        icon: "chart.bar.fill",
                        color: .purple
                    )
                    
                    AnalyticCard(
                        title: localization.localized(.itemsSold),
                        value: "\(sampleItems)",
                        icon: "shippingbox.fill",
                        color: .orange
                    )
                }
                .padding(.horizontal)
                
                // Chart placeholder
                VStack(alignment: .leading, spacing: 12) {
                    Text(localization.localized(.salesTrend))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // Simple bar chart
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(chartData, id: \.label) { item in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(colors: [.green, .green.opacity(0.6)],
                                                      startPoint: .top, endPoint: .bottom)
                                    )
                                    .frame(width: 30, height: CGFloat(item.value) * 2)
                                
                                Text(item.label)
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Top Products
                VStack(alignment: .leading, spacing: 12) {
                    Text(localization.localized(.topSelling))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        TopProductRow(rank: 1, name: "\(localization.localized(.product)) 1", sales: 45, revenue: 1125, soldText: localization.localized(.sold))
                        TopProductRow(rank: 2, name: "\(localization.localized(.product)) 2", sales: 32, revenue: 960, soldText: localization.localized(.sold))
                        TopProductRow(rank: 3, name: "\(localization.localized(.product)) 3", sales: 28, revenue: 700, soldText: localization.localized(.sold))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Platform breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text(localization.localized(.byPlatform))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        PlatformStatRow(platform: "TikTok", percentage: 45, color: .pink)
                        PlatformStatRow(platform: "Instagram", percentage: 35, color: .purple)
                        PlatformStatRow(platform: "Facebook", percentage: 20, color: .blue)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 30)
            }
            .padding(.top)
        }
        .navigationTitle(localization.localized(.salesAnalytics))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Sample data based on selected period
    var sampleRevenue: Int {
        switch selectedPeriod {
        case .today: return 450
        case .week: return 2850
        case .month: return 12400
        }
    }
    
    var sampleOrders: Int {
        switch selectedPeriod {
        case .today: return 18
        case .week: return 105
        case .month: return 456
        }
    }
    
    var sampleItems: Int {
        switch selectedPeriod {
        case .today: return 24
        case .week: return 142
        case .month: return 612
        }
    }
    
    var chartData: [(label: String, value: Int)] {
        switch selectedPeriod {
        case .today:
            return [("9am", 20), ("11am", 45), ("1pm", 35), ("3pm", 60), ("5pm", 50), ("7pm", 40)]
        case .week:
            return [("Mon", 35), ("Tue", 42), ("Wed", 55), ("Thu", 48), ("Fri", 62), ("Sat", 70), ("Sun", 45)]
        case .month:
            return [("W1", 45), ("W2", 52), ("W3", 48), ("W4", 65)]
        }
    }
    
    // Top Selling Products - Current Month
    var currentMonthTopSelling: [TopProduct] {
        [
            TopProduct(name: "Product A", sales: 156, revenue: 3900, growth: 23),
            TopProduct(name: "Product B", sales: 124, revenue: 3720, growth: 15),
            TopProduct(name: "Product C", sales: 98, revenue: 2450, growth: -5),
            TopProduct(name: "Product D", sales: 87, revenue: 2175, growth: 8),
            TopProduct(name: "Product E", sales: 65, revenue: 1625, growth: 42)
        ]
    }
    
    // Top Selling Products - Previous Month
    var previousMonthTopSelling: [TopProduct] {
        [
            TopProduct(name: "Product A", sales: 127, revenue: 3175, growth: 0),
            TopProduct(name: "Product B", sales: 108, revenue: 3240, growth: 0),
            TopProduct(name: "Product D", sales: 103, revenue: 2575, growth: 0),
            TopProduct(name: "Product C", sales: 81, revenue: 2025, growth: 0),
            TopProduct(name: "Product F", sales: 72, revenue: 1800, growth: 0)
        ]
    }
    
    var currentMonthRevenue: Int { 13870 }
    var previousMonthRevenue: Int { 12815 }
    
    func productTrend(_ name: String) -> Int {
        // Compare with previous month
        if let current = currentMonthTopSelling.first(where: { $0.name == name }),
           let previous = previousMonthTopSelling.first(where: { $0.name == name }) {
            guard previous.sales > 0 else { return 100 }
            return Int(((Double(current.sales) - Double(previous.sales)) / Double(previous.sales)) * 100)
        }
        return 0
    }

}

// MARK: - Top Product Model
struct TopProduct: Identifiable {
    let id = UUID()
    let name: String
    let sales: Int
    let revenue: Int
    let growth: Int
}

// MARK: - Top Selling Row
struct TopSellingRow: View {
    let rank: Int
    let product: TopProduct
    let trend: Int
    var soldText: String = "sold"
    
    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .gray.opacity(0.5)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                if rank <= 3 {
                    Text(rank == 1 ? "🥇" : rank == 2 ? "🥈" : "🥉")
                        .font(.system(size: 16))
                } else {
                    Text("#\(rank)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.system(size: 14, weight: .semibold))
                
                Text("\(product.sales) \(soldText)")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Trend indicator
            if trend != 0 {
                HStack(spacing: 2) {
                    Image(systemName: trend > 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 10, weight: .bold))
                    Text("\(abs(trend))%")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(trend > 0 ? .green : .red)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background((trend > 0 ? Color.green : Color.red).opacity(0.1))
                .cornerRadius(4)
            }
            
            Text("$\(product.revenue)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.green)
                .frame(width: 65, alignment: .trailing)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Month Comparison Card
struct MonthComparisonCard: View {
    let title: String
    let products: [TopProduct]
    let revenue: Int
    let isCurrentMonth: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isCurrentMonth ? .green : .gray)
                
                Spacer()
                
                Text("$\(revenue)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isCurrentMonth ? .green : .gray)
            }
            
            Divider()
            
            ForEach(Array(products.prefix(3).enumerated()), id: \.offset) { index, product in
                HStack(spacing: 6) {
                    Text("\(index + 1).")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(width: 16)
                    
                    Text(product.name)
                        .font(.system(size: 12))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("\(product.sales)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(isCurrentMonth ? .primary : .gray)
                }
            }

        }
        .padding(12)
        .background(isCurrentMonth ? Color(.systemGray6) : Color(.systemGray5).opacity(0.5))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isCurrentMonth ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

struct AnalyticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TopProductRow: View {
    let rank: Int
    let name: String
    let sales: Int
    let revenue: Int
    var soldText: String = "sold"
    
    var body: some View {
        HStack {
            Text("#\(rank)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
                .frame(width: 24)
            
            Text(name)
                .font(.system(size: 14, weight: .medium))
            
            Spacer()
            
            Text("\(sales) \(soldText)")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            Text("$\(revenue)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.green)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

struct PlatformStatRow: View {
    let platform: String
    let percentage: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(platform)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Text("\(percentage)%")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(color)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(percentage) / 100, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        AnalyticsView(localization: LocalizationManager.shared)
    }
}


