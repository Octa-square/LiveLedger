//
//  TikTokLiveOverlay.swift
//  LiveLedger
//
//  TikTok Live Floating Overlay - Draggable, Resizable, Timer-Triggered
//

import SwiftUI
import AVKit
import Combine

// MARK: - TikTok Live Overlay Manager
class TikTokLiveOverlayManager: ObservableObject {
    static let shared = TikTokLiveOverlayManager()
    
    @Published var isOverlayVisible: Bool = false
    @Published var overlayPosition: CGPoint = CGPoint(x: 100, y: 200)
    @Published var overlayTransparency: Double = 0.85
    @Published var overlayScale: CGFloat = 1.0
    @Published var isExpanded: Bool = false
    @Published var autoShowOnTimerStart: Bool = true
    
    // Size constraints
    let minScale: CGFloat = 0.6
    let maxScale: CGFloat = 1.5
    
    private init() {
        loadSettings()
    }
    
    func loadSettings() {
        let savedTransparency = UserDefaults.standard.double(forKey: "tiktokOverlayTransparency")
        overlayTransparency = savedTransparency > 0 ? savedTransparency : 0.85
        
        let savedX = UserDefaults.standard.double(forKey: "overlayPositionX")
        let savedY = UserDefaults.standard.double(forKey: "overlayPositionY")
        if savedX > 0 && savedY > 0 {
            overlayPosition = CGPoint(x: savedX, y: savedY)
        }
        
        let savedScale = UserDefaults.standard.double(forKey: "overlayScale")
        overlayScale = savedScale > 0 ? CGFloat(savedScale) : 1.0
        
        autoShowOnTimerStart = UserDefaults.standard.object(forKey: "autoShowOverlayOnTimer") as? Bool ?? true
    }
    
    func saveSettings() {
        UserDefaults.standard.set(overlayTransparency, forKey: "tiktokOverlayTransparency")
        UserDefaults.standard.set(overlayPosition.x, forKey: "overlayPositionX")
        UserDefaults.standard.set(overlayPosition.y, forKey: "overlayPositionY")
        UserDefaults.standard.set(Double(overlayScale), forKey: "overlayScale")
        UserDefaults.standard.set(autoShowOnTimerStart, forKey: "autoShowOverlayOnTimer")
    }
    
    func showOverlay() {
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                self.isOverlayVisible = true
            }
        }
    }
    
    func hideOverlay() {
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                self.isOverlayVisible = false
                self.isExpanded = false
            }
        }
    }
    
    func toggleExpanded() {
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                self.isExpanded.toggle()
            }
        }
    }
    
    // Called when timer starts - auto-shows overlay if enabled
    func onTimerStart() {
        if autoShowOnTimerStart {
            showOverlay()
        }
    }
    
    // Called when timer stops
    func onTimerStop() {
        // Optionally hide overlay when timer stops
        // For now, keep it visible so user can continue adding orders
    }
}

