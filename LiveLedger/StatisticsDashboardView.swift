//
//  StatisticsDashboardView.swift
//  LiveLedger
//
//  Enhanced statistics dashboard - performance, time-based, and platform metrics.
//

import SwiftUI

// MARK: - Card style constants
private let statCardBackground = Color(hex: "1C1C1E")
private let statCardBorder = Color.white.opacity(0.1)
private let statLabelColor = Color(hex: "8E8E93")
private let statValueFontSize: CGFloat = 24
private let statLabelFontSize: CGFloat = 12
private let statIconSize: CGFloat = 24
private let statCardRadius: CGFloat = 12
private let statCardPadding: CGFloat = 16
private let statGridSpacing: CGFloat = 16

// MARK: - Enhanced Stat Card (reusable)
struct EnhancedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let iconEmoji: String?
    let onTap: (() -> Void)?
    
    init(title: String, value: String, icon: String? = nil, iconEmoji: String? = nil, onTap: (() -> Void)? = nil) {
        self.title = title
        self.value = value
        self.icon = icon ?? "chart.bar.fill"
        self.iconEmoji = iconEmoji
        self.onTap = onTap
    }
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    if let emoji = iconEmoji {
                        Text(emoji)
                            .font(.system(size: statIconSize))
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: statIconSize))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                }
                Text(value)
                    .font(.system(size: statValueFontSize, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.system(size: statLabelFontSize))
                    .foregroundColor(statLabelColor)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(statCardPadding)
            .background(
                RoundedRectangle(cornerRadius: statCardRadius)
                    .fill(statCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: statCardRadius)
                    .strokeBorder(statCardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Statistics Dashboard View
struct StatisticsDashboardView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var localization: LocalizationManager
    @ObservedObject var authManager: AuthManager
    @Binding var showSubscription: Bool
    var currencySymbol: String
    
    @State private var selectedStatDetail: StatDetailType?
    @State private var showNeedProAlert = false
    @State private var refreshId = UUID()
    
    private var isPro: Bool { authManager.currentUser?.isPro ?? false }
    
    enum StatDetailType: Identifiable {
        case averageOrderValue
        case productsSold
        case profitMargin
        case lowStockAlert
        case todaySales
        case weekSales
        case monthSales
        case bestDay
        case topPlatform
        case platformBreakdown
        case unpaidOrders
        case orderSourceBreakdown
        var id: String { "\(self)" }
    }
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    private var columns: [GridItem] {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return Array(repeating: GridItem(.flexible(), spacing: statGridSpacing), count: 4)
        }
        #endif
        return Array(repeating: GridItem(.flexible(), spacing: statGridSpacing), count: 2)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Statistics")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(theme.textPrimary)
            
            LazyVGrid(columns: columns, spacing: statGridSpacing) {
                // Row 2 - Performance
                EnhancedStatCard(
                    title: "Average Order Value",
                    value: viewModel.orderCount > 0 ? "\(currencySymbol)\(String(format: "%.0f", viewModel.averageOrderValue))" : "—",
                    iconEmoji: "💵",
                    onTap: { if isPro { selectedStatDetail = .averageOrderValue } else { showNeedProAlert = true } }
                )
                EnhancedStatCard(
                    title: "Products Sold",
                    value: "\(viewModel.productsSoldQuantity)",
                    iconEmoji: "📊",
                    onTap: { if isPro { selectedStatDetail = .productsSold } else { showNeedProAlert = true } }
                )
                EnhancedStatCard(
                    title: "Profit Margin",
                    value: viewModel.profitMarginPercent != nil ? "\(String(format: "%.0f", viewModel.profitMarginPercent!))%" : "—",
                    iconEmoji: "📈",
                    onTap: { if isPro { selectedStatDetail = .profitMargin } else { showNeedProAlert = true } }
                )
                EnhancedStatCard(
                    title: "Low Stock Alert",
                    value: "\(viewModel.lowStockAlertCount)",
                    iconEmoji: "⚠️",
                    onTap: { if isPro { selectedStatDetail = .lowStockAlert } else { showNeedProAlert = true } }
                )
                // Row 3 - Time-based
                EnhancedStatCard(
                    title: "Today's Sales",
                    value: "\(currencySymbol)\(String(format: "%.0f", viewModel.todaySales))",
                    iconEmoji: "☀️",
                    onTap: { if isPro { selectedStatDetail = .todaySales } else { showNeedProAlert = true } }
                )
                EnhancedStatCard(
                    title: "This Week",
                    value: "\(currencySymbol)\(String(format: "%.0f", viewModel.thisWeekSales))",
                    iconEmoji: "📅",
                    onTap: { if isPro { selectedStatDetail = .weekSales } else { showNeedProAlert = true } }
                )
                EnhancedStatCard(
                    title: "This Month",
                    value: "\(currencySymbol)\(String(format: "%.0f", viewModel.thisMonthSales))",
                    iconEmoji: "🗓️",
                    onTap: { if isPro { selectedStatDetail = .monthSales } else { showNeedProAlert = true } }
                )
                EnhancedStatCard(
                    title: "Best Day",
                    value: bestDayDisplay,
                    iconEmoji: "⭐",
                    onTap: { if isPro { selectedStatDetail = .bestDay } else { showNeedProAlert = true } }
                )
                // Row 4 - Platform
                EnhancedStatCard(
                    title: "Top Platform",
                    value: viewModel.topPlatformName ?? "—",
                    iconEmoji: "📱",
                    onTap: { if isPro { selectedStatDetail = .topPlatform } else { showNeedProAlert = true } }
                )
                EnhancedStatCard(
                    title: "Platform Breakdown",
                    value: platformBreakdownShort,
                    iconEmoji: "📊",
                    onTap: { if isPro { selectedStatDetail = .platformBreakdown } else { showNeedProAlert = true } }
                )
                // Unpaid Orders & Order Sources
                EnhancedStatCard(
                    title: localization.localized(.unpaidOrders),
                    value: "\(viewModel.unpaidOrderCount)",
                    iconEmoji: "🔴",
                    onTap: { if isPro { selectedStatDetail = .unpaidOrders } else { showNeedProAlert = true } }
                )
                EnhancedStatCard(
                    title: localization.localized(.orderSources),
                    value: orderSourceBreakdownShort,
                    iconEmoji: "📲",
                    onTap: { if isPro { selectedStatDetail = .orderSourceBreakdown } else { showNeedProAlert = true } }
                )
            }
        }
        .id(refreshId)
        .sheet(item: $selectedStatDetail) { type in
            StatDetailSheet(type: type, viewModel: viewModel, currencySymbol: currencySymbol)
        }
        .alert("Pro Feature", isPresented: $showNeedProAlert) {
            Button("Upgrade to Pro") { showSubscription = true }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Statistics details require Pro. Upgrade to access.")
        }
    }
    
    private var bestDayDisplay: String {
        guard let best = viewModel.bestDayThisMonth else { return "—" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: best.date))\n\(currencySymbol)\(Int(best.revenue))"
    }
    
    private var platformBreakdownShort: String {
        let items = viewModel.platformBreakdown.prefix(3)
        guard !items.isEmpty else { return "—" }
        return items.map { "\($0.name): \(Int($0.percent))%" }.joined(separator: " | ")
    }
    
    private var orderSourceBreakdownShort: String {
        let items = viewModel.orderSourceBreakdown.prefix(3)
        guard !items.isEmpty else { return "—" }
        return items.map { "\($0.source.shortLabel): \(Int($0.percent))%" }.joined(separator: " | ")
    }
}

