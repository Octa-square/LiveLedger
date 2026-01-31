//
//  StockBadgeView.swift
//  LiveLedger
//
//  Customer-facing stock visibility badge with color coding and urgency messaging.
//

import SwiftUI

/// Badge color: >10 healthy (green), 6–10 low (yellow), 1–5 critical (red), 0 out of stock
func stockBadgeColor(for count: Int) -> Color {
    if count > 10 { return .green }
    if count > 5 { return .yellow }
    if count > 0 { return .red }
    return .gray
}

/// Urgency message and optional pulsing for stock badge
func stockBadgeMessage(for count: Int) -> String {
    if count > 10 { return "\(count) in stock" }
    if count > 5 { return "Only \(count) left!" }
    if count > 0 { return "Hurry! Only \(count) left!" }
    return "Out of Stock"
}

/// Should show pulsing animation (stock < 5 and > 0)
func stockBadgeShouldPulse(for count: Int) -> Bool {
    count > 0 && count < 5
}

// MARK: - Stock Badge View
struct StockBadgeView: View {
    let stockCount: Int
    var showToCustomers: Bool
    var theme: AppTheme? = nil
    
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        if !showToCustomers {
            EmptyView()
        } else {
            HStack(spacing: 4) {
                Image(systemName: "shippingbox")
                    .font(.system(size: 10, weight: .semibold))
                Text(stockBadgeMessage(for: stockCount))
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(stockBadgeColor(for: stockCount))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(stockBadgeColor(for: stockCount).opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(stockBadgeColor(for: stockCount).opacity(0.5), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            .scaleEffect(stockBadgeShouldPulse(for: stockCount) ? pulseScale : 1.0)
            .onAppear {
                guard stockBadgeShouldPulse(for: stockCount) else { return }
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    pulseScale = 1.08
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        StockBadgeView(stockCount: 12, showToCustomers: true)
        StockBadgeView(stockCount: 8, showToCustomers: true)
        StockBadgeView(stockCount: 3, showToCustomers: true)
        StockBadgeView(stockCount: 0, showToCustomers: true)
        StockBadgeView(stockCount: 5, showToCustomers: false)
    }
    .padding()
    .background(Color.gray.opacity(0.3))
}
