//
//  HeaderView.swift
//  LiveLedger
//
//  LiveLedger - Header with Stats and Actions
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @Binding var showSettings: Bool
    @Binding var showSubscription: Bool
    @State private var showPrintOptions = false
    @State private var showExportOptions = false
    @State private var showClearOptions = false
    @State private var showAnalytics = false
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    var currencySymbol: String {
        authManager.currentUser?.currencySymbol ?? "$"
    }
    
    // Top selling product name
    var topSellerName: String {
        let productCounts = Dictionary(grouping: viewModel.filteredOrders, by: { $0.productName })
            .mapValues { $0.reduce(0) { $0 + $1.quantity } }
        if let topProduct = productCounts.max(by: { $0.value < $1.value }) {
            return topProduct.key
        }
        return "—"
    }
    
    // Total remaining stock across all products
    var totalStockLeft: Int {
        viewModel.products.reduce(0) { $0 + $1.stock }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Title Row - COMPACT
            HStack {
                // LiveLedger logo - always shows app branding
                LiveLedgerLogoMini()
                
                VStack(alignment: .leading, spacing: 1) {
                    // App name - LiveLedger branding
                    Text("LiveLedger")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(theme.textPrimary)
                        .lineLimit(1)
                    
                    // Seller's account info (smaller, secondary)
                    if let user = authManager.currentUser {
                        HStack(spacing: 4) {
                            Text("Account:")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(theme.textMuted)
                            
                            Text(user.companyName)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(theme.textSecondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                // Right side - PRO badge + Auto-save indicator
                VStack(alignment: .trailing, spacing: 3) {
                    // PRO/FREE badge
                    if let user = authManager.currentUser {
                        if user.isPro {
                            HStack(spacing: 3) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(theme.warningColor)
                                Text("PRO")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(theme.warningColor)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(theme.warningColor.opacity(0.15))
                            )
                        } else {
                            Text("FREE")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(theme.textMuted)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(theme.textMuted.opacity(0.15))
                                )
                        }
                    }
                    
                    // Auto-save indicator
                    HStack(spacing: 3) {
                        Circle()
                            .fill(theme.successColor)
                            .frame(width: 6, height: 6)
                        Text(localization.localized(.autoSaving))
                            .font(.system(size: 9))
                            .foregroundColor(theme.textSecondary)
                    }
                }
                
                // Menu Button (replaces Settings)
                Menu {
                    // Analytics Option
                    Button {
                        showAnalytics = true
                    } label: {
                        Label("Analytics", systemImage: "chart.bar.fill")
                    }
                    
                    // Settings Option
                    Button {
                        showSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(theme.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.4))
                        )
                }
            }
            
            // Stats Row - Full width, edges align with container edges
            // Left: Total Sales (left edge aligns with container left)
            // Right: Total Orders (right edge aligns with container right)
            HStack(spacing: 6) {
                StatCard(title: localization.localized(.totalSales), amount: viewModel.totalRevenue, color: theme.successColor, icon: "dollarsign.circle.fill", symbol: currencySymbol, theme: theme)
                StatCardText(title: "Top Seller", text: topSellerName, color: theme.warningColor, icon: "flame.fill", theme: theme)
                StatCard(title: "Stock Left", amount: Double(totalStockLeft), color: theme.accentColor, icon: "shippingbox.fill", symbol: "", isCount: true, theme: theme)
                StatCard(title: "Total Orders", amount: Double(viewModel.orderCount), color: theme.secondaryColor, icon: "bag.fill", symbol: "", isCount: true, theme: theme)
            }
            .frame(maxWidth: .infinity) // Span full container width
            
            // Action Buttons Row - Full width, edges align with container edges
            // Left: Clear (left edge aligns with container left)
            // Right: Print (right edge aligns with container right)
            HStack(spacing: 0) {
                ActionButton(title: localization.localized(.clear), icon: "trash", color: theme.dangerColor, theme: theme) {
                    showClearOptions = true
                }
                
                Spacer()
                
                ActionButton(title: localization.localized(.export), icon: "square.and.arrow.up", color: theme.accentColor, theme: theme) {
                    showExportOptions = true
                }
                
                Spacer()
                
                ActionButton(title: localization.localized(.print), icon: "printer.fill", color: theme.secondaryColor, theme: theme) {
                    showPrintOptions = true
                }
            }
            .frame(maxWidth: .infinity) // Span full container width
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(theme.cardBorder, lineWidth: 1)
                )
        )
        .sheet(isPresented: $showPrintOptions) {
            PrintOptionsView(viewModel: viewModel, authManager: authManager, platforms: viewModel.platforms)
        }
        .sheet(isPresented: $showExportOptions) {
            ExportOptionsView(viewModel: viewModel, platforms: viewModel.platforms)
        }
        .sheet(isPresented: $showClearOptions) {
            ClearOptionsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showAnalytics) {
            NavigationStack {
                AnalyticsView(localization: localization)
            }
        }
    }
}

