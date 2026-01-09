//
//  QuickAddView.swift
//  LiveLedger
//
//  Live Sales Tracker - Quick Add Product Grid (FAST TAP TO ADD)
//

import SwiftUI

struct QuickAddView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    var onLimitReached: () -> Void = {}
    var onProductSelected: (Product) -> Void = { _ in }  // Callback when product tapped
    @State private var editingProduct: Product?
    @State private var showMaxProductsAlert: Bool = false
    @State private var showCreateCatalogAlert: Bool = false
    @State private var showRenameCatalogAlert: Bool = false
    @State private var newCatalogName: String = ""
    @State private var newProductToAdd: Product?  // For adding new product with full edit sheet
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    // Count of non-empty products
    private var activeProductCount: Int {
        viewModel.products.filter { !$0.isEmpty }.count
    }
    
    // MARK: - Header Row
    private var headerRow: some View {
        HStack(spacing: 0) {
            catalogMenu
            Spacer()
            hintText
            addButton
        }
        .frame(maxWidth: .infinity)
    }
    
    // Catalog dropdown menu
    private var catalogMenu: some View {
        Menu {
            ForEach(viewModel.catalogs) { catalog in
                Button(catalog.name) { viewModel.selectCatalog(catalog) }
            }
            Divider()
            Button("✏️ Rename") {
                newCatalogName = viewModel.currentCatalogName
                showRenameCatalogAlert = true
            }
            Button("➕ New Catalog") {
                newCatalogName = "New Catalog"
                showCreateCatalogAlert = true
            }
            if viewModel.catalogs.count > 1, let current = viewModel.currentCatalog {
                Button("🗑️ Delete", role: .destructive) {
                    viewModel.deleteCatalog(current)
                }
            }
        } label: {
            HStack(spacing: 3) {
                Text(viewModel.currentCatalogName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                Text("(\(activeProductCount)/12)")
                    .font(.system(size: 9))
                    .foregroundColor(theme.textSecondary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 7))
                    .foregroundColor(theme.textSecondary)
            }
        }
    }
    
    // Hint text
    private var hintText: some View {
        Text(localization.localized(.tapSellHoldEdit))
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(theme.textMuted)
            .padding(.trailing, 8)
    }
    
    // Add button - opens full EditProductSheet for new product
    private var addButton: some View {
        Button {
            if activeProductCount >= 12 {
                showMaxProductsAlert = true
            } else {
                // Create a new empty product and open edit sheet
                newProductToAdd = Product(name: "", price: 0, stock: 0)
            }
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(
                    LinearGradient(colors: [theme.accentColor, theme.secondaryColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        }
    }
    
    // MARK: - Product tap handler
    private func handleProductTap(_ product: Product) {
        guard !product.isEmpty && product.stock > 0 else { return }
        
        if let user = authManager.currentUser, !user.canCreateOrder {
            onLimitReached()
            return
        }
        
        // Call callback to show popup at ContentView level
        onProductSelected(product)
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            headerRow
            
            HorizontalProductGrid(
                products: viewModel.products,
                theme: theme,
                onTap: handleProductTap,
                onLongPress: { editingProduct = $0 }
            )
        }
        .padding(10)
        .sheet(item: $editingProduct) { product in
            EditProductSheet(
                product: product,
                onSave: { updated in
                    viewModel.updateProduct(updated)
                    editingProduct = nil
                },
                onDelete: {
                    if let index = viewModel.products.firstIndex(where: { $0.id == product.id }) {
                        viewModel.products.remove(at: index)
                    }
                    editingProduct = nil
                },
                onCancel: {
                    editingProduct = nil
                },
                isPro: authManager.currentUser?.isPro ?? false
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .alert("Maximum Products Reached", isPresented: $showMaxProductsAlert) {
            Button("Create New Catalog") {
                newCatalogName = "New Catalog"
                showCreateCatalogAlert = true
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("This catalog has reached the maximum of 12 products. Create a new catalog for additional products, or remove unused products by long-pressing and selecting delete.")
        }
        .alert("Create New Catalog", isPresented: $showCreateCatalogAlert) {
            TextField("Catalog Name", text: $newCatalogName)
            Button("Create") {
                if !newCatalogName.isEmpty {
                    _ = viewModel.createCatalog(name: newCatalogName)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter a name for your new product catalog.")
        }
        .alert("Rename Catalog", isPresented: $showRenameCatalogAlert) {
            TextField("Catalog Name", text: $newCatalogName)
            Button("Save") {
                if !newCatalogName.isEmpty, let catalog = viewModel.currentCatalog {
                    viewModel.renameCatalog(catalog, to: newCatalogName)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter a new name for this catalog.")
        }
        .sheet(item: $newProductToAdd) { product in
            EditProductSheet(
                product: product,
                onSave: { savedProduct in
                    handleSaveNewProduct(savedProduct)
                },
                onDelete: {
                    newProductToAdd = nil
                },
                onCancel: {
                    newProductToAdd = nil
                },
                isPro: authManager.currentUser?.isPro ?? false
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Handle Save New Product
    private func handleSaveNewProduct(_ product: Product) {
        // Only save if product has a name
        guard !product.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            newProductToAdd = nil
            return
        }
        
        if let emptyIndex = viewModel.products.firstIndex(where: { $0.isEmpty }) {
            viewModel.products[emptyIndex] = product
        } else if viewModel.products.count < 12 {
            viewModel.products.append(product)
        }
        viewModel.saveData()
        newProductToAdd = nil
    }
}

// MARK: - Buyer Popup View
// Overlay that appears at bottom - adjusts position when keyboard appears
struct BuyerPopupView: View {
    let product: Product
    @Binding var buyerName: String
    @Binding var orderQuantity: Int
    let onCancel: () -> Void
    let onAdd: () -> Void
    
    @FocusState private var isBuyerNameFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var safeAreaBottom: CGFloat = 0
    
    var totalAmount: Double {
        product.finalPrice * Double(orderQuantity)
    }
    
    // Calculate bottom padding: popup sits just above keyboard
    private var bottomPadding: CGFloat {
        if keyboardHeight > 0 {
            // Keyboard visible: position popup 10pt above keyboard
            // Subtract safe area because keyboard height includes it
            return keyboardHeight - safeAreaBottom + 10
        } else {
            // Keyboard hidden: 20pt from bottom of safe area
            return 20
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Semi-transparent backdrop - tap to dismiss (fills entire screen)
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isBuyerNameFocused = false
                        onCancel()
                    }
                    .onAppear {
                        safeAreaBottom = geometry.safeAreaInsets.bottom
                    }
            
            // Popup content - positioned at bottom, animates up when keyboard appears
            VStack(spacing: 10) {
                // Drag indicator
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                
                // Product name header
                Text(product.name.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                // Buyer name field
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    TextField("Buyer Name", text: $buyerName)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .focused($isBuyerNameFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            onAdd()
                        }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                
                // Quantity row
                HStack(spacing: 16) {
                    Button { if orderQuantity > 1 { orderQuantity -= 1 } } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(orderQuantity > 1 ? .blue : .gray.opacity(0.3))
                    }
                    
                    Text("\(orderQuantity)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 32)
                    
                    Button { if orderQuantity < product.stock { orderQuantity += 1 } } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(orderQuantity < product.stock ? .blue : .gray.opacity(0.3))
                    }
                    
                    Spacer()
                    
                    Text("$\(totalAmount, specifier: "%.0f")")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.green)
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    Button {
                        isBuyerNameFocused = false
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                    }
                    
                    Button {
                        isBuyerNameFocused = false
                        onAdd()
                    } label: {
                        Text("Add")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(white: 0.15))
                    .shadow(color: .black.opacity(0.3), radius: 10)
            )
            .padding(.horizontal, 16)
            // Position: sits directly above keyboard with 10pt gap, or 20pt from bottom when no keyboard
            .padding(.bottom, bottomPadding)
            .animation(.easeOut(duration: 0.25), value: keyboardHeight)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            // Listen for keyboard show/hide
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                keyboardHeight = 0
            }
            // Auto-focus the text field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isBuyerNameFocused = true
            }
        }
    }
}

// Horizontal scrolling product grid - 4 products visible, aligned with platform buttons
// Uses SAME width calculation as PlatformSelectorView for pixel-perfect alignment
struct HorizontalProductGrid: View {
    let products: [Product]
    let theme: AppTheme
    let onTap: (Product) -> Void
    let onLongPress: (Product) -> Void
    
    // ALIGNMENT CONSTANTS - Must match PlatformSelectorView exactly
    private let maxProducts = 12
    private let visibleCount: CGFloat = 4
    private let itemSpacing: CGFloat = 8    // 8pt between items (tighter)
    private let cardHeight: CGFloat = 58    // Product card height (bigger to fit content)
    
    var body: some View {
        let displayProducts = Array(products.prefix(maxProducts))
        let hasMoreProducts = displayProducts.count > Int(visibleCount)
        
        VStack(spacing: 2) {
            GeometryReader { geo in
                let availableWidth = geo.size.width
                let totalSpacing = itemSpacing * (visibleCount - 1) // 36pt for 3 gaps
                let itemWidth = (availableWidth - totalSpacing) / visibleCount
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: itemSpacing) {
                        ForEach(displayProducts, id: \.id) { product in
                            FastProductCard(
                                product: product,
                                theme: theme,
                                onTap: { onTap(product) },
                                onLongPress: { onLongPress(product) }
                            )
                            .frame(width: itemWidth, height: cardHeight)
                        }
                    }
                }
                .frame(width: availableWidth) // Clip to exactly 4 items width
            }
            .frame(height: cardHeight)
            
            // Scroll indicator - ALWAYS visible (permanent)
            HStack(spacing: 4) {
                Spacer()
                
                // Page dots - show based on product count
                let pageCount = max(1, min((displayProducts.count - 1) / Int(visibleCount) + 1, 4))
                ForEach(0..<pageCount, id: \.self) { index in
                    Circle()
                        .fill(index == 0 ? theme.accentColor : Color.white.opacity(0.4))
                        .frame(width: 5, height: 5)
                }
                
                // Scroll arrow indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(hasMoreProducts ? theme.textMuted : theme.textMuted.opacity(0.3))
                
                Spacer()
            }
        }
    }
}

// Keep old FlexibleProductGrid for backwards compatibility
struct FlexibleProductGrid: View {
    let products: [Product]
    let theme: AppTheme
    let onTap: (Product) -> Void
    let onLongPress: (Product) -> Void
    
    // Max 12 products, max 4 per row
    private let maxProducts = 12
    private let maxPerRow = 4
    private let spacing: CGFloat = 6
    
    var body: some View {
        let displayProducts = Array(products.prefix(maxProducts))
        
        GeometryReader { geometry in
            let totalSpacing = spacing * CGFloat(maxPerRow - 1)
            let cardWidth = (geometry.size.width - totalSpacing) / CGFloat(maxPerRow)
            let rows = createRows(from: displayProducts)
            
            VStack(spacing: spacing) {
                ForEach(0..<rows.count, id: \.self) { rowIndex in
                    HStack(spacing: spacing) {
                        ForEach(rows[rowIndex], id: \.id) { product in
                            FastProductCard(
                                product: product,
                                theme: theme,
                                onTap: { onTap(product) },
                                onLongPress: { onLongPress(product) }
                            )
                            .frame(width: cardWidth, height: 65)
                        }
                        
                        // Fill empty spaces in incomplete rows
                        if rows[rowIndex].count < maxPerRow {
                            ForEach(0..<(maxPerRow - rows[rowIndex].count), id: \.self) { index in
                                Color.clear.frame(width: cardWidth, height: 65)
                            }
                        }
                    }
                }
            }
        }
        .frame(height: calculateHeight(for: displayProducts.count))
    }
    
    private func calculateHeight(for productCount: Int) -> CGFloat {
        let rowCount = ceil(Double(productCount) / Double(maxPerRow))
        let cardHeight: CGFloat = 65
        return CGFloat(rowCount) * cardHeight + CGFloat(max(0, Int(rowCount) - 1)) * spacing
    }
    
    private func createRows(from displayProducts: [Product]) -> [[Product]] {
        guard !displayProducts.isEmpty else { return [] }
        
        var rows: [[Product]] = []
        var currentRow: [Product] = []
        
        for product in displayProducts {
            currentRow.append(product)
            if currentRow.count == maxPerRow {
                rows.append(currentRow)
                currentRow = []
            }
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
}

// Compact product cards - fits 4 per row - FIXED SIZE
struct FastProductCard: View {
    let product: Product
    let theme: AppTheme
    let onTap: () -> Void
    let onLongPress: () -> Void
    @ObservedObject var localization = LocalizationManager.shared
    
    @State private var isPressed = false
    
    // Format price - show with commas, only abbreviate very large numbers
    private var formattedPrice: String {
        let price = product.finalPrice
        if price >= 1_000_000 {
            return "$\(String(format: "%.1fM", price / 1_000_000))"
        } else if price >= 100_000 {
            return "$\(String(format: "%.0fK", price / 1_000))"
        } else {
            // Show full price with commas (up to $99,999)
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            let formatted = formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
            return "$\(formatted)"
        }
    }
    
    var body: some View {
        Button(action: {}) {
            GeometryReader { geo in
                ZStack {
                    if product.isEmpty {
                        // Empty product state - simple "Hold to add product" text
                        VStack(spacing: 4) {
                            Image(systemName: "plus.circle.dashed")
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(theme.textMuted.opacity(0.4))
                            
                            Text(localization.localized(.holdToAddProduct))
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(theme.textMuted.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    } else if let imageData = product.imageData, let uiImage = UIImage(data: imageData) {
                        // WITH IMAGE - image fills card
                        ZStack {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                            
                            // Gradient overlay
                            LinearGradient(
                                colors: [.black.opacity(0.7), .black.opacity(0.3), .black.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            
                            // Content - Name (big) → Price (medium) → Stock (small)
                            VStack(spacing: 2) {
                                // Name - LARGEST (ALL CAPS, 2 lines)
                                Text(product.name.uppercased())
                                    .font(.system(size: 12, weight: .heavy))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                    .multilineTextAlignment(.center)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                                    .frame(width: geo.size.width - 6)
                                
                                // Price - MEDIUM (abbreviated for large numbers)
                                Text(formattedPrice)
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(product.hasDiscount ? .orange : .green)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                                    .lineLimit(1)
                                
                                // Stock (color shows status)
                                Text("\(product.stock)")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(product.stockColor)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    } else {
                        // NO IMAGE - Name (big) → Price (medium) → Stock
                        VStack(spacing: 2) {
                            // Name - LARGEST (ALL CAPS, 2 lines)
                            Text(product.name.uppercased())
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundColor(theme.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .multilineTextAlignment(.center)
                                .frame(width: geo.size.width - 6)
                            
                            // Price - MEDIUM (abbreviated for large numbers)
                            Text(formattedPrice)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(product.hasDiscount ? theme.warningColor : theme.successColor)
                                .lineLimit(1)
                            
                            // Stock (color shows status)
                            Text("\(product.stock)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(product.stockColor)
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.cardBackgroundWithOpacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        product.stock == 0 && !product.isEmpty ? theme.dangerColor.opacity(0.5) : theme.cardBorder,
                        lineWidth: 1
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(product.stock == 0 && !product.isEmpty ? 0.5 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { value in
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    onLongPress()
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
                        isPressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                        isPressed = false
                        onTap()
                    }
                }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(product.isEmpty ? localization.localized(.holdToAddProduct) : "\(product.name), \(formattedPrice), \(product.stock) \(localization.localized(.stock))")
        .accessibilityHint(product.isEmpty ? "Long press to add a new product" : "Tap to add order, long press to edit")
    }
}

// Add Order Sheet - with buyer name and quantity
struct AddOrderSheet: View {
    let product: Product
    @Binding var buyerName: String
    @Binding var quantity: Int
    let maxStock: Int
    let theme: AppTheme
    let onCancel: () -> Void
    let onAdd: () -> Void
    
    var totalPrice: Double {
        product.finalPrice * Double(quantity)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Product info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name.uppercased())
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(theme.textPrimary)
                        Text("$\(product.finalPrice, specifier: "%.2f") each")
                            .font(.system(size: 14))
                            .foregroundColor(theme.textSecondary)
                    }
                    Spacer()
                    Text("Stock: \(maxStock)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(product.stockColor)
                }
                .padding()
                .background(theme.cardBackground)
                .cornerRadius(10)
                
                // Buyer Name
                VStack(alignment: .leading, spacing: 6) {
                    Text("BUYER NAME")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(theme.textSecondary)
                    TextField("Enter buyer name", text: $buyerName)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                }
                
                // Quantity Selector
                VStack(alignment: .leading, spacing: 6) {
                    Text("QUANTITY")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(theme.textSecondary)
                    
                    HStack(spacing: 20) {
                        // Minus button
                        Button {
                            if quantity > 1 { quantity -= 1 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(quantity > 1 ? theme.accentColor : theme.textMuted)
                        }
                        .disabled(quantity <= 1)
                        
                        // Quantity display
                        Text("\(quantity)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .frame(minWidth: 50)
                        
                        // Plus button
                        Button {
                            if quantity < maxStock { quantity += 1 }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(quantity < maxStock ? theme.accentColor : theme.textMuted)
                        }
                        .disabled(quantity >= maxStock)
                        
                        Spacer()
                        
                        // Total
                        VStack(alignment: .trailing) {
                            Text("TOTAL")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(theme.textSecondary)
                            Text("$\(totalPrice, specifier: "%.2f")")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(theme.successColor)
                        }
                    }
                    .padding()
                    .background(theme.cardBackground)
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { onAdd() }
                        .fontWeight(.bold)
                }
            }
        }
    }
}

struct EditProductSheet: View {
    @State var product: Product
    let onSave: (Product) -> Void
    let onDelete: () -> Void
    let onCancel: () -> Void
    var isPro: Bool = false
    
    @State private var stockText = ""
    @State private var priceText = ""
    @State private var discountText = ""
    @State private var lowStockText = ""
    @State private var criticalStockText = ""
    @State private var showImagePicker = false
    @State private var showBarcodeScanner = false
    @State private var showProAlert = false
    @State private var showAbbreviateAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Product Image (Pro Feature)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("PRODUCT IMAGE")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            if !isPro {
                                Label("PRO", systemImage: "crown.fill")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        HStack(spacing: 12) {
                            // Image preview
                            if let imageData = product.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray5))
                                        .frame(width: 80, height: 80)
                                    Image(systemName: "photo")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Button {
                                    if isPro {
                                        showImagePicker = true
                                    } else {
                                        showProAlert = true
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "photo.badge.plus")
                                        Text(product.imageData == nil ? "Add Image" : "Change Image")
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(isPro ? .blue : .gray)
                                }
                                
                                if product.imageData != nil {
                                    Button {
                                        product.imageData = nil
                                    } label: {
                                        HStack {
                                            Image(systemName: "trash")
                                            Text("Remove")
                                        }
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.red)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Product Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PRODUCT")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text("Name").foregroundColor(.gray).frame(width: 70, alignment: .leading)
                                TextField("Name (max 15)", text: $product.name)
                                    .textFieldStyle(.roundedBorder)
                                    .onChange(of: product.name) { _, newValue in
                                        if newValue.count > 15 {
                                            product.name = String(newValue.prefix(15))
                                            showAbbreviateAlert = true
                                        }
                                    }
                                Text("\(product.name.count)/15")
                                    .font(.system(size: 10))
                                    .foregroundColor(product.name.count >= 15 ? .red : .gray)
                            }
                            HStack {
                                Text("Price $").foregroundColor(.gray).frame(width: 70, alignment: .leading)
                                TextField("0", text: $priceText).textFieldStyle(.roundedBorder).keyboardType(.decimalPad)
                                    .onChange(of: priceText) { _, v in if let d = Double(v) { product.price = d } }
                            }
                            HStack {
                                Text("Stock").foregroundColor(.gray).frame(width: 70, alignment: .leading)
                                TextField("0", text: $stockText).textFieldStyle(.roundedBorder).keyboardType(.numberPad)
                                    .onChange(of: stockText) { _, v in if let i = Int(v) { product.stock = i } }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Barcode (Pro Feature)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("BARCODE")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            if !isPro {
                                Label("PRO", systemImage: "crown.fill")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        VStack(spacing: 10) {
                            HStack {
                                TextField("Enter or scan barcode", text: $product.barcode)
                                    .textFieldStyle(.roundedBorder)
                                    .disabled(!isPro)
                                
                                Button {
                                    if isPro {
                                        showBarcodeScanner = true
                                    } else {
                                        showProAlert = true
                                    }
                                } label: {
                                    Image(systemName: "barcode.viewfinder")
                                        .font(.system(size: 20))
                                        .foregroundColor(isPro ? .blue : .gray)
                                        .frame(width: 44, height: 36)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                            }
                            
                            if product.hasBarcode {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Barcode saved - will appear on receipts")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Discount
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DISCOUNT")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 10) {
                            Picker("Type", selection: $product.discountType) {
                                ForEach(DiscountType.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                            }.pickerStyle(.segmented)
                            
                            if product.discountType != .none {
                                HStack {
                                    Text(product.discountType == .percentage ? "%" : "$")
                                        .foregroundColor(.gray).frame(width: 30)
                                    TextField("0", text: $discountText).textFieldStyle(.roundedBorder).keyboardType(.decimalPad)
                                        .onChange(of: discountText) { _, v in if let d = Double(v) { product.discountValue = d } }
                                    Text("= $\(product.finalPrice, specifier: "%.2f")").foregroundColor(.orange).fontWeight(.bold)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Alerts
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ALERTS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 10) {
                            HStack {
                                Circle().fill(Color.orange).frame(width: 8, height: 8)
                                Text("Low").foregroundColor(.gray).frame(width: 60, alignment: .leading)
                                TextField("5", text: $lowStockText).textFieldStyle(.roundedBorder).keyboardType(.numberPad)
                                    .onChange(of: lowStockText) { _, v in if let i = Int(v) { product.lowStockThreshold = max(1, i) } }
                            }
                            HStack {
                                Circle().fill(Color.red).frame(width: 8, height: 8)
                                Text("Critical").foregroundColor(.gray).frame(width: 60, alignment: .leading)
                                TextField("2", text: $criticalStockText).textFieldStyle(.roundedBorder).keyboardType(.numberPad)
                                    .onChange(of: criticalStockText) { _, v in if let i = Int(v) { product.criticalStockThreshold = max(0, i) } }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    Button(role: .destructive) { onDelete() } label: {
                        HStack { Image(systemName: "trash"); Text("Delete") }
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.red.opacity(0.1)).foregroundColor(.red).cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: onCancel) }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { onSave(product) }.fontWeight(.semibold) }
            }
            .onAppear {
                stockText = product.stock > 0 ? "\(product.stock)" : ""
                priceText = product.price > 0 ? String(format: "%.2f", product.price) : ""
                discountText = product.discountValue > 0 ? String(format: "%.0f", product.discountValue) : ""
                lowStockText = "\(product.lowStockThreshold)"
                criticalStockText = "\(product.criticalStockThreshold)"
            }
            .sheet(isPresented: $showImagePicker) {
                ProductImagePicker { image in
                    if let data = image.jpegData(compressionQuality: 0.6) {
                        product.imageData = data
                    }
                }
            }
            .sheet(isPresented: $showBarcodeScanner) {
                BarcodeScannerView(scannedCode: $product.barcode) { code in
                    product.barcode = code
                }
            }
            .alert("Pro Feature", isPresented: $showProAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Product images and barcode scanning are Pro features. Upgrade to access these features.")
            }
            .alert("Name Too Long", isPresented: $showAbbreviateAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Product name is limited to 15 characters. Please abbreviate your product name.")
            }
        }
    }
}

// MARK: - Product Image Picker
struct ProductImagePicker: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ProductImagePicker
        
        init(_ parent: ProductImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let edited = info[.editedImage] as? UIImage {
                parent.onImageSelected(edited)
            } else if let original = info[.originalImage] as? UIImage {
                parent.onImageSelected(original)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        QuickAddView(viewModel: SalesViewModel(), themeManager: ThemeManager(), authManager: AuthManager(), localization: LocalizationManager.shared)
            .padding()
    }
}
