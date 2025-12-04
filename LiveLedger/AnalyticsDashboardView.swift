//
//  AnalyticsDashboardView.swift
//  LiveLedger
//
//  LiveLedger - Comprehensive Analytics Dashboard
//

import SwiftUI
import Charts

// MARK: - Analytics Dashboard View
struct AnalyticsDashboardView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var authManager: AuthManager
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab: AnalyticsTab = .overview
    @State private var selectedPeriod: TimePeriod = .week
    @State private var customStartDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var customEndDate = Date()
    @State private var showCustomDatePicker = false
    @State private var selectedPlatforms: Set<UUID> = []
    @State private var selectedProducts: Set<String> = []
    @State private var showPlatformFilter = false
    @State private var showProductFilter = false
    @State private var hoveredPlatform: UUID? = nil
    
    // Comparison
    @State private var showComparison = false
    @State private var compareStartDate1 = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
    @State private var compareEndDate1 = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var compareStartDate2 = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var compareEndDate2 = Date()
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    var currencySymbol: String {
        authManager.currentUser?.currencySymbol ?? "$"
    }
    
    enum AnalyticsTab: String, CaseIterable {
        case overview = "Overview"
        case platforms = "Platforms"
        case products = "Products"
        case trends = "Trends"
        case compare = "Compare"
    }
    
    enum TimePeriod: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
        case custom = "Custom"
    }
    
    // MARK: - Filtered Orders
    private var filteredOrders: [Order] {
        var orders = viewModel.orders.filter { order in
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
                let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: customEndDate) ?? customEndDate
                return order.timestamp >= customStartDate && order.timestamp <= endOfDay
            }
        }
        
        // Platform filter
        if !selectedPlatforms.isEmpty {
            orders = orders.filter { selectedPlatforms.contains($0.platform.id) }
        }
        
        // Product filter
        if !selectedProducts.isEmpty {
            orders = orders.filter { selectedProducts.contains($0.productName) }
        }
        
        return orders
    }
    
    // MARK: - Computed Stats
    private var totalRevenue: Double {
        filteredOrders.reduce(0.0) { $0 + $1.totalPrice }
    }
    
    private var totalOrders: Int { filteredOrders.count }
    
    private var totalQuantity: Int {
        filteredOrders.reduce(0) { $0 + $1.quantity }
    }
    
    private var averageOrderValue: Double {
        totalOrders > 0 ? totalRevenue / Double(totalOrders) : 0
    }
    
    // Platform breakdown
    private var platformBreakdown: [(platform: Platform, revenue: Double, orders: Int, percentage: Double)] {
        var breakdown: [UUID: (platform: Platform, revenue: Double, orders: Int)] = [:]
        
        for order in filteredOrders {
            let platformId = order.platform.id
            if var existing = breakdown[platformId] {
                existing.revenue += order.totalPrice
                existing.orders += 1
                breakdown[platformId] = existing
            } else {
                breakdown[platformId] = (order.platform, order.totalPrice, 1)
            }
        }
        
        let total = totalRevenue
        return breakdown.values.map { item in
            let percentage = total > 0 ? (item.revenue / total) * 100 : 0
            return (platform: item.platform, revenue: item.revenue, orders: item.orders, percentage: percentage)
        }.sorted { $0.revenue > $1.revenue }
    }
    
    // Top products
    private var topProducts: [(name: String, quantity: Int, revenue: Double)] {
        var products: [String: (quantity: Int, revenue: Double)] = [:]
        
        for order in filteredOrders {
            let name = order.productName
            if var existing = products[name] {
                existing.quantity += order.quantity
                existing.revenue += order.totalPrice
                products[name] = existing
            } else {
                products[name] = (order.quantity, order.totalPrice)
            }
        }
        
        return products.map { (name: $0.key, quantity: $0.value.quantity, revenue: $0.value.revenue) }
            .sorted { $0.revenue > $1.revenue }
    }
    
    // Daily sales for chart
    private var dailySales: [(date: Date, revenue: Double, orders: Int)] {
        var daily: [Date: (revenue: Double, orders: Int)] = [:]
        let calendar = Calendar.current
        
        for order in filteredOrders {
            let day = calendar.startOfDay(for: order.timestamp)
            if var existing = daily[day] {
                existing.revenue += order.totalPrice
                existing.orders += 1
                daily[day] = existing
            } else {
                daily[day] = (order.totalPrice, 1)
            }
        }
        
        return daily.map { (date: $0.key, revenue: $0.value.revenue, orders: $0.value.orders) }
            .sorted { $0.date < $1.date }
    }
    
    // Hourly breakdown for today
    private var hourlySales: [(hour: Int, revenue: Double, orders: Int)] {
        var hourly: [Int: (revenue: Double, orders: Int)] = [:]
        let calendar = Calendar.current
        
        let todayOrders = viewModel.orders.filter { calendar.isDateInToday($0.timestamp) }
        
        for order in todayOrders {
            let hour = calendar.component(.hour, from: order.timestamp)
            if var existing = hourly[hour] {
                existing.revenue += order.totalPrice
                existing.orders += 1
                hourly[hour] = existing
            } else {
                hourly[hour] = (order.totalPrice, 1)
            }
        }
        
        return hourly.map { (hour: $0.key, revenue: $0.value.revenue, orders: $0.value.orders) }
            .sorted { $0.hour < $1.hour }
    }
    
    // Best performing hour
    private var bestHour: Int? {
        hourlySales.max { $0.revenue < $1.revenue }?.hour
    }
    
    // Growth rate (compare to previous period)
    private var growthRate: Double {
        let currentRevenue = totalRevenue
        
        // Calculate previous period revenue
        let previousOrders: [Order]
        switch selectedPeriod {
        case .today:
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            previousOrders = viewModel.orders.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: yesterday) }
        case .week:
            let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            previousOrders = viewModel.orders.filter { $0.timestamp >= twoWeeksAgo && $0.timestamp < oneWeekAgo }
        case .month:
            let twoMonthsAgo = Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()
            let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            previousOrders = viewModel.orders.filter { $0.timestamp >= twoMonthsAgo && $0.timestamp < oneMonthAgo }
        case .custom:
            let duration = customEndDate.timeIntervalSince(customStartDate)
            let previousStart = customStartDate.addingTimeInterval(-duration)
            previousOrders = viewModel.orders.filter { $0.timestamp >= previousStart && $0.timestamp < customStartDate }
        }
        
        let previousRevenue = previousOrders.reduce(0.0) { $0 + $1.totalPrice }
        
        guard previousRevenue > 0 else { return currentRevenue > 0 ? 100 : 0 }
        return ((currentRevenue - previousRevenue) / previousRevenue) * 100
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(AnalyticsTab.allCases, id: \.self) { tab in
                            Button {
                                withAnimation { selectedTab = tab }
                            } label: {
                                Text(tab.rawValue)
                                    .font(.system(size: 13, weight: selectedTab == tab ? .bold : .medium))
                                    .foregroundColor(selectedTab == tab ? .white : theme.textSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(selectedTab == tab ? theme.accentColor : theme.cardBackground)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                .background(theme.cardBackground.opacity(0.5))
                
                // Filters Bar
                filtersBar
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case .overview:
                            overviewSection
                        case .platforms:
                            platformsSection
                        case .products:
                            productsSection
                        case .trends:
                            trendsSection
                        case .compare:
                            compareSection
                        }
                    }
                    .padding()
                }
            }
            .background(theme.gradientColors[0].ignoresSafeArea())
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: generateReport()) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showCustomDatePicker) {
                customDatePickerSheet
            }
        }
    }
    
    // MARK: - Filters Bar
    private var filtersBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Time Period
                Menu {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Button {
                            selectedPeriod = period
                            if period == .custom { showCustomDatePicker = true }
                        } label: {
                            HStack {
                                Text(period.rawValue)
                                if selectedPeriod == period {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    FilterChip(
                        icon: "calendar",
                        text: selectedPeriod == .custom ? "Custom" : selectedPeriod.rawValue,
                        isActive: true,
                        color: theme.accentColor
                    )
                }
                
                // Platform Filter
                Button { showPlatformFilter = true } label: {
                    FilterChip(
                        icon: "square.grid.2x2",
                        text: selectedPlatforms.isEmpty ? "All Platforms" : "\(selectedPlatforms.count) Platform(s)",
                        isActive: !selectedPlatforms.isEmpty,
                        color: .purple
                    )
                }
                
                // Product Filter
                Button { showProductFilter = true } label: {
                    FilterChip(
                        icon: "cube.box",
                        text: selectedProducts.isEmpty ? "All Products" : "\(selectedProducts.count) Product(s)",
                        isActive: !selectedProducts.isEmpty,
                        color: .blue
                    )
                }
                
                // Clear Filters
                if !selectedPlatforms.isEmpty || !selectedProducts.isEmpty {
                    Button {
                        selectedPlatforms.removeAll()
                        selectedProducts.removeAll()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                            Text("Clear")
                        }
                        .font(.system(size: 11))
                        .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showPlatformFilter) {
            platformFilterSheet
        }
        .sheet(isPresented: $showProductFilter) {
            productFilterSheet
        }
    }
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        VStack(spacing: 16) {
            // Key Metrics
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MetricCard(
                    title: "Total Revenue",
                    value: "\(currencySymbol)\(String(format: "%.2f", totalRevenue))",
                    icon: "dollarsign.circle.fill",
                    color: .green,
                    trend: growthRate,
                    theme: theme
                )
                
                MetricCard(
                    title: "Total Orders",
                    value: "\(totalOrders)",
                    icon: "bag.fill",
                    color: .blue,
                    theme: theme
                )
                
                MetricCard(
                    title: "Items Sold",
                    value: "\(totalQuantity)",
                    icon: "cube.box.fill",
                    color: .purple,
                    theme: theme
                )
                
                MetricCard(
                    title: "Avg Order",
                    value: "\(currencySymbol)\(String(format: "%.2f", averageOrderValue))",
                    icon: "chart.bar.fill",
                    color: .orange,
                    theme: theme
                )
            }
            
            // Quick Stats
            if let bestHour = bestHour {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.yellow)
                    Text("Best Hour: \(bestHour):00 - \(bestHour + 1):00")
                        .font(.system(size: 12))
                        .foregroundColor(theme.textSecondary)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(theme.cardBackground)
                .cornerRadius(8)
            }
            
            // Mini Pie Chart
            if !platformBreakdown.isEmpty {
                AnalyticsCard(title: "Sales by Platform", theme: theme) {
                    miniPieChart
                }
            }
            
            // Top Products Quick View
            if !topProducts.isEmpty {
                AnalyticsCard(title: "🏆 Top Sellers", theme: theme) {
                    VStack(spacing: 6) {
                        ForEach(Array(topProducts.prefix(5).enumerated()), id: \.offset) { index, product in
                            HStack {
                                Text("\(index + 1)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(index == 0 ? .yellow : (index == 1 ? .gray : .orange))
                                    .frame(width: 20)
                                
                                Text(product.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(theme.textPrimary)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text("\(product.quantity) sold")
                                    .font(.system(size: 10))
                                    .foregroundColor(theme.textMuted)
                                
                                Text("\(currencySymbol)\(String(format: "%.0f", product.revenue))")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Mini Pie Chart
    private var miniPieChart: some View {
        HStack(spacing: 16) {
            // Pie Chart
            ZStack {
                ForEach(Array(platformBreakdown.enumerated()), id: \.element.platform.id) { index, item in
                    let startAngle = calculateStartAngle(for: index)
                    let endAngle = startAngle + Angle(degrees: item.percentage * 3.6)
                    
                    DashboardPieSlice(startAngle: startAngle, endAngle: endAngle)
                        .fill(item.platform.swiftUIColor)
                        .scaleEffect(hoveredPlatform == item.platform.id ? 1.05 : 1.0)
                        .onTapGesture {
                            withAnimation {
                                hoveredPlatform = hoveredPlatform == item.platform.id ? nil : item.platform.id
                            }
                        }
                }
                
                // Center total
                VStack(spacing: 2) {
                    Text("\(currencySymbol)\(String(format: "%.0f", totalRevenue))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.textPrimary)
                    Text("Total")
                        .font(.system(size: 9))
                        .foregroundColor(theme.textMuted)
                }
            }
            .frame(width: 120, height: 120)
            
            // Legend
            VStack(alignment: .leading, spacing: 6) {
                ForEach(platformBreakdown, id: \.platform.id) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.platform.swiftUIColor)
                            .frame(width: 10, height: 10)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.platform.name)
                                .font(.system(size: 11, weight: hoveredPlatform == item.platform.id ? .bold : .medium))
                                .foregroundColor(theme.textPrimary)
                            
                            if hoveredPlatform == item.platform.id {
                                Text("\(currencySymbol)\(String(format: "%.2f", item.revenue))")
                                    .font(.system(size: 10))
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Spacer()
                        
                        Text("\(String(format: "%.1f", item.percentage))%")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(theme.textSecondary)
                    }
                    .padding(.vertical, 2)
                    .background(hoveredPlatform == item.platform.id ? item.platform.swiftUIColor.opacity(0.1) : Color.clear)
                    .cornerRadius(4)
                    .onTapGesture {
                        withAnimation {
                            hoveredPlatform = hoveredPlatform == item.platform.id ? nil : item.platform.id
                        }
                    }
                }
            }
        }
    }
    
    private func calculateStartAngle(for index: Int) -> Angle {
        let preceding = platformBreakdown.prefix(index)
        let sum = preceding.reduce(0.0) { $0 + $1.percentage }
        return Angle(degrees: sum * 3.6 - 90)
    }
    
    // MARK: - Platforms Section
    private var platformsSection: some View {
        VStack(spacing: 16) {
            // Large Pie Chart
            if !platformBreakdown.isEmpty {
                AnalyticsCard(title: "Platform Distribution", theme: theme) {
                    VStack(spacing: 16) {
                        miniPieChart
                        
                        Divider()
                        
                        // Detailed breakdown
                        ForEach(platformBreakdown, id: \.platform.id) { item in
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: item.platform.icon)
                                        .foregroundColor(item.platform.swiftUIColor)
                                    Text(item.platform.name)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(theme.textPrimary)
                                    Spacer()
                                    Text("\(currencySymbol)\(String(format: "%.2f", item.revenue))")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.green)
                                }
                                
                                // Progress bar
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(theme.cardBackground)
                                            .frame(height: 8)
                                        
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(item.platform.swiftUIColor)
                                            .frame(width: geo.size.width * (item.percentage / 100), height: 8)
                                    }
                                }
                                .frame(height: 8)
                                
                                HStack {
                                    Text("\(item.orders) orders")
                                        .font(.system(size: 11))
                                        .foregroundColor(theme.textMuted)
                                    Spacer()
                                    Text("\(String(format: "%.1f", item.percentage))% of sales")
                                        .font(.system(size: 11))
                                        .foregroundColor(theme.textMuted)
                                }
                            }
                            .padding(10)
                            .background(theme.cardBackground.opacity(0.5))
                            .cornerRadius(8)
                        }
                    }
                }
            } else {
                emptyStateView
            }
        }
    }
    
    // MARK: - Products Section
    private var productsSection: some View {
        VStack(spacing: 16) {
            if !topProducts.isEmpty {
                AnalyticsCard(title: "Product Performance", theme: theme) {
                    VStack(spacing: 8) {
                        ForEach(Array(topProducts.enumerated()), id: \.offset) { index, product in
                            HStack {
                                // Rank badge
                                ZStack {
                                    Circle()
                                        .fill(index == 0 ? Color.yellow : (index == 1 ? Color.gray : (index == 2 ? Color.orange : theme.cardBackground)))
                                        .frame(width: 28, height: 28)
                                    Text("\(index + 1)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(index < 3 ? .white : theme.textPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(product.name)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(theme.textPrimary)
                                        .lineLimit(1)
                                    
                                    Text("\(product.quantity) units sold")
                                        .font(.system(size: 10))
                                        .foregroundColor(theme.textMuted)
                                }
                                
                                Spacer()
                                
                                Text("\(currencySymbol)\(String(format: "%.2f", product.revenue))")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            .padding(10)
                            .background(theme.cardBackground.opacity(0.5))
                            .cornerRadius(8)
                        }
                    }
                }
            } else {
                emptyStateView
            }
        }
    }
    
    // MARK: - Trends Section
    private var trendsSection: some View {
        VStack(spacing: 16) {
            // Sales Over Time Bar Chart
            if !dailySales.isEmpty {
                AnalyticsCard(title: "Sales Over Time", theme: theme) {
                    VStack(spacing: 12) {
                        // Bar chart
                        HStack(alignment: .bottom, spacing: 4) {
                            ForEach(dailySales.suffix(14), id: \.date) { day in
                                let maxRevenue = dailySales.map { $0.revenue }.max() ?? 1
                                let height = max((day.revenue / maxRevenue) * 100, 4)
                                
                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(theme.accentColor)
                                        .frame(width: 20, height: height)
                                    
                                    Text(day.date.formatted(.dateTime.day()))
                                        .font(.system(size: 8))
                                        .foregroundColor(theme.textMuted)
                                }
                            }
                        }
                        .frame(height: 130)
                        
                        Divider()
                        
                        // Daily breakdown
                        ForEach(dailySales.suffix(7).reversed(), id: \.date) { day in
                            HStack {
                                Text(day.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 12))
                                    .foregroundColor(theme.textSecondary)
                                
                                Spacer()
                                
                                Text("\(day.orders) orders")
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.textMuted)
                                
                                Text("\(currencySymbol)\(String(format: "%.2f", day.revenue))")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                // Hourly breakdown for today
                if selectedPeriod == .today && !hourlySales.isEmpty {
                    AnalyticsCard(title: "Today by Hour", theme: theme) {
                        VStack(spacing: 8) {
                            ForEach(hourlySales, id: \.hour) { hourData in
                                HStack {
                                    Text("\(hourData.hour):00")
                                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                                        .foregroundColor(theme.textSecondary)
                                        .frame(width: 40, alignment: .leading)
                                    
                                    GeometryReader { geo in
                                        let maxRevenue = hourlySales.map { $0.revenue }.max() ?? 1
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(hourData.hour == bestHour ? Color.yellow : theme.accentColor)
                                            .frame(width: geo.size.width * (hourData.revenue / maxRevenue))
                                    }
                                    .frame(height: 16)
                                    
                                    Text("\(currencySymbol)\(String(format: "%.0f", hourData.revenue))")
                                        .font(.system(size: 10))
                                        .foregroundColor(theme.textMuted)
                                        .frame(width: 50, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
            } else {
                emptyStateView
            }
        }
    }
    
    // MARK: - Compare Section
    private var compareSection: some View {
        VStack(spacing: 16) {
            AnalyticsCard(title: "Period Comparison", theme: theme) {
                // Calculate stats for both periods
                let period1Orders = viewModel.orders.filter { $0.timestamp >= compareStartDate1 && $0.timestamp <= compareEndDate1 }
                let period2Orders = viewModel.orders.filter { $0.timestamp >= compareStartDate2 && $0.timestamp <= compareEndDate2 }
                let period1Revenue = period1Orders.reduce(0.0) { $0 + $1.totalPrice }
                let period2Revenue = period2Orders.reduce(0.0) { $0 + $1.totalPrice }
                let period1Items = period1Orders.reduce(0) { $0 + $1.quantity }
                let period2Items = period2Orders.reduce(0) { $0 + $1.quantity }
                let period1Avg = period1Orders.count > 0 ? period1Revenue / Double(period1Orders.count) : 0
                let period2Avg = period2Orders.count > 0 ? period2Revenue / Double(period2Orders.count) : 0
                
                VStack(spacing: 16) {
                    // PERIOD 1 - Date picker and stats together
                    VStack(spacing: 12) {
                        // Header with date range
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Period 1")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(theme.accentColor)
                            
                            HStack {
                                DatePicker("", selection: $compareStartDate1, displayedComponents: .date)
                                    .labelsHidden()
                                Text("to")
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.textMuted)
                                DatePicker("", selection: $compareEndDate1, displayedComponents: .date)
                                    .labelsHidden()
                            }
                            .font(.system(size: 12))
                        }
                        
                        // Period 1 Stats
                        HStack(spacing: 12) {
                            // Total Sales
                            VStack(spacing: 4) {
                                Text("Total Sales")
                                    .font(.system(size: 9))
                                    .foregroundColor(theme.textMuted)
                                Text("\(currencySymbol)\(formatCompact(period1Revenue))")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(theme.accentColor)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider().frame(height: 30)
                            
                            // Orders
                            VStack(spacing: 4) {
                                Text("Orders")
                                    .font(.system(size: 9))
                                    .foregroundColor(theme.textMuted)
                                Text("\(period1Orders.count)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(theme.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider().frame(height: 30)
                            
                            // Items Sold
                            VStack(spacing: 4) {
                                Text("Items")
                                    .font(.system(size: 9))
                                    .foregroundColor(theme.textMuted)
                                Text("\(period1Items)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(theme.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider().frame(height: 30)
                            
                            // Avg Order
                            VStack(spacing: 4) {
                                Text("Avg Order")
                                    .font(.system(size: 9))
                                    .foregroundColor(theme.textMuted)
                                Text("\(currencySymbol)\(formatCompact(period1Avg))")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(theme.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(12)
                        .background(theme.accentColor.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Divider between periods
                    HStack {
                        Rectangle()
                            .fill(theme.textMuted.opacity(0.3))
                            .frame(height: 1)
                        Text("vs")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(theme.textMuted)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(theme.textMuted.opacity(0.3))
                            .frame(height: 1)
                    }
                    
                    // PERIOD 2 - Date picker and stats together
                    VStack(spacing: 12) {
                        // Header with date range
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Period 2")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.orange)
                            
                            HStack {
                                DatePicker("", selection: $compareStartDate2, displayedComponents: .date)
                                    .labelsHidden()
                                Text("to")
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.textMuted)
                                DatePicker("", selection: $compareEndDate2, displayedComponents: .date)
                                    .labelsHidden()
                            }
                            .font(.system(size: 12))
                        }
                        
                        // Period 2 Stats
                        HStack(spacing: 12) {
                            // Total Sales
                            VStack(spacing: 4) {
                                Text("Total Sales")
                                    .font(.system(size: 9))
                                    .foregroundColor(theme.textMuted)
                                Text("\(currencySymbol)\(formatCompact(period2Revenue))")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider().frame(height: 30)
                            
                            // Orders
                            VStack(spacing: 4) {
                                Text("Orders")
                                    .font(.system(size: 9))
                                    .foregroundColor(theme.textMuted)
                                Text("\(period2Orders.count)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(theme.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider().frame(height: 30)
                            
                            // Items Sold
                            VStack(spacing: 4) {
                                Text("Items")
                                    .font(.system(size: 9))
                                    .foregroundColor(theme.textMuted)
                                Text("\(period2Items)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(theme.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider().frame(height: 30)
                            
                            // Avg Order
                            VStack(spacing: 4) {
                                Text("Avg Order")
                                    .font(.system(size: 9))
                                    .foregroundColor(theme.textMuted)
                                Text("\(currencySymbol)\(formatCompact(period2Avg))")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(theme.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // DIFFERENCE Summary
                    let revenueDiff = period2Revenue - period1Revenue
                    let ordersDiff = period2Orders.count - period1Orders.count
                    let itemsDiff = period2Items - period1Items
                    let revenuePercent = period1Revenue > 0 ? (revenueDiff / period1Revenue) * 100 : 0
                    
                    VStack(spacing: 10) {
                        Text("Change from Period 1 to Period 2")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(theme.textMuted)
                        
                        HStack(spacing: 16) {
                            // Revenue Change
                            VStack(spacing: 2) {
                                HStack(spacing: 4) {
                                    Image(systemName: revenueDiff >= 0 ? "arrow.up.right" : "arrow.down.right")
                                        .font(.system(size: 10))
                                    Text(revenueDiff >= 0 ? "+\(currencySymbol)\(formatCompact(revenueDiff))" : "-\(currencySymbol)\(formatCompact(abs(revenueDiff)))")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .foregroundColor(revenueDiff >= 0 ? .green : .red)
                                Text("Revenue (\(String(format: "%+.1f", revenuePercent))%)")
                                    .font(.system(size: 8))
                                    .foregroundColor(theme.textMuted)
                            }
                            
                            // Orders Change
                            VStack(spacing: 2) {
                                HStack(spacing: 4) {
                                    Image(systemName: ordersDiff >= 0 ? "arrow.up.right" : "arrow.down.right")
                                        .font(.system(size: 10))
                                    Text(ordersDiff >= 0 ? "+\(ordersDiff)" : "\(ordersDiff)")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .foregroundColor(ordersDiff >= 0 ? .green : .red)
                                Text("Orders")
                                    .font(.system(size: 8))
                                    .foregroundColor(theme.textMuted)
                            }
                            
                            // Items Change
                            VStack(spacing: 2) {
                                HStack(spacing: 4) {
                                    Image(systemName: itemsDiff >= 0 ? "arrow.up.right" : "arrow.down.right")
                                        .font(.system(size: 10))
                                    Text(itemsDiff >= 0 ? "+\(itemsDiff)" : "\(itemsDiff)")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .foregroundColor(itemsDiff >= 0 ? .green : .red)
                                Text("Items")
                                    .font(.system(size: 8))
                                    .foregroundColor(theme.textMuted)
                            }
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(theme.cardBackground)
                    .cornerRadius(10)
                }
            }
        }
    }
    
    // Helper function to format numbers compactly
    private func formatCompact(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.1fK", value / 1_000)
        } else {
            return String(format: "%.0f", value)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(theme.textMuted.opacity(0.4))
            
            Text("No data for selected period")
                .font(.system(size: 14))
                .foregroundColor(theme.textMuted)
            
            Text("Try adjusting your filters or date range")
                .font(.system(size: 12))
                .foregroundColor(theme.textMuted.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(theme.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Custom Date Picker Sheet
    private var customDatePickerSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker("Start Date", selection: $customStartDate, displayedComponents: .date)
                DatePicker("End Date", selection: $customEndDate, displayedComponents: .date)
            }
            .padding()
            .navigationTitle("Select Date Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showCustomDatePicker = false }
                }
            }
        }
        .presentationDetents([.height(250)])
    }
    
    // MARK: - Platform Filter Sheet
    private var platformFilterSheet: some View {
        NavigationStack {
            List {
                Button {
                    selectedPlatforms.removeAll()
                } label: {
                    HStack {
                        Text("All Platforms")
                        Spacer()
                        if selectedPlatforms.isEmpty {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                ForEach(viewModel.platforms) { platform in
                    Button {
                        if selectedPlatforms.contains(platform.id) {
                            selectedPlatforms.remove(platform.id)
                        } else {
                            selectedPlatforms.insert(platform.id)
                        }
                    } label: {
                        HStack {
                            Image(systemName: platform.icon)
                                .foregroundColor(platform.swiftUIColor)
                            Text(platform.name)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedPlatforms.contains(platform.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Platforms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showPlatformFilter = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Product Filter Sheet
    private var productFilterSheet: some View {
        NavigationStack {
            List {
                Button {
                    selectedProducts.removeAll()
                } label: {
                    HStack {
                        Text("All Products")
                        Spacer()
                        if selectedProducts.isEmpty {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                let productNames = Set(viewModel.orders.map { $0.productName })
                ForEach(Array(productNames).sorted(), id: \.self) { product in
                    Button {
                        if selectedProducts.contains(product) {
                            selectedProducts.remove(product)
                        } else {
                            selectedProducts.insert(product)
                        }
                    } label: {
                        HStack {
                            Text(product)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedProducts.contains(product) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showProductFilter = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Generate Report
    private func generateReport() -> String {
        var report = """
        LiveLedger Analytics Report
        Generated: \(Date().formatted())
        Period: \(selectedPeriod.rawValue)
        ================================
        
        SUMMARY
        Total Revenue: \(currencySymbol)\(String(format: "%.2f", totalRevenue))
        Total Orders: \(totalOrders)
        Items Sold: \(totalQuantity)
        Average Order: \(currencySymbol)\(String(format: "%.2f", averageOrderValue))
        Growth: \(String(format: "%.1f", growthRate))%
        
        PLATFORM BREAKDOWN
        """
        
        for item in platformBreakdown {
            report += "\n\(item.platform.name): \(currencySymbol)\(String(format: "%.2f", item.revenue)) (\(String(format: "%.1f", item.percentage))%)"
        }
        
        report += "\n\nTOP PRODUCTS"
        for (index, product) in topProducts.prefix(10).enumerated() {
            report += "\n\(index + 1). \(product.name): \(product.quantity) sold - \(currencySymbol)\(String(format: "%.2f", product.revenue))"
        }
        
        return report
    }
}

// MARK: - Supporting Views

struct FilterChip: View {
    let icon: String
    let text: String
    let isActive: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(isActive ? .white : .primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isActive ? color : Color(.systemGray5))
        .cornerRadius(16)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var trend: Double? = nil
    let theme: AppTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Spacer()
                
                if let trend = trend {
                    HStack(spacing: 2) {
                        Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10))
                        Text("\(String(format: "%.1f", abs(trend)))%")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(trend >= 0 ? .green : .red)
                }
            }
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(theme.textMuted)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.cardBackground)
        .cornerRadius(12)
    }
}

struct AnalyticsCard<Content: View>: View {
    let title: String
    let theme: AppTheme
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.textPrimary)
            
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.cardBackground)
        .cornerRadius(12)
    }
}

struct DashboardPieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 * 0.8
        let innerRadius = radius * 0.5
        
        path.move(to: CGPoint(
            x: center.x + innerRadius * cos(CGFloat(startAngle.radians)),
            y: center.y + innerRadius * sin(CGFloat(startAngle.radians))
        ))
        
        path.addLine(to: CGPoint(
            x: center.x + radius * cos(CGFloat(startAngle.radians)),
            y: center.y + radius * sin(CGFloat(startAngle.radians))
        ))
        
        path.addArc(center: center, radius: radius,
                    startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        path.addLine(to: CGPoint(
            x: center.x + innerRadius * cos(CGFloat(endAngle.radians)),
            y: center.y + innerRadius * sin(CGFloat(endAngle.radians))
        ))
        
        path.addArc(center: center, radius: innerRadius,
                    startAngle: endAngle, endAngle: startAngle, clockwise: true)
        
        path.closeSubpath()
        return path
    }
}

#Preview {
    AnalyticsDashboardView(
        viewModel: SalesViewModel(),
        authManager: AuthManager(),
        themeManager: ThemeManager()
    )
}