// MARK: - Clear Options View
struct ClearOptionsView: View {
    @ObservedObject var viewModel: SalesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var clearCustomPlatforms = false
    @State private var clearProducts = false
    @State private var clearOrders = false
    @State private var showConfirmation = false
    
    var hasCustomPlatforms: Bool {
        viewModel.platforms.contains { $0.isCustom }
    }
    
    var hasProducts: Bool {
        viewModel.products.contains { !$0.isEmpty }
    }
    
    var hasOrders: Bool {
        !viewModel.orders.isEmpty
    }
    
    var selectedCount: Int {
        [clearCustomPlatforms, clearProducts, clearOrders].filter { $0 }.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Options List
                VStack(spacing: 12) {
                    // Clear Custom Platforms
                    ClearOptionRow(
                        title: "Clear Custom Platforms",
                        subtitle: hasCustomPlatforms ? "\(viewModel.platforms.filter { $0.isCustom }.count) custom platforms" : "No custom platforms",
                        icon: "star.fill",
                        color: .orange,
                        isSelected: $clearCustomPlatforms,
                        isEnabled: hasCustomPlatforms
                    )
                    
                    // Clear Products
                    ClearOptionRow(
                        title: "Clear My Products",
                        subtitle: hasProducts ? "\(viewModel.products.filter { !$0.isEmpty }.count) products configured" : "No products configured",
                        icon: "cube.box.fill",
                        color: .blue,
                        isSelected: $clearProducts,
                        isEnabled: hasProducts
                    )
                    
                    // Clear Orders
                    ClearOptionRow(
                        title: "Clear Orders",
                        subtitle: hasOrders ? "\(viewModel.orders.count) orders" : "No orders",
                        icon: "bag.fill",
                        color: .green,
                        isSelected: $clearOrders,
                        isEnabled: hasOrders
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Clear All shortcut
                Button {
                    if hasCustomPlatforms { clearCustomPlatforms = true }
                    if hasProducts { clearProducts = true }
                    if hasOrders { clearOrders = true }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Select All")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                }
                .disabled(!hasCustomPlatforms && !hasProducts && !hasOrders)
                
                Spacer()
                
                // Clear Button
                Button {
                    showConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Clear Selected (\(selectedCount))")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(selectedCount > 0 ? Color.red : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(selectedCount == 0)
            }
            .padding()
            .navigationTitle("Clear Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Confirm Clear", isPresented: $showConfirmation) {
                Button("Clear", role: .destructive) {
                    performClear()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete the selected data. This cannot be undone.")
            }
        }
    }
    
    func performClear() {
        if clearCustomPlatforms {
            viewModel.platforms.removeAll { $0.isCustom }
        }
        if clearProducts {
            // Reset to empty products
            if let id = viewModel.selectedCatalogId ?? viewModel.catalogs.first?.id,
               let index = viewModel.catalogs.firstIndex(where: { $0.id == id }) {
                viewModel.catalogs[index].products = [Product(), Product(), Product(), Product()]
            }
        }
        if clearOrders {
            viewModel.orders.removeAll()
        }
        viewModel.saveData()
    }
}

struct ClearOptionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @Binding var isSelected: Bool
    let isEnabled: Bool
    
    var body: some View {
        Button {
            if isEnabled {
                isSelected.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isEnabled ? color : .gray)
                    .frame(width: 32)
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(isEnabled ? .primary : .gray)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? color : .gray.opacity(0.4))
            }
            .padding(.vertical, 8)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

// Export Options View - select platforms to export
struct ExportOptionsView: View {
    @ObservedObject var viewModel: SalesViewModel
    let platforms: [Platform]
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPlatforms: Set<UUID> = []
    @State private var selectAll = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Select All toggle
                HStack {
                    Button {
                        if selectAll {
                            selectedPlatforms.removeAll()
                            selectAll = false
                        } else {
                            selectedPlatforms = Set(platforms.map { $0.id })
                            selectAll = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: selectAll ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22))
                                .foregroundColor(selectAll ? .green : .gray)
                            Text("All Platforms")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                    Spacer()
                    Text("\(ordersForSelectedPlatforms.count) orders")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Platform list
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(platforms) { platform in
                            let isSelected = selectedPlatforms.contains(platform.id) || selectAll
                            let orderCount = viewModel.orders.filter { $0.platform.id == platform.id }.count
                            
                            Button {
                                selectAll = false
                                if selectedPlatforms.contains(platform.id) {
                                    selectedPlatforms.remove(platform.id)
                                } else {
                                    selectedPlatforms.insert(platform.id)
                                }
                                // Check if all are selected
                                if selectedPlatforms.count == platforms.count {
                                    selectAll = true
                                }
                            } label: {
                                HStack {
                                    // Platform color bar
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(platform.swiftUIColor)
                                        .frame(width: 4, height: 30)
                                    
                                    // Platform icon & name
                                    Image(systemName: platform.icon)
                                        .font(.system(size: 16))
                                        .foregroundColor(platform.swiftUIColor)
                                        .frame(width: 24)
                                    
                                    Text(platform.name)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    // Order count
                                    Text("\(orderCount)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(6)
                                    
                                    // Checkbox
                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(isSelected ? platform.swiftUIColor : .gray.opacity(0.4))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6).opacity(isSelected ? 0.8 : 0.4))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Export button
                Button {
                    exportSelectedPlatforms()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export \(ordersForSelectedPlatforms.count) Orders")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(ordersForSelectedPlatforms.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(12)
                }
                .disabled(ordersForSelectedPlatforms.isEmpty)
            }
            .padding()
            .navigationTitle("Export Orders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                // Start with all selected
                selectedPlatforms = Set(platforms.map { $0.id })
            }
        }
    }
    
    // Get orders for selected platforms
    var ordersForSelectedPlatforms: [Order] {
        if selectAll {
            return viewModel.orders
        }
        return viewModel.orders.filter { selectedPlatforms.contains($0.platform.id) }
    }
    
    // Export function
    func exportSelectedPlatforms() {
        let ordersToExport = ordersForSelectedPlatforms
        var csv = "Order ID,Product,Buyer,Phone,Address,Platform,Quantity,Unit Price,Total,Payment Status,Timestamp\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for order in ordersToExport {
            let buyerDisplay = order.buyerName.hasPrefix("SN-") 
                ? String(order.buyerName.dropFirst(3))
                : order.buyerName
            
            let row = [
                order.id.uuidString,
                order.productName.replacingOccurrences(of: ",", with: ";"),
                buyerDisplay.replacingOccurrences(of: ",", with: ";"),
                order.phoneNumber.replacingOccurrences(of: ",", with: ";"),
                order.address.replacingOccurrences(of: ",", with: ";"),
                order.platform.name,
                String(order.quantity),
                String(format: "%.2f", order.pricePerUnit),
                String(format: "%.2f", order.totalPrice),
                order.paymentStatus.rawValue,
                dateFormatter.string(from: order.timestamp)
            ].joined(separator: ",")
            csv += row + "\n"
        }
        
        // Generate filename with platform info
        let platformNames = selectAll ? "All" : selectedPlatforms.compactMap { id in
            platforms.first { $0.id == id }?.name
        }.joined(separator: "_")
        
        let fileDateFormatter = DateFormatter()
        fileDateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let filename = "LiveLedger_\(platformNames)_\(fileDateFormatter.string(from: Date())).csv"
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
            viewModel.csvURL = tempURL
            viewModel.showingExportSheet = true
        } catch {
            print("Failed to export CSV: \(error)")
        }
    }
}

struct StatCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    var symbol: String = "$"
    var isCount: Bool = false
    var theme: AppTheme = .minimalistDark
    
