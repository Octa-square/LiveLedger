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
        // Always maintain 12 product slots (core catalog structure)
        if products.isEmpty {
            self.products = (0..<Self.maxProducts).map { _ in Product() }
        } else if products.count < Self.maxProducts {
            // Pad with empty products to reach 12
            var paddedProducts = products
            while paddedProducts.count < Self.maxProducts {
                paddedProducts.append(Product())
            }
            self.products = paddedProducts
        } else {
            self.products = Array(products.prefix(Self.maxProducts))
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
    
    init(id: UUID = UUID(), name: String = "", price: Double = 0, stock: Int = 0, lowStockThreshold: Int = 5, criticalStockThreshold: Int = 2, discountType: DiscountType = .none, discountValue: Double = 0, barcode: String = "", imageData: Data? = nil) {
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
        if stock <= criticalStockThreshold {
            return .red      // Critical - needs attention!
        } else if stock <= lowStockThreshold {
            return .orange   // Low - warning
        } else {
            return .gray     // Plenty - no attention needed
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

// MARK: - Order
struct Order: Identifiable, Codable, Equatable {
    let id: UUID
    var productId: UUID
    var productName: String
    var productBarcode: String  // Stored for receipts
    var buyerName: String
    var phoneNumber: String
    var address: String
    var platform: Platform
    var quantity: Int
    var pricePerUnit: Double
    var wasDiscounted: Bool  // Was this order placed with a discount?
    var paymentStatus: PaymentStatus
    var isFulfilled: Bool  // Simple: has order been completed/delivered?
    var timestamp: Date
    
    init(id: UUID = UUID(), productId: UUID, productName: String, productBarcode: String = "", buyerName: String, phoneNumber: String = "", address: String = "", platform: Platform, quantity: Int, pricePerUnit: Double, wasDiscounted: Bool = false, paymentStatus: PaymentStatus = .unset, isFulfilled: Bool = false, timestamp: Date = Date()) {
        self.id = id
        self.productId = productId
        self.productName = productName
        self.productBarcode = productBarcode
        self.buyerName = buyerName
        self.phoneNumber = phoneNumber
        self.address = address
        self.platform = platform
        self.quantity = quantity
        self.pricePerUnit = pricePerUnit
        self.wasDiscounted = wasDiscounted
        self.paymentStatus = paymentStatus
        self.isFulfilled = isFulfilled
        self.timestamp = timestamp
    }
    
    var hasBarcode: Bool {
        !productBarcode.isEmpty
    }
    
    var totalPrice: Double {
        Double(quantity) * pricePerUnit
    }
}
