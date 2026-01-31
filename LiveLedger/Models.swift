//
//  Models.swift
//  LiveLedger
//
//  Live Sales Tracker - Data Models
//

import Foundation
import SwiftUI

// MARK: - Platform
struct Platform: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var color: String
    var isCustom: Bool
    
    init(id: UUID = UUID(), name: String, icon: String, color: String, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.isCustom = isCustom
    }
    
    var swiftUIColor: Color {
        switch color {
        // Brand colors
        case "tiktok": return Color(red: 0.93, green: 0.11, blue: 0.32)      // #EE1D52 Hot Pink
        case "instagram": return Color(red: 0.76, green: 0.21, blue: 0.55)   // #C13584 Magenta
        case "facebookblue": return Color(red: 0.09, green: 0.47, blue: 0.95) // #1877F2 Facebook Blue
        // Standard colors
        case "pink": return .pink
        case "purple": return .purple
        case "blue": return .blue
        case "orange": return .orange
        case "green": return .green
        case "red": return .red
        case "yellow": return .yellow
        case "cyan": return .cyan
        case "indigo": return .indigo
        case "mint": return .mint
        case "teal": return .teal
        case "brown": return .brown
        default: return .gray
        }
    }
    
    // Default platforms with official brand colors
    static let tiktok = Platform(name: "TikTok", icon: "music.note", color: "tiktok")
    static let instagram = Platform(name: "Instagram", icon: "camera.fill", color: "instagram")
    static let facebook = Platform(name: "Facebook", icon: "f.square.fill", color: "facebookblue")
    static let all = Platform(name: "All", icon: "square.grid.2x2", color: "gray")
    
    static let defaultPlatforms: [Platform] = [.tiktok, .instagram, .facebook]
}

// MARK: - Payment Status
enum PaymentStatus: String, Codable, CaseIterable {
    case unset = "Unset"
    case pending = "Pending"
    case paid = "Paid"
    
    var color: Color {
        switch self {
        case .unset: return .gray
        case .pending: return .orange
        case .paid: return .green
        }
    }
    
    var icon: String {
        switch self {
        case .unset: return "questionmark.circle"
        case .pending: return "clock"
        case .paid: return "checkmark.circle.fill"
        }
    }
}

// MARK: - Discount Type
enum DiscountType: String, Codable, CaseIterable {
    case none = "None"
    case percentage = "Percentage"
    case amount = "Amount"
}

// MARK: - Product Catalog
struct ProductCatalog: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var products: [Product]
    
    static let maxProducts = 12
    
    init(id: UUID = UUID(), name: String = "My Products", products: [Product] = []) {
        self.id = id
        self.name = name
        // Start with 4 empty slots
        if products.isEmpty {
            self.products = [Product(), Product(), Product(), Product()]
        } else {
            self.products = products
        }
    }
    
    var isFull: Bool {
        products.count >= Self.maxProducts
    }
    
    var configuredProductsCount: Int {
        products.filter { !$0.isEmpty }.count
    }
}

// MARK: - Product
struct Product: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var price: Double
    var stock: Int
    var lowStockThreshold: Int
    var criticalStockThreshold: Int
    var discountType: DiscountType
    var discountValue: Double
    var barcode: String
    var imageData: Data?
    
    init(id: UUID = UUID(), name: String = "", price: Double = 0, stock: Int = 0, lowStockThreshold: Int = 10, criticalStockThreshold: Int = 5, discountType: DiscountType = .none, discountValue: Double = 0, barcode: String = "", imageData: Data? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.stock = stock
        self.lowStockThreshold = lowStockThreshold
        self.criticalStockThreshold = criticalStockThreshold
        self.discountType = discountType
        self.discountValue = discountValue
        self.barcode = barcode
        self.imageData = imageData
    }
    
    var hasImage: Bool {
        imageData != nil
    }
    
    var hasBarcode: Bool {
        !barcode.isEmpty
    }
    
    var stockColor: Color {
        if stock == 0 {
            return .gray     // Out of stock - disabled
        } else if stock <= criticalStockThreshold {
            return .red      // Critical - needs attention!
        } else if stock <= lowStockThreshold {
            return .yellow   // Low - warning
        } else {
            return .green    // Plenty - healthy stock
        }
    }
    
    var isEmpty: Bool {
        name.isEmpty && price == 0 && stock == 0
    }
    
    var finalPrice: Double {
        switch discountType {
        case .none:
            return price
        case .percentage:
            return price * (1 - discountValue / 100)
        case .amount:
            return max(0, price - discountValue)
        }
    }
    
    var hasDiscount: Bool {
        discountType != .none && discountValue > 0
    }
}

// MARK: - Order Source (where the order came from)
enum OrderSource: String, CaseIterable, Codable {
    case liveStream = "Live Stream"
    case instagramDM = "Instagram DM"
    case facebookDM = "Facebook DM"
    case tiktokDM = "TikTok DM"
    case whatsApp = "WhatsApp"
    case other = "Other"
    
    static var defaultSource: OrderSource { .liveStream }
    