// MARK: - Stat Detail Sheet
struct StatDetailSheet: View {
    let type: StatisticsDashboardView.StatDetailType
    @ObservedObject var viewModel: SalesViewModel
    let currencySymbol: String
    @Environment(\.dismiss) var dismiss
    
    private var title: String {
        switch type {
        case .averageOrderValue: return "Average Order Value"
        case .productsSold: return "Products Sold"
        case .profitMargin: return "Profit Margin"
        case .lowStockAlert: return "Low Stock Alert"
        case .todaySales: return "Today's Sales"
        case .weekSales: return "This Week"
        case .monthSales: return "This Month"
        case .bestDay: return "Best Day"
        case .topPlatform: return "Top Platform"
        case .platformBreakdown: return "Platform Breakdown"
        case .unpaidOrders: return "Unpaid Orders"
        case .orderSourceBreakdown: return "Order Sources"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch type {
                    case .averageOrderValue:
                        detailText("Total Sales ÷ Total Orders")
                        detailRow("Total Sales", "\(currencySymbol)\(String(format: "%.2f", viewModel.totalRevenue))")
                        detailRow("Total Orders", "\(viewModel.orderCount)")
                        detailRow("Average", "\(currencySymbol)\(String(format: "%.2f", viewModel.averageOrderValue))")
                    case .productsSold:
                        detailText("Total quantity of all items sold.")
                        detailRow("Items Sold", "\(viewModel.productsSoldQuantity)")
                    case .profitMargin:
                        detailText("(Sales − Costs) ÷ Sales × 100%. Cost tracking is not stored in the app, so margin is not calculated.")
                        if let p = viewModel.profitMarginPercent {
                            detailRow("Margin", "\(String(format: "%.1f", p))%")
                        } else {
                            detailRow("Margin", "—")
                        }
                    case .lowStockAlert:
                        detailText("Products with stock < 10 items.")
                        detailRow("Count", "\(viewModel.lowStockAlertCount)")
                        let low = viewModel.products.filter { !$0.isEmpty && $0.stock < 10 && $0.stock > 0 }
                        ForEach(low, id: \.id) { p in
                            detailRow(p.name, "\(p.stock) left")
                        }
                    case .todaySales:
                        detailText("Revenue from orders placed today.")
                        detailRow("Today's Revenue", "\(currencySymbol)\(String(format: "%.2f", viewModel.todaySales))")
                    case .weekSales:
                        detailText("Revenue from the current week (Monday–Sunday).")
                        detailRow("This Week", "\(currencySymbol)\(String(format: "%.2f", viewModel.thisWeekSales))")
                    case .monthSales:
                        detailText("Revenue from the current month.")
                        detailRow("This Month", "\(currencySymbol)\(String(format: "%.2f", viewModel.thisMonthSales))")
                    case .bestDay:
                        detailText("Highest revenue day this month.")
                        if let best = viewModel.bestDayThisMonth {
                            Group {
                                detailRow("Date", best.date.formatted(date: .long, time: .omitted))
                                detailRow("Revenue", "\(currencySymbol)\(String(format: "%.2f", best.revenue))")
                            }
                        } else {
                            detailRow("—", "No orders this month")
                        }
                    case .topPlatform:
                        detailText("Platform with the most sales (by revenue).")
                        detailRow("Top", viewModel.topPlatformName ?? "—")
                    case .platformBreakdown:
                        detailText("Revenue share by platform.")
                        ForEach(Array(viewModel.platformBreakdown.enumerated()), id: \.offset) { _, item in
                            detailRow(item.name, "\(String(format: "%.0f", item.percent))%")
                        }
                    case .unpaidOrders:
                        detailText("Orders that are not yet marked as paid.")
                        detailRow("Unpaid count", "\(viewModel.unpaidOrderCount)")
                        let unpaid = viewModel.orders.filter { $0.paymentStatus != .paid }
                        if !unpaid.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Recent unpaid orders")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.secondary)
                                ForEach(unpaid.prefix(10)) { order in
                                    detailRow(order.buyerName, "\(order.quantity)× \(order.productName)")
                                }
                                if unpaid.count > 10 {
                                    detailRow("…", "\(unpaid.count - 10) more")
                                }
                            }
                            .padding(.top, 8)
                        }
                    case .orderSourceBreakdown:
                        detailText("Where your orders came from (Live, DMs, etc.).")
                        ForEach(Array(viewModel.orderSourceBreakdown.enumerated()), id: \.offset) { _, item in
                            detailRow(item.source.rawValue, "\(item.count) (\(String(format: "%.0f", item.percent))%)")
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func detailText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    
    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

// Ensure StatDetailType is Identifiable for .sheet(item:)
extension StatisticsDashboardView.StatDetailType: Hashable {}

#Preview {
    StatisticsDashboardView(
        viewModel: SalesViewModel(),
        themeManager: ThemeManager(),
        localization: LocalizationManager.shared,
        authManager: AuthManager(),
        showSubscription: .constant(false),
        currencySymbol: "$"
    )
    .padding()
    .background(Color.black)
}
