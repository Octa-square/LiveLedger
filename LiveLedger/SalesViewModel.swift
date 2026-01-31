//
//  SalesViewModel.swift
//  LiveLedger
//
//  Live Sales Tracker - Main ViewModel
//

import Foundation
import SwiftUI
import Combine

class SalesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var catalogs: [ProductCatalog] = []
    @Published var selectedCatalogId: UUID?
    @Published var orders: [Order] = []
    @Published var platforms: [Platform] = Platform.defaultPlatforms
    @Published var selectedPlatform: Platform? = nil // Platform for ADDING new orders (nil = use first platform)
    @Published var showingSaveConfirmation = false
    @Published var showingClearConfirmation = false
    @Published var showingExportSheet = false
    @Published var csvURL: URL?
    
    // MARK: - Filter Properties (for DISPLAYING orders)
    @Published var filterPlatform: Platform? = nil // nil = All Platforms
    @Published var filterDiscount: DiscountFilter = .all
    @Published var filterPayment: PaymentFilter = .all
    @Published var filterOrderSource: OrderSource? = nil // nil = All Sources
    
    enum DiscountFilter: String, CaseIterable {
        case all = "All"
        case withDiscount = "With Discount"
        case withoutDiscount = "Without Discount"
    }
    
    enum PaymentFilter: String, CaseIterable {
        case all = "All"
        case unpaid = "Unpaid"
        case paid = "Paid"
    }
    
    // MARK: - Session Timer Properties
    @Published var sessionElapsedTime: TimeInterval = 0  // Total elapsed time in seconds
    @Published var isSessionActive: Bool = false         // Session has started (first order made)
    @Published var isTimerRunning: Bool = false          // Timer is currently running
    @Published var isTimerManuallyPaused: Bool = false   // User manually paused
    @Published var sessionEnded: Bool = false            // Session permanently ended
    private var timerCancellable: AnyCancellable?
    private var lastTimerUpdateDate: Date?
    
    // MARK: - Catalog Computed Properties
    var currentCatalog: ProductCatalog? {
        get {
            guard let id = selectedCatalogId else { return catalogs.first }
            return catalogs.first { $0.id == id } ?? catalogs.first
        }
        set {
            if let newValue = newValue, let index = catalogs.firstIndex(where: { $0.id == newValue.id }) {
                catalogs[index] = newValue
            }
        }
    }
    
    var products: [Product] {
        get { currentCatalog?.products ?? [] }
        set {
            if let id = selectedCatalogId ?? catalogs.first?.id,
               let index = catalogs.firstIndex(where: { $0.id == id }) {
                catalogs[index].products = newValue
            }
        }
    }
    
    var currentCatalogName: String {
        currentCatalog?.name ?? "Products"
    }
    
    var canAddMoreProducts: Bool {
        guard let catalog = currentCatalog else { return false }
        return catalog.products.count < ProductCatalog.maxProducts
    }
    
    // MARK: - Computed Properties
    var filteredOrders: [Order] {
        var result = orders
        
        // Filter by platform
        if let platform = filterPlatform {
            result = result.filter { $0.platform.id == platform.id }
        }
        
        // Filter by discount
        switch filterDiscount {
        case .all:
            break
        case .withDiscount:
            result = result.filter { $0.wasDiscounted }
        case .withoutDiscount:
            result = result.filter { !$0.wasDiscounted }
        }
        
        // Filter by payment status
        switch filterPayment {
        case .all: break
        case .unpaid: result = result.filter { $0.paymentStatus != .paid }
        case .paid: result = result.filter { $0.paymentStatus == .paid }
        }
        
        // Filter by order source
        if let source = filterOrderSource {
            result = result.filter { $0.orderSource == source }
        }
        
        return result
    }
    
    /// Unpaid order count (across all orders, for dashboard)
    var unpaidOrderCount: Int {
        orders.filter { $0.paymentStatus != .paid }.count
    }
    
    /// Order source breakdown: (source, count, percent) for dashboard
    var orderSourceBreakdown: [(source: OrderSource, count: Int, percent: Double)] {
        let total = Double(orders.count)
        guard total > 0 else { return [] }
        let bySource = Dictionary(grouping: orders) { $0.orderSource }
        return bySource.map { source, list in
            (source: source, count: list.count, percent: (Double(list.count) / total) * 100)
        }.sorted { $0.percent > $1.percent }
    }
    
    var totalRevenue: Double {
        filteredOrders.reduce(0) { $0 + $1.totalPrice }
    }
    
    var paidAmount: Double {
        filteredOrders.filter { $0.paymentStatus == .paid }.reduce(0) { $0 + $1.totalPrice }
    }
    
    var pendingAmount: Double {
        filteredOrders.filter { $0.paymentStatus == .pending }.reduce(0) { $0 + $1.totalPrice }
    }
    
    var unsetAmount: Double {
        filteredOrders.filter { $0.paymentStatus == .unset }.reduce(0) { $0 + $1.totalPrice }
    }
    
    var orderCount: Int {
        filteredOrders.count
    }
    
    // MARK: - Enhanced Statistics (for dashboard)
    
    /// Average Order Value: Total Sales ÷ Total Orders
    var averageOrderValue: Double {
        guard orderCount > 0 else { return 0 }
        return totalRevenue / Double(orderCount)
    }
    
    /// Total quantity of all items sold (across filtered orders)
    var productsSoldQuantity: Int {
        filteredOrders.reduce(0) { $0 + $1.quantity }
    }
    
    /// Profit Margin: (Sales - Costs) ÷ Sales × 100. No cost data → show as N/A or 0.
    var profitMarginPercent: Double? {
        guard totalRevenue > 0 else { return nil }
        // App does not track costs; could be extended later
        return nil
    }
    
    /// Count of products with stock < 10
    var lowStockAlertCount: Int {
        products.filter { !$0.isEmpty && $0.stock < 10 && $0.stock > 0 }.count
    }
    
    /// Revenue from today only (calendar day, local timezone)
    var todaySales: Double {
        let cal = Calendar.current
        let startOfToday = cal.startOfDay(for: Date())
        return orders
            .filter { $0.timestamp >= startOfToday }
            .reduce(0) { $0 + $1.totalPrice }
    }
    
    /// Revenue from current week (Monday–Sunday)
    var thisWeekSales: Double {
        let cal = Calendar.current
        guard let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return 0 }
        let endOfWeek = cal.date(byAdding: .day, value: 7, to: startOfWeek) ?? Date()
        return orders
            .filter { $0.timestamp >= startOfWeek && $0.timestamp < endOfWeek }
            .reduce(0) { $0 + $1.totalPrice }
    }
    
    /// Revenue from current month
    var thisMonthSales: Double {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: Date())
        guard let startOfMonth = cal.date(from: comps),
              let endOfMonth = cal.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else { return 0 }
        let endStart = cal.date(byAdding: .day, value: 1, to: endOfMonth) ?? Date()
        return orders
            .filter { $0.timestamp >= startOfMonth && $0.timestamp < endStart }
            .reduce(0) { $0 + $1.totalPrice }
    }
    
    /// Best day this month: (date, revenue)
    var bestDayThisMonth: (date: Date, revenue: Double)? {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: Date())
        guard let startOfMonth = cal.date(from: comps) else { return nil }
        let monthOrders = orders.filter { $0.timestamp >= startOfMonth }
        let byDay = Dictionary(grouping: monthOrders) { cal.startOfDay(for: $0.timestamp) }
        return byDay
            .map { (date: $0.key, revenue: $0.value.reduce(0) { $0 + $1.totalPrice }) }
            .max(by: { $0.revenue < $1.revenue })
    }
    
    /// Top platform by revenue (filtered orders)
    var topPlatformName: String? {
        let byPlatform = Dictionary(grouping: filteredOrders) { $0.platform.name }
        return byPlatform
            .map { (name: $0.key, revenue: $0.value.reduce(0) { $0 + $1.totalPrice }) }
            .max(by: { $0.revenue < $1.revenue })
            .map { $0.name }
    }
    
    /// Platform breakdown: name -> percentage (0–100)
    var platformBreakdown: [(name: String, percent: Double)] {
        guard totalRevenue > 0 else { return [] }
        let byPlatform = Dictionary(grouping: filteredOrders) { $0.platform.name }
        return byPlatform.map { name, orders in
            let rev = orders.reduce(0) { $0 + $1.totalPrice }
            return (name: name, percent: (rev / totalRevenue) * 100)
        }.sorted { $0.percent > $1.percent }
    }
    
    /// Set from MainAppView/MainTabView so notification observer can read current Pro status for sample data images.
    weak var authManager: AuthManager?
    
    // MARK: - UserDefaults Keys (per-user to isolate data across accounts)
    private var userDataSuffix: String { "\(authManager?.currentUser?.id ?? "default")" }
    private var catalogsKey: String { "livesales_catalogs_\(userDataSuffix)" }
    private var selectedCatalogKey: String { "livesales_selected_catalog_\(userDataSuffix)" }
    private var ordersKey: String { "livesales_orders_\(userDataSuffix)" }
    private var platformsKey: String { "livesales_platforms_\(userDataSuffix)" }
    // Timer keys (per-user)
    private var timerElapsedKey: String { "livesales_timer_elapsed_\(userDataSuffix)" }
    private var timerIsActiveKey: String { "livesales_timer_active_\(userDataSuffix)" }
    private var timerIsRunningKey: String { "livesales_timer_running_\(userDataSuffix)" }
    private var timerManuallyPausedKey: String { "livesales_timer_manually_paused_\(userDataSuffix)" }
    private var timerSessionEndedKey: String { "livesales_timer_session_ended_\(userDataSuffix)" }
    private var timerLastUpdateKey: String { "livesales_timer_last_update_\(userDataSuffix)" }
    
    // MARK: - Initialization
    init() {
        loadData()
        loadTimerState()
        setupAppLifecycleObservers()
        setupDemoDataObserver()
        print("[SampleData] SalesViewModel init – .populateDemoData observer registered")
        setupClearDataObserver()
        
        // Initialize with one default catalog if empty
        if catalogs.isEmpty {
            let defaultCatalog = ProductCatalog(name: "My Products")
            catalogs = [defaultCatalog]
            selectedCatalogId = defaultCatalog.id
        }
        
        // Resume timer if it was running (not manually paused) when app closed
        if isSessionActive && !sessionEnded && !isTimerManuallyPaused {
            resumeTimer()
        }
    }
    
    // MARK: - Demo Mode Setup
    private func setupDemoDataObserver() {
        NotificationCenter.default.addObserver(
            forName: .populateDemoData,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let email = notification.userInfo?["email"] as? String
            guard let email = email, email.lowercased() == "applereview@liveledger.com" else { return }
            let currentIsPro = self?.authManager?.currentUser?.isPro ?? false
            self?.populateDemoData(email: email, isPro: currentIsPro)
        }
    }
    
    // MARK: - Clear Data on Sign-Out (data isolation)
    private func setupClearDataObserver() {
        NotificationCenter.default.addObserver(
            forName: .clearAllData,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.orders = []
            self.catalogs = [ProductCatalog(name: "My Products")]
            self.selectedCatalogId = self.catalogs.first?.id
            self.platforms = Platform.defaultPlatforms
            // Clear in-memory only; do not save to avoid overwriting another user's bucket
            // Next user's data loads via loadData() when they log in
        }
    }
    
    /// Populates the app with sample data ONLY for Apple Review test account (applereview@liveledger.com). All other emails get no sample data.
    /// Products are ALWAYS generated WITH images so that: Basic users see placeholders; Pro users see images; when they upgrade/resubscribe, images appear.
    func populateDemoData(email: String?, isPro: Bool = false) {
        let normalized = (email ?? "").lowercased()
        guard normalized == "applereview@liveledger.com" else { return }
        let hasProducts = !products.isEmpty && !products.allSatisfy { $0.isEmpty }
        guard !hasProducts else { return }
        // Always generate products WITH images. Display is gated by isPro (Basic hides, Pro shows).
        let reviewProducts = SampleDataGenerator.makeReviewProducts(isPro: true)
        let reviewOrders = SampleDataGenerator.makeReviewOrders(products: reviewProducts)
        let catalog = ProductCatalog(name: "Sample Products", products: reviewProducts)
        catalogs = [catalog]
        selectedCatalogId = catalog.id
        orders = reviewOrders
        saveData()
    }
    
    // MARK: - Persistence
    func saveData() {
        if let catalogsData = try? JSONEncoder().encode(catalogs) {
            UserDefaults.standard.set(catalogsData, forKey: catalogsKey)
        }
        if let selectedId = selectedCatalogId {
            UserDefaults.standard.set(selectedId.uuidString, forKey: selectedCatalogKey)
        }
        if let ordersData = try? JSONEncoder().encode(orders) {
            UserDefaults.standard.set(ordersData, forKey: ordersKey)
        }
        if let platformsData = try? JSONEncoder().encode(platforms) {
            UserDefaults.standard.set(platformsData, forKey: platformsKey)
        }
        showingSaveConfirmation = true
    }
    
    func loadData() {
        // Load catalogs
        if let catalogsData = UserDefaults.standard.data(forKey: catalogsKey),
           let decoded = try? JSONDecoder().decode([ProductCatalog].self, from: catalogsData) {
            catalogs = decoded
        }
        
        // Load selected catalog
        if let selectedIdString = UserDefaults.standard.string(forKey: selectedCatalogKey),
           let selectedId = UUID(uuidString: selectedIdString) {
            selectedCatalogId = selectedId
        }
        
        // Migrate old products format to new catalog format
        if catalogs.isEmpty {
            let oldProductsKey = "livesales_products"
            if let productsData = UserDefaults.standard.data(forKey: oldProductsKey),
               let oldProducts = try? JSONDecoder().decode([Product].self, from: productsData) {
                let migratedCatalog = ProductCatalog(name: "My Products", products: oldProducts)
                catalogs = [migratedCatalog]
                selectedCatalogId = migratedCatalog.id
                // Clean up old key
                UserDefaults.standard.removeObject(forKey: oldProductsKey)
            }
        }
        
        if let ordersData = UserDefaults.standard.data(forKey: ordersKey),
           let decoded = try? JSONDecoder().decode([Order].self, from: ordersData) {
            orders = decoded
        }
        if let platformsData = UserDefaults.standard.data(forKey: platformsKey),
           let decoded = try? JSONDecoder().decode([Platform].self, from: platformsData) {
            platforms = decoded
            // Migrate default platform colors to brand colors
            migratePlatformColors()
        }
    }
    
    // Update default platforms to use official brand colors
    private func migratePlatformColors() {
        var needsSave = false
        
        // Update platform selector buttons
        for i in platforms.indices {
            if platforms[i].name == "TikTok" && platforms[i].color != "tiktok" {
                platforms[i] = Platform(id: platforms[i].id, name: "TikTok", icon: "music.note", color: "tiktok", isCustom: false)
                needsSave = true
            }
            if platforms[i].name == "Instagram" && platforms[i].color != "instagram" {
                platforms[i] = Platform(id: platforms[i].id, name: "Instagram", icon: "camera.fill", color: "instagram", isCustom: false)
                needsSave = true
            }
            if platforms[i].name == "Facebook" && platforms[i].color != "facebookblue" {
                platforms[i] = Platform(id: platforms[i].id, name: "Facebook", icon: "f.square.fill", color: "facebookblue", isCustom: false)
                needsSave = true
            }
        }
        
        // Also update orders' platform colors
        for i in orders.indices {
            if orders[i].platform.name == "TikTok" && orders[i].platform.color != "tiktok" {
                orders[i].platform = Platform(id: orders[i].platform.id, name: "TikTok", icon: "music.note", color: "tiktok", isCustom: false)
                needsSave = true
            }
            if orders[i].platform.name == "Instagram" && orders[i].platform.color != "instagram" {
                orders[i].platform = Platform(id: orders[i].platform.id, name: "Instagram", icon: "camera.fill", color: "instagram", isCustom: false)
                needsSave = true
            }
            if orders[i].platform.name == "Facebook" && orders[i].platform.color != "facebookblue" {
                orders[i].platform = Platform(id: orders[i].platform.id, name: "Facebook", icon: "f.square.fill", color: "facebookblue", isCustom: false)
                needsSave = true
            }
        }
        
        if needsSave {
            saveData()
        }
    }
    
    func clearAllData() {
        orders.removeAll()
        // Reset current catalog to default 4 empty products
        if let id = selectedCatalogId ?? catalogs.first?.id,
           let index = catalogs.firstIndex(where: { $0.id == id }) {
            catalogs[index].products = [Product(), Product(), Product(), Product()]
        }
        saveData()
    }
    
    /// Load state from a backup (used after Restore from Backup).
    func loadFromBackup(_ backup: BackupData) {
        orders = backup.orders
        catalogs = backup.catalogs
        platforms = backup.platforms
        selectedCatalogId = catalogs.first?.id
        saveData()
    }
    
    /// Reset to empty state and persist (used for "Delete My Data").
    func resetToEmptyState() {
        orders = []
        catalogs = [ProductCatalog(name: "My Products")]
        selectedCatalogId = catalogs.first?.id
        platforms = Platform.defaultPlatforms
        saveData()
    }
    
    /// Returns true if current catalogs/orders look like the sample data (e.g. "Sample Products" catalog or "Blue Cotton T-Shirt").
    private func currentDataLooksLikeSampleData() -> Bool {
        let hasSampleCatalog = catalogs.contains { $0.name == "Sample Products" }
        let hasSampleProduct = catalogs.contains { catalog in
            catalog.products.contains { $0.name == "Blue Cotton T-Shirt" }
        }
        return hasSampleCatalog || hasSampleProduct
    }
    
    /// If current user is NOT applereview@liveledger.com and loaded data looks like sample data (e.g. from previous session), clear it so they see empty app.
    func clearSampleDataForNonReviewUser(currentEmail: String?) {
        let normalized = (currentEmail ?? "").lowercased()
        guard normalized != "applereview@liveledger.com" else { return }
        guard currentDataLooksLikeSampleData() else { return }
        print("[SampleData] Clearing sample data for non-review user (email: \(currentEmail ?? "nil"))")
        resetToEmptyState()
    }
    
    func addNewProduct() -> Bool {
        guard let id = selectedCatalogId ?? catalogs.first?.id,
              let index = catalogs.firstIndex(where: { $0.id == id }) else { return false }
        
        // Max 12 products per catalog
        guard catalogs[index].products.count < ProductCatalog.maxProducts else { return false }
        catalogs[index].products.append(Product())
        return true
    }
    
    // MARK: - Catalog Management
    func createCatalog(name: String) -> ProductCatalog {
        let newCatalog = ProductCatalog(name: name)
        catalogs.append(newCatalog)
        selectedCatalogId = newCatalog.id
        saveData()
        return newCatalog
    }
    
    func renameCatalog(_ catalog: ProductCatalog, to newName: String) {
        if let index = catalogs.firstIndex(where: { $0.id == catalog.id }) {
            catalogs[index].name = newName
            saveData()
        }
    }
    
    func deleteCatalog(_ catalog: ProductCatalog) {
        // Don't delete the last catalog
        guard catalogs.count > 1 else { return }
        
        catalogs.removeAll { $0.id == catalog.id }
        
        // If we deleted the selected catalog, select the first one
        if selectedCatalogId == catalog.id {
            selectedCatalogId = catalogs.first?.id
        }
        saveData()
    }
    
    func selectCatalog(_ catalog: ProductCatalog) {
        selectedCatalogId = catalog.id
        saveData()
    }
    
    // MARK: - Product Management
    func updateProduct(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index] = product
        }
    }
    
    func decrementStock(for productId: UUID, by amount: Int = 1) {
        if let index = products.firstIndex(where: { $0.id == productId }) {
            products[index].stock = max(0, products[index].stock - amount)
        }
    }
    
    func incrementStock(for productId: UUID, by amount: Int = 1) {
        if let index = products.firstIndex(where: { $0.id == productId }) {
            products[index].stock += amount
        }
    }
    
    // MARK: - Order Management
    
    /// Convenience method for quick order entry (used by overlay)
    func addOrder(product: Product, quantity: Int, buyerName: String?, phoneNumber: String = "", customerNotes: String? = nil, orderSource: OrderSource = .liveStream) {
        createOrder(
            product: product,
            buyerName: buyerName ?? "Customer",
            phoneNumber: phoneNumber,
            address: "",
            customerNotes: customerNotes,
            orderSource: orderSource,
            platform: selectedPlatform ?? platforms.first ?? Platform(name: "TikTok", icon: "music.note", color: "#ff0050"),
            quantity: quantity
        )
    }
    
    /// Unique previous customers (name, phone, notes) for autocomplete - from existing orders, most recent first
    func previousCustomers(prefix: String = "") -> [(name: String, phone: String, notes: String)] {
        var seen = Set<String>()
        let normalized = prefix.trimmingCharacters(in: .whitespaces).lowercased()
        return orders
            .filter { !$0.buyerName.isEmpty }
            .filter { normalized.isEmpty || $0.buyerName.lowercased().hasPrefix(normalized) || $0.buyerName.lowercased().contains(normalized) }
            .compactMap { order -> (name: String, phone: String, notes: String)? in
                let key = order.buyerName.lowercased()
                guard !seen.contains(key) else { return nil }
                seen.insert(key)
                return (order.buyerName, order.phoneNumber, order.customerNotes ?? "")
            }
    }
    
    func createOrder(product: Product, buyerName: String, phoneNumber: String, address: String, customerNotes: String? = nil, orderSource: OrderSource = .liveStream, platform: Platform, quantity: Int = 1) {
        // Timer is now manually controlled - no auto-start
        
        let order = Order(
            productId: product.id,
            productName: product.name,
            productBarcode: product.barcode,
            buyerName: buyerName,
            phoneNumber: phoneNumber,
            address: address,
            customerNotes: customerNotes,
            orderSource: orderSource,
            platform: platform,
            quantity: quantity,
            pricePerUnit: product.finalPrice,
            wasDiscounted: product.hasDiscount
        )
        orders.insert(order, at: 0)
        decrementStock(for: product.id, by: quantity)
        
        SoundManager.shared.playOrderAddedSound()
        HapticManager.success()
    }
    
    func updateOrder(_ order: Order) {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index] = order
        }
    }
    
    func deleteOrder(_ order: Order) {
        // Restore stock when deleting order
        incrementStock(for: order.productId, by: order.quantity)
        orders.removeAll { $0.id == order.id }
    }
    
    func updateOrderQuantity(_ order: Order, newQuantity: Int) {
        guard newQuantity > 0 else { return }
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            let oldQuantity = orders[index].quantity
            let difference = newQuantity - oldQuantity
            
            // Adjust stock
            if difference > 0 {
                decrementStock(for: order.productId, by: difference)
            } else {
                incrementStock(for: order.productId, by: abs(difference))
            }
            
            orders[index].quantity = newQuantity
        }
    }
    
    func cyclePaymentStatus(_ order: Order) {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            let currentStatus = orders[index].paymentStatus
            switch currentStatus {
            case .unset: orders[index].paymentStatus = .pending
            case .pending:
                orders[index].paymentStatus = .paid
                HapticManager.success()
            case .paid: orders[index].paymentStatus = .unset
            }
        }
    }
    
    func toggleFulfilled(_ order: Order) {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index].isFulfilled.toggle()
        }
    }
    
    // MARK: - Platform Management
    func addCustomPlatform(name: String, color: String) {
        let platform = Platform(name: name, icon: "star.fill", color: color, isCustom: true)
        platforms.append(platform)
        saveData()
    }
    
    func deletePlatform(_ platform: Platform) {
        guard platform.isCustom else { return }
        platforms.removeAll { $0.id == platform.id }
        saveData()
    }
    
    // MARK: - CSV Export
    func generateCSV() -> String {
        var csv = "Order ID,Product,Buyer,Phone,Address,Platform,Quantity,Unit Price,Total,Payment Status,Timestamp\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for order in filteredOrders {
            // Convert "SN-1" to just "1" for export
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
        
        return csv
    }
    
    func exportCSV() {
        let csv = generateCSV()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let filename = "LiveSales_\(dateFormatter.string(from: Date())).csv"
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
            csvURL = tempURL
            showingExportSheet = true
        } catch {
            print("Failed to export CSV: \(error)")
        }
    }
    
    // MARK: - Session Timer Methods
    
    /// Start the timer manually
    func startTimer() {
        guard !isTimerRunning else { return }
        isSessionActive = true
        sessionEnded = false
        isTimerManuallyPaused = false
        lastTimerUpdateDate = Date()
        startTimerLoop()
        saveTimerState()
    }
    
    /// Manually pause the timer
    func pauseTimer() {
        guard isTimerRunning else { return }
        isTimerManuallyPaused = true
        stopTimerLoop()
        saveTimerState()
    }
    
    /// Resume the timer (from manual pause or app reopen)
    func resumeTimer() {
        guard !isTimerRunning && (isTimerPaused || sessionElapsedTime > 0) else { return }
        isTimerManuallyPaused = false
        isSessionActive = true
        sessionEnded = false
        lastTimerUpdateDate = Date()
        startTimerLoop()
        saveTimerState()
    }
    
    /// Stop and reset timer to 00:00:00
    func resetTimer() {
        stopTimerLoop()
        sessionElapsedTime = 0
        isSessionActive = false
        isTimerRunning = false
        isTimerManuallyPaused = false
        sessionEnded = false
        lastTimerUpdateDate = nil
        saveTimerState()
    }
    
    /// Check if timer is in paused state
    var isTimerPaused: Bool {
        isTimerManuallyPaused && sessionElapsedTime > 0
    }
    
    /// Format elapsed time as HH:MM:SS
    var formattedSessionTime: String {
        let hours = Int(sessionElapsedTime) / 3600
        let minutes = (Int(sessionElapsedTime) % 3600) / 60
        let seconds = Int(sessionElapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func startTimerLoop() {
        isTimerRunning = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.sessionElapsedTime += 1
            }
    }
    
    private func stopTimerLoop() {
        isTimerRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppWillResignActive()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppDidBecomeActive()
        }
    }
    
    private func handleAppWillResignActive() {
        // Save current state when app goes to background
        if isTimerRunning {
            lastTimerUpdateDate = Date()
        }
        saveTimerState()
        stopTimerLoop()
    }
    
    private func handleAppDidBecomeActive() {
        // Resume timer if it was running (not manually paused)
        guard isSessionActive && !sessionEnded && !isTimerManuallyPaused else { return }
        
        // Calculate elapsed time while app was in background
        if let lastUpdate = lastTimerUpdateDate {
            let backgroundElapsed = Date().timeIntervalSince(lastUpdate)
            sessionElapsedTime += backgroundElapsed
        }
        
        // Resume the timer loop
        lastTimerUpdateDate = Date()
        startTimerLoop()
    }
    
    private func saveTimerState() {
        UserDefaults.standard.set(sessionElapsedTime, forKey: timerElapsedKey)
        UserDefaults.standard.set(isSessionActive, forKey: timerIsActiveKey)
        UserDefaults.standard.set(isTimerRunning, forKey: timerIsRunningKey)
        UserDefaults.standard.set(isTimerManuallyPaused, forKey: timerManuallyPausedKey)
        UserDefaults.standard.set(sessionEnded, forKey: timerSessionEndedKey)
        if let date = lastTimerUpdateDate {
            UserDefaults.standard.set(date.timeIntervalSince1970, forKey: timerLastUpdateKey)
        }
    }
    
    private func loadTimerState() {
        sessionElapsedTime = UserDefaults.standard.double(forKey: timerElapsedKey)
        isSessionActive = UserDefaults.standard.bool(forKey: timerIsActiveKey)
        isTimerManuallyPaused = UserDefaults.standard.bool(forKey: timerManuallyPausedKey)
        sessionEnded = UserDefaults.standard.bool(forKey: timerSessionEndedKey)
        
        let lastUpdateTimestamp = UserDefaults.standard.double(forKey: timerLastUpdateKey)
        if lastUpdateTimestamp > 0 {
            lastTimerUpdateDate = Date(timeIntervalSince1970: lastUpdateTimestamp)
        }
    }
}