    var shortLabel: String {
        switch self {
        case .liveStream: return "Live"
        case .instagramDM: return "Instagram"
        case .facebookDM: return "Facebook"
        case .tiktokDM: return "TikTok"
        case .whatsApp: return "WhatsApp"
        case .other: return "Other"
        }
    }
}

// MARK: - Order
struct Order: Identifiable, Codable, Equatable {
    let id: UUID
    var productId: UUID
    var productName: String
    var productBarcode: String  // Stored for receipts
    var buyerName: String
    var phoneNumber: String
    var address: String
    var customerNotes: String?  // Optional notes (repeat buyers)
    var orderSourceRaw: String? // Backward compat: nil = "Live Stream"
    var platform: Platform
    var quantity: Int
    var pricePerUnit: Double
    var wasDiscounted: Bool  // Was this order placed with a discount?
    var paymentStatus: PaymentStatus
    var isFulfilled: Bool  // Simple: has order been completed/delivered?
    var timestamp: Date
    
    /// Order source for display/filter (defaults to Live Stream)
    var orderSource: OrderSource {
        get {
            guard let raw = orderSourceRaw, let s = OrderSource(rawValue: raw) else { return .liveStream }
            return s
        }
        set { orderSourceRaw = newValue.rawValue }
    }
    
    init(id: UUID = UUID(), productId: UUID, productName: String, productBarcode: String = "", buyerName: String, phoneNumber: String = "", address: String = "", customerNotes: String? = nil, orderSource: OrderSource = .liveStream, platform: Platform, quantity: Int, pricePerUnit: Double, wasDiscounted: Bool = false, paymentStatus: PaymentStatus = .unset, isFulfilled: Bool = false, timestamp: Date = Date()) {
        self.id = id
        self.productId = productId
        self.productName = productName
        self.productBarcode = productBarcode
        self.buyerName = buyerName
        self.phoneNumber = phoneNumber
        self.address = address
        self.customerNotes = customerNotes
        self.orderSourceRaw = orderSource.rawValue
        self.platform = platform
        self.quantity = quantity
        self.pricePerUnit = pricePerUnit
        self.wasDiscounted = wasDiscounted
        self.paymentStatus = paymentStatus
        self.isFulfilled = isFulfilled
        self.timestamp = timestamp
    }
    
    enum CodingKeys: String, CodingKey {
        case id, productId, productName, productBarcode, buyerName, phoneNumber, address, platform, quantity, pricePerUnit, wasDiscounted, paymentStatus, isFulfilled, timestamp
        case customerNotes
        case orderSourceRaw = "orderSource"
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        productId = try c.decode(UUID.self, forKey: .productId)
        productName = try c.decode(String.self, forKey: .productName)
        productBarcode = try c.decodeIfPresent(String.self, forKey: .productBarcode) ?? ""
        buyerName = try c.decode(String.self, forKey: .buyerName)
        phoneNumber = try c.decodeIfPresent(String.self, forKey: .phoneNumber) ?? ""
        address = try c.decodeIfPresent(String.self, forKey: .address) ?? ""
        customerNotes = try c.decodeIfPresent(String.self, forKey: .customerNotes)
        orderSourceRaw = try c.decodeIfPresent(String.self, forKey: .orderSourceRaw)
        platform = try c.decode(Platform.self, forKey: .platform)
        quantity = try c.decode(Int.self, forKey: .quantity)
        pricePerUnit = try c.decode(Double.self, forKey: .pricePerUnit)
        wasDiscounted = try c.decodeIfPresent(Bool.self, forKey: .wasDiscounted) ?? false
        paymentStatus = try c.decodeIfPresent(PaymentStatus.self, forKey: .paymentStatus) ?? .unset
        isFulfilled = try c.decodeIfPresent(Bool.self, forKey: .isFulfilled) ?? false
        timestamp = try c.decode(Date.self, forKey: .timestamp)
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(productId, forKey: .productId)
        try c.encode(productName, forKey: .productName)
        try c.encode(productBarcode, forKey: .productBarcode)
        try c.encode(buyerName, forKey: .buyerName)
        try c.encode(phoneNumber, forKey: .phoneNumber)
        try c.encode(address, forKey: .address)
        try c.encodeIfPresent(customerNotes, forKey: .customerNotes)
        try c.encode(orderSourceRaw ?? OrderSource.liveStream.rawValue, forKey: .orderSourceRaw)
        try c.encode(platform, forKey: .platform)
        try c.encode(quantity, forKey: .quantity)
        try c.encode(pricePerUnit, forKey: .pricePerUnit)
        try c.encode(wasDiscounted, forKey: .wasDiscounted)
        try c.encode(paymentStatus, forKey: .paymentStatus)
        try c.encode(isFulfilled, forKey: .isFulfilled)
        try c.encode(timestamp, forKey: .timestamp)
    }
    
    var hasBarcode: Bool {
        !productBarcode.isEmpty
    }
    
    var totalPrice: Double {
        Double(quantity) * pricePerUnit
    }
    
    /// True when payment status is Paid
    var isPaid: Bool {
        paymentStatus == .paid
    }
}
