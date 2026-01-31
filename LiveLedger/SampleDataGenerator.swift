//
//  SampleDataGenerator.swift
//  LiveLedger
//
//  Generates sample products with images and orders for Apple Review test account.
//  Only used when applereview@liveledger.com logs in (Apple review test account only).
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum SampleDataGenerator {

    /// The ONE test account email that receives sample data on first login. No other emails trigger sample data.
    private static let reviewAccountEmail = "applereview@liveledger.com"

    /// Returns true ONLY for applereview@liveledger.com (exact, case-insensitive). No other emails trigger sample data.
    static func isReviewAccount(_ email: String) -> Bool {
        email.lowercased() == reviewAccountEmail
    }

    /// UserDefaults key: sample data loaded once per device for test account
    private static let sampleDataLoadedKey = "sample_data_loaded_for_review_account"

    /// Returns true if sample data has already been loaded (so we only load once).
    static func hasLoadedSampleData() -> Bool {
        let value = UserDefaults.standard.bool(forKey: sampleDataLoadedKey)
        print("[SampleData] Checking UserDefaults \(sampleDataLoadedKey): \(value)")
        return value
    }

    /// Call after creating and saving sample products/orders so we don't reload on next login.
    static func markSampleDataLoaded() {
        UserDefaults.standard.set(true, forKey: sampleDataLoadedKey)
    }

    /// Generates 5 sample products. For review account: always include images (display is gated by isPro in UI).
    static func makeReviewProducts(isPro: Bool) -> [Product] {
        let blueTshirt = Product(
            name: "Blue Cotton T-Shirt",
            price: 29.99,
            stock: 15,
            lowStockThreshold: 5,
            criticalStockThreshold: 2,
            barcode: "123456789012",
            imageData: isPro ? generateProductImage(symbolName: "tshirt.fill", color: platformBlue) : nil
        )
        let redHoodie = Product(
            name: "Red Hoodie",
            price: 49.99,
            stock: 8,
            lowStockThreshold: 4,
            criticalStockThreshold: 2,
            barcode: "123456789013",
            imageData: isPro ? generateProductImage(symbolName: "tshirt.fill", color: platformRed) : nil
        )
        let blackCap = Product(
            name: "Black Baseball Cap",
            price: 19.99,
            stock: 25,
            lowStockThreshold: 8,
            criticalStockThreshold: 3,
            barcode: "123456789014",
            imageData: isPro ? generateProductImage(symbolName: "crown.fill", color: platformBlack) : nil
        )
        let whiteSneakers = Product(
            name: "White Sneakers",
            price: 79.99,
            stock: 3,
            lowStockThreshold: 5,
            criticalStockThreshold: 2,
            barcode: "123456789015",
            imageData: isPro ? generateProductImage(symbolName: "figure.walk", color: platformGray) : nil
        )
        let denimJacket = Product(
            name: "Denim Jacket",
            price: 89.99,
            stock: 12,
            lowStockThreshold: 4,
            criticalStockThreshold: 2,
            barcode: "123456789016",
            imageData: isPro ? generateProductImage(symbolName: "jacket.fill", color: platformDenim) : nil
        )
        return [blueTshirt, redHoodie, blackCap, whiteSneakers, denimJacket]
    }

    #if canImport(UIKit)
    private static var platformBlue: UIColor { .systemBlue }
    private static var platformRed: UIColor { .systemRed }
    private static var platformBlack: UIColor { .black }
    private static var platformGray: UIColor { .systemGray5 }
    private static var platformDenim: UIColor { UIColor(red: 0.25, green: 0.35, blue: 0.6, alpha: 1) }
    #else
    private static var platformBlue: Color { .blue }
    private static var platformRed: Color { .red }
    private static var platformBlack: Color { .black }
    private static var platformGray: Color { .gray }
    private static var platformDenim: Color { Color(red: 0.25, green: 0.35, blue: 0.6) }
    #endif

    /// Generates sample orders for the review products.
    /// Order 5 is split into two orders (one product per order in app model).
    static func makeReviewOrders(products: [Product]) -> [Order] {
        guard products.count >= 5 else { return [] }
        let blueT = products[0]
        let redH = products[1]
        let blackC = products[2]
        let whiteS = products[3]
        let now = Date()
        let calendar = Calendar.current
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now) ?? now
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now) ?? now
        let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: now) ?? now
        let yesterday = oneDayAgo

        return [
            Order(
                productId: blueT.id,
                productName: blueT.name,
                productBarcode: blueT.barcode,
                buyerName: "Sarah Johnson",
                orderSource: .instagramDM,
                platform: .instagram,
                quantity: 2,
                pricePerUnit: blueT.finalPrice,
                paymentStatus: .paid,
                timestamp: threeDaysAgo
            ),
            Order(
                productId: redH.id,
                productName: redH.name,
                productBarcode: redH.barcode,
                buyerName: "Mike Chen",
                orderSource: .liveStream,
                platform: .tiktok,
                quantity: 1,
                pricePerUnit: redH.finalPrice,
                paymentStatus: .pending,
                timestamp: twoDaysAgo
            ),
            Order(
                productId: blackC.id,
                productName: blackC.name,
                productBarcode: blackC.barcode,
                buyerName: "Emma Davis",
                orderSource: .facebookDM,
                platform: .facebook,
                quantity: 3,
                pricePerUnit: blackC.finalPrice,
                paymentStatus: .paid,
                timestamp: oneDayAgo
            ),
            Order(
                productId: whiteS.id,
                productName: whiteS.name,
                productBarcode: whiteS.barcode,
                buyerName: "James Wilson",
                orderSource: .instagramDM,
                platform: .instagram,
                quantity: 1,
                pricePerUnit: whiteS.finalPrice,
                paymentStatus: .pending,
                timestamp: now
            ),
            Order(
                productId: blueT.id,
                productName: blueT.name,
                productBarcode: blueT.barcode,
                buyerName: "Lisa Martinez",
                orderSource: .liveStream,
                platform: .tiktok,
                quantity: 1,
                pricePerUnit: blueT.finalPrice,
                paymentStatus: .paid,
                timestamp: yesterday
            ),
            Order(
                productId: blackC.id,
                productName: blackC.name,
                productBarcode: blackC.barcode,
                buyerName: "Lisa Martinez",
                orderSource: .liveStream,
                platform: .tiktok,
                quantity: 2,
                pricePerUnit: blackC.finalPrice,
                paymentStatus: .paid,
                timestamp: yesterday
            ),
        ]
    }

    /// Renders a product image: colored rounded rect with SF Symbol. Returns PNG Data for Product.imageData.
    #if canImport(UIKit)
    static func generateProductImage(symbolName: String, color: UIColor) -> Data? {
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 16)
            color.setFill()
            path.fill()
            let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .medium)
            guard let symbol = UIImage(systemName: symbolName, withConfiguration: config) else { return }
            let tinted = symbol.withTintColor(.white, renderingMode: .alwaysOriginal)
            let symbolSize = CGSize(width: 120, height: 120)
            let symbolRect = CGRect(
                x: (size.width - symbolSize.width) / 2,
                y: (size.height - symbolSize.height) / 2,
                width: symbolSize.width,
                height: symbolSize.height
            )
            tinted.draw(in: symbolRect)
        }
        return image.pngData()
    }
    #else
    static func generateProductImage(symbolName: String, color: Color) -> Data? {
        nil
    }
    #endif
}