// MARK: - TikTok Live Floating Overlay View
struct TikTokLiveOverlayView: View {
    @StateObject private var overlayManager = TikTokLiveOverlayManager.shared
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    
    @State private var dragOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var showProductsSheet: Bool = false
    @State private var showPlatformsSheet: Bool = false
    @State private var selectedProduct: Product?
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    var body: some View {
        // Only render when visible - don't block content when hidden
        if overlayManager.isOverlayVisible {
            GeometryReader { geometry in
                // Overlay widget - positioned absolutely
                VStack(spacing: 0) {
                    if overlayManager.isExpanded {
                        expandedView
                    } else {
                        compactView
                    }
                }
                .scaleEffect(overlayManager.overlayScale * currentScale)
                .background(
                    RoundedRectangle(cornerRadius: overlayManager.isExpanded ? 16 : 24)
                        .fill(theme.cardBackground.opacity(overlayManager.overlayTransparency))
                        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: overlayManager.isExpanded ? 16 : 24)
                        .strokeBorder(theme.accentColor.opacity(0.3), lineWidth: 1)
                )
                .contentShape(RoundedRectangle(cornerRadius: overlayManager.isExpanded ? 16 : 24))  // Define hit testing area BEFORE gestures
                .position(
                    x: clampPosition(overlayManager.overlayPosition.x + dragOffset.width, maxValue: geometry.size.width),
                    y: clampPosition(overlayManager.overlayPosition.y + dragOffset.height, maxValue: geometry.size.height)
                )
                // Drag gesture for moving
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            overlayManager.overlayPosition.x += value.translation.width
                            overlayManager.overlayPosition.y += value.translation.height
                            // Clamp position to screen bounds
                            overlayManager.overlayPosition.x = clampPosition(overlayManager.overlayPosition.x, maxValue: geometry.size.width)
                            overlayManager.overlayPosition.y = clampPosition(overlayManager.overlayPosition.y, maxValue: geometry.size.height)
                            dragOffset = .zero
                            overlayManager.saveSettings()
                        }
                )
                // Pinch gesture for resizing
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            currentScale = value
                        }
                        .onEnded { value in
                            let newScale = overlayManager.overlayScale * value
                            overlayManager.overlayScale = Swift.min(Swift.max(newScale, overlayManager.minScale), overlayManager.maxScale)
                            currentScale = 1.0
                            overlayManager.saveSettings()
                        }
                )
            }
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    // Clamp position to keep overlay on screen
    private func clampPosition(_ value: CGFloat, maxValue: CGFloat) -> CGFloat {
        let padding: CGFloat = 50
        return Swift.min(Swift.max(value, padding), maxValue - padding)
    }
    
    // Compact floating button with close button
    private var compactView: some View {
        HStack(spacing: 6) {
            // Main tap area to expand
            Button {
                overlayManager.toggleExpanded()
            } label: {
                HStack(spacing: 8) {
                    // LiveLedger mini logo
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.05, green: 0.59, blue: 0.41), Color(red: 0.04, green: 0.47, blue: 0.34)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                        
                        ZStack(alignment: .topTrailing) {
                            Text("L")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("²")
                                .font(.system(size: 8, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .offset(x: 4, y: -1)
                        }
                    }
                    
                    // Quick info
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 6, height: 6)
                            Text("LIVE")
                                .font(.system(size: 8, weight: .heavy))
                                .foregroundColor(.red)
                        }
                        Text("\(viewModel.orders.count) orders")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(theme.textSecondary)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Close/Hide button
            Button {
                overlayManager.hideOverlay()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(theme.textMuted.opacity(0.7))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    // Expanded quick-add interface
    private var expandedView: some View {
        VStack(spacing: 10) {
            // Header with close and hide buttons
            HStack {
                Text("Quick Add")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                // Collapse button
                Button {
                    overlayManager.toggleExpanded()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(theme.textMuted)
                }
                
                // Close/Hide button
                Button {
                    overlayManager.hideOverlay()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(theme.textMuted)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            
            // Resize hint
            Text("Pinch to resize • Drag to move")
                .font(.system(size: 8))
                .foregroundColor(theme.textMuted.opacity(0.6))
            
            // Quick action buttons
            HStack(spacing: 10) {
                QuickActionButton(
                    icon: "bag.fill",
                    label: "Products",
                    color: .blue
                ) {
                    showProductsSheet = true
                }
                
                QuickActionButton(
                    icon: "iphone",
                    label: "Platform",
                    color: .purple
                ) {
                    showPlatformsSheet = true
                }
            }
            .padding(.horizontal, 14)
            
            // Quick product grid
            VStack(alignment: .leading, spacing: 4) {
                Text("QUICK SELL")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(theme.textMuted)
                    .padding(.horizontal, 14)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(viewModel.products.filter { !$0.isEmpty && $0.stock > 0 }.prefix(6)) { product in
                            QuickProductChip(product: product, theme: theme) {
                                selectedProduct = product
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                }
            }
            
            // Current session stats
            HStack(spacing: 12) {
                StatBadge(value: "\(viewModel.orders.count)", label: "Orders", color: .blue)
                StatBadge(value: "$\(Int(viewModel.totalRevenue))", label: "Total", color: .green)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
        }
        .frame(width: 240)
        .sheet(isPresented: $showProductsSheet) {
            QuickProductsSheet(viewModel: viewModel, themeManager: themeManager)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showPlatformsSheet) {
            QuickPlatformsSheet(viewModel: viewModel, themeManager: themeManager)
                .presentationDetents([.height(250)])
        }
        .sheet(item: $selectedProduct) { product in
            QuickOrderSheet(
                product: product,
                viewModel: viewModel,
                themeManager: themeManager
            )
            .presentationDetents([.height(300)])
        }
    }
}

// MARK: - Overlay Control Button (for use in main app)
struct OverlayControlButton: View {
    @StateObject private var overlayManager = TikTokLiveOverlayManager.shared
    
    var body: some View {
        Button {
            if overlayManager.isOverlayVisible {
                overlayManager.hideOverlay()
            } else {
                overlayManager.showOverlay()
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: overlayManager.isOverlayVisible ? "pip.exit" : "pip.enter")
                    .font(.system(size: 12))
                Text(overlayManager.isOverlayVisible ? "Hide Overlay" : "Show Overlay")
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(overlayManager.isOverlayVisible ? Color.orange : Color.green)
            )
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(color)
                    .cornerRadius(10)
                
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quick Product Chip
struct QuickProductChip: View {
    let product: Product
    let theme: AppTheme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(product.name.prefix(6).uppercased())
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                
                Text("$\(Int(product.finalPrice))")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(theme.successColor)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(theme.cardBackground)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(theme.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Quick Products Sheet
struct QuickProductsSheet: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedProduct: Product?
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                    ForEach(viewModel.products.filter { !$0.isEmpty }) { product in
                        Button {
                            selectedProduct = product
                        } label: {
                            VStack(spacing: 4) {
                                if let imageData = product.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(theme.cardBackground)
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Text(product.name.prefix(2).uppercased())
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(theme.textMuted)
                                        )
                                }
                                
                                Text(product.name)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(theme.textPrimary)
                                    .lineLimit(1)
                                
                                Text("$\(Int(product.finalPrice))")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(theme.successColor)
                                
                                Text("Stock: \(product.stock)")
                                    .font(.system(size: 8))
                                    .foregroundColor(product.stockColor)
                            }
                            .padding(8)
                            .background(theme.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(product.stock == 0 ? Color.red.opacity(0.5) : theme.cardBorder, lineWidth: 1)
                            )
                            .opacity(product.stock == 0 ? 0.5 : 1)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(product.stock == 0)
                    }
                }
                .padding()
            }
            .navigationTitle("Quick Select")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(item: $selectedProduct) { product in
                QuickOrderSheet(product: product, viewModel: viewModel, themeManager: themeManager)
                    .presentationDetents([.height(300)])
            }
        }
    }
}

// MARK: - Quick Platforms Sheet
struct QuickPlatformsSheet: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Select Platform")
                    .font(.headline)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                    ForEach(viewModel.platforms) { platform in
                        Button {
                            viewModel.selectedPlatform = platform
                            dismiss()
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: platform.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(platform.swiftUIColor)
                                
                                Text(platform.name)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(theme.textPrimary)
                            }
                            .frame(width: 70, height: 60)
                            .background(
                                viewModel.selectedPlatform?.id == platform.id
                                    ? platform.swiftUIColor.opacity(0.15)
                                    : theme.cardBackground
                            )
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(
                                        viewModel.selectedPlatform?.id == platform.id
                                            ? platform.swiftUIColor
                                            : theme.cardBorder,
                                        lineWidth: viewModel.selectedPlatform?.id == platform.id ? 2 : 1
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding(.top)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Quick Order Sheet
struct QuickOrderSheet: View {
    let product: Product
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    @State private var quantity: Int = 1
    @State private var buyerName: String = ""
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Product info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name.uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(theme.textPrimary)
                        Text("$\(product.finalPrice, specifier: "%.2f") each")
                            .font(.system(size: 13))
                            .foregroundColor(theme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text("Stock: \(product.stock)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(product.stockColor)
                }
                .padding()
                .background(theme.cardBackground)
                .cornerRadius(10)
                
                // Buyer name (optional)
                TextField("Buyer name (optional)", text: $buyerName)
                    .textFieldStyle(.roundedBorder)
                
                // Quantity selector
                HStack(spacing: 20) {
                    Button {
                        if quantity > 1 { quantity -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(quantity > 1 ? .blue : .gray.opacity(0.3))
                    }
                    
                    Text("\(quantity)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .frame(width: 50)
                    
                    Button {
                        if quantity < product.stock { quantity += 1 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(quantity < product.stock ? .blue : .gray.opacity(0.3))
                    }
                    
                    Spacer()
                    
                    // Total
                    VStack(alignment: .trailing) {
                        Text("TOTAL")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(theme.textSecondary)
                        Text("$\(product.finalPrice * Double(quantity), specifier: "%.2f")")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(theme.successColor)
                    }
                }
                .padding()
                .background(theme.cardBackground)
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let platform = viewModel.selectedPlatform ?? .all
                        let finalName = buyerName.isEmpty ? "SN-\(viewModel.orders.count + 1)" : buyerName
                        
                        viewModel.createOrder(
                            product: product,
                            buyerName: finalName,
                            phoneNumber: "",
                            address: "",
                            platform: platform,
                            quantity: quantity
                        )
                        
                        // Play sound
                        SoundManager.shared.playOrderAddedSound()
                        
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        
        TikTokLiveOverlayView(
            viewModel: SalesViewModel(),
            themeManager: ThemeManager()
        )
    }
}
