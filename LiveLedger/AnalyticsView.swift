//
//  AnalyticsView.swift
//  LiveLedger
//
//  LiveLedger - Sales Analytics with Real Data
//

import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @ObservedObject var themeManager: ThemeManager
    
    @State private var selectedPeriod: TimePeriod = .week
    @State private var selectedPlatformFilter: Platform? = nil
    @State private var customStartDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var customEndDate = Date()
    @State private var showCustomDatePicker = false
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    var currencySymbol: String {
        authManager.currentUser?.currencySymbol ?? "$"
    }
    
    enum TimePeriod: String, CaseIterable {
        case today = "Today"
        case week = "Week"
        case month = "Month"
        case custom = "Custom"
    }
    
    // MARK: - Filtered Orders
    private var filteredOrders: [Order] {
        let dateFiltered = viewModel.orders.filter { order in
            switch selectedPeriod {
            case .today:
                return Calendar.current.isDateInToday(order.timestamp)
            case .week:
                let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                return order.timestamp >= weekAgo
            case .month:
                let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
                return order.timestamp >= monthAgo
            case .custom:
                return order.timestamp >= customStartDate && order.timestamp <= customEndDate
            }
        }
        
        if let platform = selectedPlatformFilter {
            return dateFiltered.filter { $0.platform.id == platform.id }
        }
        return dateFiltered
    }
    
    // MARK: - Computed Stats
    private var totalRevenue: Double {
        filteredOrders.reduce(0.0) { $0 + ($1.pricePerUnit * Double($1.quantity)) }
    }
    
    private var totalOrders: Int {
        filteredOrders.count
    }
    
    private var totalQuantity: Int {
        filteredOrders.reduce(0) { $0 + $1.quantity }
    }
    
    private var averageOrderValue: Double {
        totalOrders > 0 ? totalRevenue / Double(totalOrders) : 0
    }
    
    // Platform breakdown
    private var platformBreakdown: [(platform: Platform, revenue: Double, orders: Int)] {
        var breakdown: [UUID: (platform: Platform, revenue: Double, orders: Int)] = [:]
        
        for order in filteredOrders {
            let platformId = order.platform.id
            if var existing = breakdown[platformId] {
                existing.revenue += order.pricePerUnit * Double(order.quantity)
                existing.orders += 1
                breakdown[platformId] = existing
            } else {
                breakdown[platformId] = (order.platform, order.pricePerUnit * Double(order.quantity), 1)
            }
        }
        
        return breakdown.values.sorted { $0.revenue > $1.revenue }
    }
    
    // Top selling products
    private var topProducts: [(name: String, quantity: Int, revenue: Double)] {
        var products: [String: (quantity: Int, revenue: Double)] = [:]
        
        for order in filteredOrders {
            let name = order.productName
            if var existing = products[name] {
                existing.quantity += order.quantity
                existing.revenue += order.pricePerUnit * Double(order.quantity)
                products[name] = existing
            } else {
                products[name] = (order.quantity, order.pricePerUnit * Double(order.quantity))
            }
        }
        
        return products.map { (name: $0.key, quantity: $0.value.quantity, revenue: $0.value.revenue) }
            .sorted { $0.quantity > $1.quantity }
            .prefix(5)
            .map { $0 }
    }
    
    // Default platforms (TikTok, Instagram, Facebook)
    private var defaultPlatforms: [Platform] {
        viewModel.platforms.filter { !$0.isCustom }
    }
    
    // Custom platforms
    private var customPlatforms: [Platform] {
        viewModel.platforms.filter { $0.isCustom }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Time Period Card
                timePeriodCard
                
                // Platform Filter Card
                platformFilterCard
                
                // Summary Stats Card
                summaryStatsCard
                
                // Sales by Platform (Pie Chart)
                if !platformBreakdown.isEmpty {
                    salesByPlatformCard
                }
                
                // Top Selling Products
                topProductsCard
                
                // Sales Over Time
                salesOverTimeCard
            }
            .padding(16)
        }
        .background(theme.gradientColors[0].ignoresSafeArea())
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCustomDatePicker) {
            customDatePickerSheet
        }
    }
    
    // MARK: - Time Period Card
    private var timePeriodCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time Period")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.textPrimary)
            
            HStack(spacing: 8) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Button {
                        if period == .custom {
                            showCustomDatePicker = true
                        }
                        selectedPeriod = period
                    } label: {
                        Text(period.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(selectedPeriod == period ? .white : theme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedPeriod == period ? theme.accentColor : theme.cardBackground.opacity(0.5))
                            )
                    }
                }
            }
            
            if selectedPeriod == .custom {
                Text("\(customStartDate.formatted(date: .abbreviated, time: .omitted)) - \(customEndDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.system(size: 11))
                    .foregroundColor(theme.textMuted)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowDark.opacity(0.1), radius: 4, y: 2)
        )
    }
    
    // MARK: - Platform Filter Card
    private var platformFilterCard: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack {
                Text("Filter by Platform")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(theme.textPrimary)
                Spacer()
            }
            
            GeometryReader { geo in
                // Calculate chip width: total width minus spacing (3 gaps of 6px each)
                let totalSpacing: CGFloat = 6 * 3 // 18px for gaps between 4 chips
                let chipWidth: CGFloat = (geo.size.width - totalSpacing) / 4
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        // "All" button
                        AnalyticsPlatformChip(
                            name: "All",
                            icon: "square.grid.2x2",
                            color: theme.accentColor,
                            isSelected: selectedPlatformFilter == nil,
                            width: chipWidth,
                            theme: theme
                        ) {
                            selectedPlatformFilter = nil
                        }
                        
                        // Default platforms (TikTok, Instagram, Facebook)
                        ForEach(defaultPlatforms) { platform in
                            AnalyticsPlatformChip(
                                name: platform.name,
                                icon: platform.icon,
                                color: platform.swiftUIColor,
                                isSelected: selectedPlatformFilter?.id == platform.id,
                                width: chipWidth,
                                theme: theme
                            ) {
                                selectedPlatformFilter = platform
                            }
                        }
                        
                        // Custom platforms - completely hidden until scrolled
                        ForEach(customPlatforms) { platform in
                            AnalyticsPlatformChip(
                                name: platform.name,
                                icon: platform.icon,
                                color: platform.swiftUIColor,
                                isSelected: selectedPlatformFilter?.id == platform.id,
                                width: chipWidth,
                                theme: theme
                            ) {
                                selectedPlatformFilter = platform
                            }
                        }
                    }
                    .padding(.trailing, 1) // Prevent edge peeking
                }
                .scrollIndicators(.hidden) // Hide all scroll indicators
                .scrollDisabled(customPlatforms.isEmpty)
            }
            .frame(height: 46)
            .clipShape(Rectangle()) // Hard clip to prevent any peeking
            
            // Three-dot scroll indicator (centered) - only when custom platforms exist
            if !customPlatforms.isEmpty {
                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(theme.textMuted.opacity(0.6))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 4)
                .frame(maxWidth: .infinity) // Center horizontally
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowDark.opacity(0.1), radius: 4, y: 2)
        )
    }
    
    // MARK: - Summary Stats Card
    private var summaryStatsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.textPrimary)
            
            HStack(spacing: 12) {
                StatBox(title: "Revenue", value: "\(currencySymbol)\(String(format: "%.2f", totalRevenue))", color: theme.successColor, theme: theme)
                StatBox(title: "Orders", value: "\(totalOrders)", color: theme.accentColor, theme: theme)
            }
            
            HStack(spacing: 12) {
                StatBox(title: "Items Sold", value: "\(totalQuantity)", color: theme.secondaryColor, theme: theme)
                StatBox(title: "Avg Order", value: "\(currencySymbol)\(String(format: "%.2f", averageOrderValue))", color: theme.warningColor, theme: theme)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowDark.opacity(0.1), radius: 4, y: 2)
        )
    }
    
    // MARK: - Sales by Platform Card
    private var salesByPlatformCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sales by Platform")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.textPrimary)
            
            // Simple bar representation
            ForEach(platformBreakdown.prefix(5), id: \.platform.id) { item in
                HStack {
                    Image(systemName: item.platform.icon)
                        .foregroundColor(item.platform.swiftUIColor)
                        .frame(width: 20)
                    
                    Text(item.platform.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.textSecondary)
                        .frame(width: 70, alignment: .leading)
                    
                    GeometryReader { geo in
                        let maxRevenue = platformBreakdown.first?.revenue ?? 1
                        let width = (item.revenue / maxRevenue) * geo.size.width
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(item.platform.swiftUIColor)
                            .frame(width: max(width, 20), height: 20)
                    }
                    .frame(height: 20)
                    
                    Text("\(currencySymbol)\(String(format: "%.0f", item.revenue))")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(theme.textPrimary)
                        .frame(width: 60, alignment: .trailing)
                }
            }
            
            if platformBreakdown.isEmpty {
                Text("No sales data for this period")
                    .font(.system(size: 12))
                    .foregroundColor(theme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowDark.opacity(0.1), radius: 4, y: 2)
        )
    }
    
    // MARK: - Top Products Card
    private var topProductsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🏆 Top Selling Products")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.textPrimary)
            
            if topProducts.isEmpty {
                Text("No products sold in this period")
                    .font(.system(size: 12))
                    .foregroundColor(theme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(Array(topProducts.enumerated()), id: \.offset) { index, product in
                    HStack {
                        // Rank
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(index == 0 ? .yellow : (index == 1 ? .gray : (index == 2 ? .orange : theme.textMuted)))
                            .frame(width: 24)
                        
                        // Product name
                        Text(product.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(theme.textPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Quantity
                        Text("\(product.quantity) sold")
                            .font(.system(size: 11))
                            .foregroundColor(theme.textMuted)
                        
                        // Revenue
                        Text("\(currencySymbol)\(String(format: "%.0f", product.revenue))")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(theme.successColor)
                            .frame(width: 60, alignment: .trailing)
                    }
                    .padding(.vertical, 4)
                    
                    if index < topProducts.count - 1 {
                        Divider()
                            .background(theme.cardBorder)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowDark.opacity(0.1), radius: 4, y: 2)
        )
    }
    
    // MARK: - Sales Over Time Card
    private var salesOverTimeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sales Over Time")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.textPrimary)
            
            let dailySales = calculateDailySales()
            
            if dailySales.isEmpty {
                Text("No sales data for this period")
                    .font(.system(size: 12))
                    .foregroundColor(theme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                // Simple bar chart
                GeometryReader { geo in
                    let maxSale = dailySales.map { $0.revenue }.max() ?? 1
                    let barWidth = (geo.size.width - CGFloat(dailySales.count - 1) * 4) / CGFloat(min(dailySales.count, 7))
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(dailySales.suffix(7), id: \.date) { day in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(theme.accentColor)
                                    .frame(width: barWidth, height: max((day.revenue / maxSale) * 80, 4))
                                
                                Text(day.date.formatted(.dateTime.weekday(.abbreviated)))
                                    .font(.system(size: 9))
                                    .foregroundColor(theme.textMuted)
                            }
                        }
                    }
                }
                .frame(height: 120)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowDark.opacity(0.1), radius: 4, y: 2)
        )
    }
    
    // MARK: - Custom Date Picker Sheet
    private var customDatePickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker("Start Date", selection: $customStartDate, displayedComponents: .date)
                DatePicker("End Date", selection: $customEndDate, displayedComponents: .date)
            }
            .padding()
            .navigationTitle("Select Date Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showCustomDatePicker = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func calculateDailySales() -> [(date: Date, revenue: Double)] {
        var dailySales: [Date: Double] = [:]
        let calendar = Calendar.current
        
        for order in filteredOrders {
            let day = calendar.startOfDay(for: order.timestamp)
            dailySales[day, default: 0] += order.pricePerUnit * Double(order.quantity)
        }
        
        return dailySales.map { (date: $0.key, revenue: $0.value) }
            .sorted { $0.date < $1.date }
    }
}

// MARK: - Analytics Platform Chip (Same size as home page)
struct AnalyticsPlatformChip: View {
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let width: CGFloat
    let theme: AppTheme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(name)
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(color)
            .frame(width: width, height: 42)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? color.opacity(0.15) : theme.cardBackground.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(theme.textMuted)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}