    // Format large amounts to prevent overflow
    private var formattedAmount: String {
        if isCount {
            if amount >= 1_000_000 {
                return String(format: "%.1fM", amount / 1_000_000)
            } else if amount >= 100_000 {
                return String(format: "%.0fK", amount / 1_000)
            } else {
                return "\(Int(amount))"
            }
        } else {
            if amount >= 1_000_000 {
                return "\(symbol)\(String(format: "%.1fM", amount / 1_000_000))"
            } else if amount >= 100_000 {
                return "\(symbol)\(String(format: "%.0fK", amount / 1_000))"
            } else {
                return "\(symbol)\(String(format: "%.0f", amount))"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(color)
            
            // Amount - abbreviated for large numbers
            Text(formattedAmount)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(theme.textSecondary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(theme.cardBorder, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(formattedAmount)")
    }
}

// StatCard for text (like Top Seller product name)
struct StatCardText: View {
    let title: String
    let text: String
    let color: Color
    let icon: String
    var theme: AppTheme = .minimalistDark
    
    var body: some View {
        VStack(spacing: 2) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(color)
            
            // Text value - SAME SIZE as StatCard amount (14pt)
            Text(text)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(theme.textSecondary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(theme.cardBorder, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(text)")
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    var theme: AppTheme = .minimalistDark
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            action()
        }) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(
                ZStack {
                    // Base neumorphic shape
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                    
                    // Inner highlight (top-left)
                    if !isPressed {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            )
            .shadow(color: isPressed ? Color.clear : theme.shadowDark.opacity(0.3), radius: 4, x: 3, y: 3)
            .shadow(color: isPressed ? Color.clear : theme.shadowLight.opacity(0.1), radius: 4, x: -2, y: -2)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .accessibilityLabel("\(title) button")
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Print Options View
struct PrintOptionsView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var authManager: AuthManager
    let platforms: [Platform]
    @Environment(\.dismiss) var dismiss
    @State private var showingDailyReport = false
    @State private var showingAllReceipts = false
    @State private var selectedPrintPlatforms: Set<UUID> = []
    @State private var printAllPlatforms = true
    
    var currencySymbol: String {
        authManager.currentUser?.currencySymbol ?? "$"
    }
    
    var ordersForPrint: [Order] {
        if printAllPlatforms {
            return viewModel.orders
        }
        return viewModel.orders.filter { selectedPrintPlatforms.contains($0.platform.id) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Platform Filter Section
                Section {
                    // All Platforms toggle
                    Button {
                        printAllPlatforms.toggle()
                        if printAllPlatforms {
                            selectedPrintPlatforms.removeAll()
                        }
                    } label: {
                        HStack {
                            Image(systemName: printAllPlatforms ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(printAllPlatforms ? .green : .gray)
                            Text("All Platforms")
                            Spacer()
                            Text("\(viewModel.orders.count) orders")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Individual platforms
                    ForEach(platforms) { platform in
                        let platformOrders = viewModel.orders.filter { $0.platform.id == platform.id }
                        let isSelected = selectedPrintPlatforms.contains(platform.id)
                        
                        Button {
                            printAllPlatforms = false
                            if isSelected {
                                selectedPrintPlatforms.remove(platform.id)
                            } else {
                                selectedPrintPlatforms.insert(platform.id)
                            }
                        } label: {
                            HStack {
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(isSelected ? platform.swiftUIColor : .gray)
                                Image(systemName: platform.icon)
                                    .foregroundColor(platform.swiftUIColor)
                                Text(platform.name)
                                Spacer()
                                Text("\(platformOrders.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Filter by Platform")
                }
                
                Section {
                    Button {
                        showingDailyReport = true
                    } label: {
                        Label("Print Sales Report", systemImage: "doc.text.fill")
                    }
                    .disabled(ordersForPrint.isEmpty)
                    
                    Button {
                        showingAllReceipts = true
                    } label: {
                        Label("Print All Receipts (\(ordersForPrint.count))", systemImage: "doc.on.doc.fill")
                    }
                    .disabled(ordersForPrint.isEmpty)
                } header: {
                    Text("Print Options")
                } footer: {
                    Text("Sales Report: Summary with all orders\nAll Receipts: Individual POS receipts for each order")
                }
                
                Section {
                    Text("Tap any order in the list, then tap 'Print Receipt' to print an individual POS-style receipt")
                        .font(.caption)
                        .foregroundColor(.gray)
                } header: {
                    Text("Individual Receipts")
                }
            }
            .navigationTitle("Print Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showingDailyReport) {
                DailyOrderReportView(
                    orders: ordersForPrint,
                    currencySymbol: currencySymbol,
                    companyName: authManager.currentUser?.companyName ?? "Live Sales"
                )
            }
            .sheet(isPresented: $showingAllReceipts) {
                AllReceiptsView(orders: ordersForPrint)
            }
            .onAppear {
                selectedPrintPlatforms = Set(platforms.map { $0.id })
            }
        }
    }
}

// MARK: - All Receipts View
struct AllReceiptsView: View {
    let orders: [Order]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(orders) { order in
                        ReceiptCard(order: order)
                    }
                }
                .padding()
            }
            .background(Color.gray.opacity(0.2))
            .navigationTitle("All Receipts (\(orders.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    ShareLink(item: generateAllReceiptsText()) {
                        Label("Share All", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    func generateAllReceiptsText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        
        var text = "ALL RECEIPTS (\(orders.count) orders)\n"
        text += "Generated: \(dateFormatter.string(from: Date()))\n"
        text += "================================\n\n"
        
        for (index, order) in orders.enumerated() {
            text += "RECEIPT #\(index + 1)\n"
            text += "Order #\(order.id.uuidString.prefix(8).uppercased())\n"
            text += "\(order.productName)\n"
            text += "\(order.quantity) x $\(String(format: "%.2f", order.pricePerUnit)) = $\(String(format: "%.2f", order.totalPrice))\n"
            text += "Buyer: \(order.buyerName)\n"
            text += "Platform: \(order.platform.name)\n"
            text += "Status: \(order.paymentStatus.rawValue)\n"
            text += "--------------------------------\n\n"
        }
        
        let total = orders.reduce(0) { $0 + $1.totalPrice }
        text += "GRAND TOTAL: $\(String(format: "%.2f", total))\n"
        
        return text
    }
}

struct ReceiptCard: View {
    let order: Order
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd hh:mm a"
        return f
    }()
    
    var body: some View {
        VStack(spacing: 6) {
            Text("RECEIPT")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
            Text(dateFormatter.string(from: order.timestamp))
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.gray)
            
            Divider()
            
            Text(order.productName)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
            
            HStack {
                Text("\(order.quantity) x $\(order.pricePerUnit, specifier: "%.2f")")
                    .font(.system(size: 10, design: .monospaced))
                Spacer()
                Text("$\(order.totalPrice, specifier: "%.2f")")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
            }
            
            Divider()
            
            HStack {
                Text(order.buyerName)
                Spacer()
                Text(order.platform.name)
            }
            .font(.system(size: 9, design: .monospaced))
            .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(4)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

// MARK: - Daily Order Report View
struct DailyOrderReportView: View {
    let orders: [Order]
    let currencySymbol: String
    let companyName: String
    @Environment(\.dismiss) var dismiss
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        return f
    }()
    
    var totalRevenue: Double {
        orders.reduce(0) { $0 + $1.totalPrice }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Text(companyName)
                            .font(.title2.bold())
                        Text("Daily Sales Report")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(dateFormatter.string(from: Date()))
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Divider()
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Summary
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total Orders: \(orders.count)")
                            Text("Total Items: \(orders.reduce(0) { $0 + $1.quantity })")
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Total Sales: \(currencySymbol)\(totalRevenue, specifier: "%.2f")")
                                .fontWeight(.bold)
                        }
                    }
                    .font(.subheadline)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    Divider()
                    
                    // Orders Table Header
                    HStack {
                        Text("#").frame(width: 25, alignment: .leading)
                        Text("Product").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Qty").frame(width: 30)
                        Text("Price").frame(width: 50, alignment: .trailing)
                        Text("Total").frame(width: 55, alignment: .trailing)
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                    
                    // Orders
                    ForEach(Array(orders.enumerated()), id: \.element.id) { index, order in
                        VStack(alignment: .leading, spacing: 4) {
                            // Main row
                            HStack {
                                Text("\(index + 1)").frame(width: 25, alignment: .leading)
                                Text(order.productName).frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(order.quantity)").frame(width: 30)
                                Text("\(currencySymbol)\(order.pricePerUnit, specifier: "%.0f")").frame(width: 50, alignment: .trailing)
                                Text("\(currencySymbol)\(order.totalPrice, specifier: "%.0f")").frame(width: 55, alignment: .trailing)
                            }
                            .font(.system(size: 11))
                            
                            // Buyer details
                            VStack(alignment: .leading, spacing: 2) {
                                // Convert "SN-1" to "#1" for print
                                Text("Buyer: \(order.buyerName.hasPrefix("SN-") ? "#" + String(order.buyerName.dropFirst(3)) : order.buyerName)")
                                if !order.phoneNumber.isEmpty {
                                    Text("Phone: \(order.phoneNumber)")
                                }
                                if !order.address.isEmpty {
                                    Text("Address: \(order.address)")
                                }
                                Text("Platform: \(order.platform.name) • Status: \(order.paymentStatus.rawValue)")
                            }
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                            .padding(.leading, 25)
                            
                            Divider()
                        }
                    }
                    
                    // Footer
                    VStack(spacing: 4) {
                        Divider()
                        HStack {
                            Text("GRAND TOTAL")
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(currencySymbol)\(totalRevenue, specifier: "%.2f")")
                                .fontWeight(.bold)
                        }
                        .font(.headline)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Daily Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    ShareLink(item: generateReportText()) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    func generateReportText() -> String {
        var report = """
        \(companyName)
        DAILY SALES REPORT
        \(dateFormatter.string(from: Date()))
        ================================
        
        """
        
        for (index, order) in orders.enumerated() {
            var orderText = """
            #\(index + 1) \(order.productName)
            """
            
            if order.hasBarcode {
                orderText += "\nBarcode: \(order.productBarcode)"
            }
            
            // Convert "SN-1" to "#1" for print
            let buyerDisplay = order.buyerName.hasPrefix("SN-") ? "#" + String(order.buyerName.dropFirst(3)) : order.buyerName
            
            orderText += """
            
            Qty: \(order.quantity) x \(currencySymbol)\(String(format: "%.2f", order.pricePerUnit)) = \(currencySymbol)\(String(format: "%.2f", order.totalPrice))
            Buyer: \(buyerDisplay)
            Phone: \(order.phoneNumber.isEmpty ? "N/A" : order.phoneNumber)
            Address: \(order.address.isEmpty ? "N/A" : order.address)
            Platform: \(order.platform.name) | Status: \(order.paymentStatus.rawValue)
            --------------------------------
            
            """
            
            report += orderText
        }
        
        report += """
        ================================
        TOTAL ORDERS: \(orders.count)
        TOTAL ITEMS: \(orders.reduce(0) { $0 + $1.quantity })
        GRAND TOTAL: \(currencySymbol)\(String(format: "%.2f", totalRevenue))
        """
        
        return report
    }
}

// Mini logo for header (Logo 10 - Calculator with L stamped + Signal + LIVE)
struct LiveLedgerLogoMini: View {
    private let greenStart = Color(red: 0.02, green: 0.59, blue: 0.41)
    private let greenEnd = Color(red: 0.02, green: 0.47, blue: 0.34)
    private let liveRed = Color(red: 0.94, green: 0.27, blue: 0.27)
    
    var body: some View {
        ZStack {
            // Green background
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(colors: [greenStart, greenEnd],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 36, height: 36)
            
            // Signal arcs (top right)
            MiniSignalArc()
                .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                .frame(width: 14, height: 14)
                .offset(x: 8, y: -8)
            
            MiniSignalArc()
                .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                .frame(width: 10, height: 10)
                .offset(x: 8, y: -8)
            
            MiniSignalArc()
                .stroke(Color.white, lineWidth: 1.5)
                .frame(width: 6, height: 6)
                .offset(x: 8, y: -8)
            
            // L² - Official LiveLedger Logo (Mini)
            // "2" positioned at top-right corner of L, nearly touching
            ZStack(alignment: .topTrailing) {
                Text("L")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text("²")
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                    .offset(x: 5, y: -2)  // Top-right corner position
            }
            .offset(x: -1, y: 2)
            
            // LIVE badge
            Text("LIVE")
                .font(.system(size: 5, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 3)
                .padding(.vertical, 1)
                .background(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(liveRed)
                )
                .offset(x: -8, y: -14)
        }
        .frame(width: 40, height: 40)
    }
}

// Mini signal arc for header logo
struct MiniSignalArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: 0, y: rect.height),
            radius: rect.width,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        return path
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HeaderView(viewModel: SalesViewModel(), themeManager: ThemeManager(), authManager: AuthManager(), localization: LocalizationManager.shared, showSettings: .constant(false), showSubscription: .constant(false))
            .padding()
    }
}
