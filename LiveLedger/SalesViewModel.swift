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
    
    enum DiscountFilter: String, CaseIterable {
        case all = "All"
        case withDiscount = "With Discount"
        case withoutDiscount = "Without Discount"
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
        
        return result
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
    
    // MARK: - UserDefaults Keys
    private let catalogsKey = "livesales_catalogs"
    private let selectedCatalogKey = "livesales_selected_catalog"
    private let ordersKey = "livesales_orders"
    private let platformsKey = "livesales_platforms"
    // Timer keys
    private let timerElapsedKey = "livesales_timer_elapsed"
    private let timerIsActiveKey = "livesales_timer_active"
    private let timerIsRunningKey = "livesales_timer_running"
    private let timerManuallyPausedKey = "livesales_timer_manually_paused"
    private let timerSessionEndedKey = "livesales_timer_session_ended"
    private let timerLastUpdateKey = "livesales_timer_last_update"
    
    // MARK: - Initialization
    init() {
        loadData()
        loadTimerState()
        setupAppLifecycleObservers()
        setupDemoDataObserver()
        
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
        ) { [weak self] _ in
            self?.populateDemoData()
        }
    }
    
    /// Populates the app with sample demo data for App Store review
    func populateDemoData() {
        // Create demo products
        let demoProducts = [
            Product(name: "Vintage T-Shirt", price: 29.99, stock: 15, lowStockThreshold: 5, criticalStockThreshold: 2),
            Product(name: "Handmade Candle", price: 18.50, stock: 25, lowStockThreshold: 8, criticalStockThreshold: 3),
            Product(name: "Organic Face Cream", price: 45.00, stock: 8, lowStockThreshold: 5, criticalStockThreshold: 2, discountType: .percentage, discountValue: 10),
            Product(name: "Beaded Bracelet", price: 12.99, stock: 40, lowStockThreshold: 10, criticalStockThreshold: 5),
            Product(name: "Art Print (Large)", price: 35.00, stock: 12, lowStockThreshold: 4, criticalStockThreshold: 2),
            Product(name: "Handmade Soap Set", price: 22.00, stock: 3, lowStockThreshold: 5, criticalStockThreshold: 2), // Low stock demo
        ]
        
        // Create demo catalog
        let demoCatalog = ProductCatalog(name: "Demo Products", products: demoProducts)
        catalogs = [demoCatalog]
        selectedCatalogId = demoCatalog.id
        
        // Create demo orders with variety of statuses
        let demoOrders: [Order] = [
            Order(
                productId: demoProducts[0].id,
                productName: demoProducts[0].name,
                buyerName: "Sarah M.",
                phoneNumber: "(555) 123-4567",
                address: "123 Main St, Austin TX",
                platform: .tiktok,
                quantity: 2,
                pricePerUnit: demoProducts[0].price,
                paymentStatus: .paid,
                isFulfilled: true,
                timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
            ),
            Order(
                productId: demoProducts[1].id,
                productName: demoProducts[1].name,
                buyerName: "John D.",
                phoneNumber: "(555) 234-5678",
                address: "456 Oak Ave, Portland OR",
                platform: .instagram,
                quantity: 1,
                pricePerUnit: demoProducts[1].price,
                paymentStatus: .paid,
                isFulfilled: false,
                timestamp: Date().addingTimeInterval(-1800) // 30 min ago
            ),
            Order(
                productId: demoProducts[2].id,
                productName: demoProducts[2].name,
                buyerName: "Emily R.",
                phoneNumber: "(555) 345-6789",
                address: "",
                platform: .facebook,
                quantity: 1,
                pricePerUnit: demoProducts[2].finalPrice,
                wasDiscounted: true,
                paymentStatus: .pending,
                isFulfilled: false,
                timestamp: Date().addingTimeInterval(-900) // 15 min ago
            ),
            Order(
                productId: demoProducts[3].id,
                productName: demoProducts[3].name,
                buyerName: "SN-42",
                platform: .tiktok,
                quantity: 3,
                pricePerUnit: demoProducts[3].price,
                paymentStatus: .unset,
                timestamp: Date().addingTimeInterval(-300) // 5 min ago
            ),
            Order(
                productId: demoProducts[4].id,
                productName: demoProducts[4].name,
                buyerName: "Alex T.",
                phoneNumber: "(555) 456-7890",
                platform: .instagram,
                quantity: 1,
                pricePerUnit: demoProducts[4].price,
                paymentStatus: .paid,
                isFulfilled: true,
                timestamp: Date().addingTimeInterval(-120) // 2 min ago
            ),
        ]
        
        orders = demoOrders
        
        // Save all demo data
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
    func createOrder(product: Product, buyerName: String, phoneNumber: String, address: String, platform: Platform, quantity: Int = 1) {
        // Timer is now manually controlled - no auto-start
        
        let order = Order(
            productId: product.id,
            productName: product.name,
            productBarcode: product.barcode,
            buyerName: buyerName,
            phoneNumber: phoneNumber,
            address: address,
            platform: platform,
            quantity: quantity,
            pricePerUnit: product.finalPrice,
            wasDiscounted: product.hasDiscount
        )
        orders.insert(order, at: 0)
        decrementStock(for: product.id, by: quantity)
        
        // Play order added sound
        SoundManager.shared.playOrderAddedSound()
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
            case .pending: orders[index].paymentStatus = .paid
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
        
        // Play timer start sound
        SoundManager.shared.playTimerStartSound()
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
        // Play stop sound when timer was active
        if isTimerRunning || isTimerPaused || sessionElapsedTime > 0 {
            SoundManager.shared.playTimerStopSound()
        }
        
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

