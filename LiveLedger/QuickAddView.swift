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
    var onUpgrade: (() -> Void)? = nil  // Show subscription when Pro feature tapped
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
                isPro: authManager.currentUser?.isPro ?? false,
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
                    viewModel.saveData()
                    editingProduct = nil
                },
                onDelete: {
                    if let index = viewModel.products.firstIndex(where: { $0.id == product.id }) {
                        var updated = viewModel.products
                        updated.remove(at: index)
                        viewModel.products = updated
                        viewModel.saveData()
                    }
                    editingProduct = nil
                },
                onCancel: {
                    editingProduct = nil
                },
                isPro: authManager.currentUser?.isPro ?? false,
                onUpgrade: onUpgrade,
                authManager: authManager
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
                isPro: authManager.currentUser?.isPro ?? false,
                onUpgrade: onUpgrade,
                authManager: authManager
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
// Overlay that appears at bottom - order entry with customer autocomplete, phone, notes, order source
struct BuyerPopupView: View {
    let product: Product
    @ObservedObject var viewModel: SalesViewModel
    @Binding var buyerName: String
    @Binding var orderQuantity: Int
    @Binding var phoneNumber: String
    @Binding var customerNotes: String
    @Binding var orderSource: OrderSource
    let onCancel: () -> Void
    let onAdd: () -> Void
    
    @FocusState private var isBuyerNameFocused: Bool
    @FocusState private var isQuantityFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var safeAreaBottom: CGFloat = 0
    @State private var quantityInput: String = "1"
    
    private var autocompleteSuggestions: [(name: String, phone: String, notes: String)] {
        viewModel.previousCustomers(prefix: buyerName)
    }
    
    var totalAmount: Double {
        product.finalPrice * Double(orderQuantity)
    }
    
    private var bottomPadding: CGFloat {
        if keyboardHeight > 0 {
            return keyboardHeight - safeAreaBottom + 10
        } else {
            return 20
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isBuyerNameFocused = false
                        onCancel()
                    }
                    .onAppear {
                        safeAreaBottom = geometry.safeAreaInsets.bottom
                    }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 40, height: 5)
                            .padding(.top, 8)
                        
                        Text(product.name.uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Customer name with autocomplete
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                TextField(LocalizationManager.shared.localized(.customerName), text: $buyerName)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .focused($isBuyerNameFocused)
                                    .submitLabel(.next)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            
                            if !autocompleteSuggestions.isEmpty && !buyerName.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(Array(autocompleteSuggestions.prefix(5).enumerated()), id: \.offset) { _, customer in
                                        Button {
                                            buyerName = customer.name
                                            phoneNumber = customer.phone
                                            customerNotes = customer.notes
                                            isBuyerNameFocused = false
                                        } label: {
                                            HStack {
                                                Text(customer.name)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.white)
                                                Spacer()
                                                if !customer.phone.isEmpty {
                                                    Text(customer.phone)
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.white.opacity(0.7))
                                                }
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                        }
                                        .background(Color.white.opacity(0.08))
                                    }
                                }
                                .cornerRadius(8)
                            }
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            TextField(LocalizationManager.shared.localized(.phoneOptional), text: $phoneNumber)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .keyboardType(.phonePad)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "note.text")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            TextField(LocalizationManager.shared.localized(.notesOptional), text: $customerNotes)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        
                        // Order source picker
                        Menu {
                            ForEach(OrderSource.allCases, id: \.self) { source in
                                Button(source.rawValue) { orderSource = source }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.triangle.branch")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Text("\(LocalizationManager.shared.localized(.orderSource)): \(orderSource.rawValue)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Quantity row - type or use +/-
                        HStack(spacing: 16) {
                            Button { if orderQuantity > 1 { orderQuantity -= 1; quantityInput = "\(orderQuantity)" } } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(orderQuantity > 1 ? .blue : .gray.opacity(0.3))
                            }
                            TextField("Qty", text: $quantityInput)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .frame(width: 64)
                                .focused($isQuantityFocused)
                                .onChange(of: quantityInput) { _, s in
                                    if s.isEmpty { orderQuantity = 1; return }
                                    let n = Int(s) ?? orderQuantity
                                    let clamped = min(max(n, 1), max(1, product.stock))
                                    orderQuantity = clamped
                                    if "\(clamped)" != s { quantityInput = "\(clamped)" }
                                }
                                .onChange(of: isQuantityFocused) { _, focused in
                                    if focused { quantityInput = "" }
                                    else if quantityInput.isEmpty { quantityInput = "1"; orderQuantity = 1 }
                                }
                            Button { if orderQuantity < product.stock { orderQuantity += 1; quantityInput = "\(orderQuantity)" } } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(orderQuantity < product.stock ? .blue : .gray.opacity(0.3))
                            }
                            Spacer()
                            Text("$\(totalAmount, specifier: "%.0f")")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .onAppear { quantityInput = "\(orderQuantity)" }
                        .onChange(of: orderQuantity) { _, v in if !isQuantityFocused { quantityInput = "\(v)" } }
                        
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
                }
                .frame(maxHeight: geometry.size.height * 0.7)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(white: 0.15))
                        .shadow(color: .black.opacity(0.3), radius: 10)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, bottomPadding)
                .animation(.easeOut(duration: 0.25), value: keyboardHeight)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
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
    let isPro: Bool
    let onTap: (Product) -> Void
    let onLongPress: (Product) -> Void
    
    private let maxProducts = 12
    private let itemSpacing: CGFloat = 8
    private let cardWidth: CGFloat = 84
    private let cardHeight: CGFloat = 58
    
    private var displayProducts: [Product] { Array(products.prefix(maxProducts)) }
    private var isEmpty: Bool { displayProducts.isEmpty }
    
    var body: some View {
        if isEmpty {
            Color.clear
                .frame(height: 0)
        } else {
            let hasMoreProducts = displayProducts.count > 4
            
            VStack(spacing: 2) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: itemSpacing) {
                        ForEach(displayProducts, id: \.id) { product in
                            FastProductCard(
                                product: product,
                                theme: theme,
                                isPro: isPro,
                                onTap: { onTap(product) },
                                onLongPress: { onLongPress(product) }
                            )
                            .frame(width: cardWidth, height: cardHeight)
                        }
                    }
                }
                .frame(height: cardHeight)
                
                // Scroll indicator - ALWAYS visible (permanent)
                HStack(spacing: 4) {
                    Spacer()
                    
                    // Page dots - show based on product count
                    let pageCount = max(1, min((displayProducts.count - 1) / 4 + 1, 4))
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
}

// Keep old FlexibleProductGrid for backwards compatibility - fixed layout, no GeometryReader
struct FlexibleProductGrid: View {
    let products: [Product]
    let theme: AppTheme
    let isPro: Bool
    let onTap: (Product) -> Void
    let onLongPress: (Product) -> Void
    
    private let maxProducts = 12
    private let maxPerRow = 4
    private let spacing: CGFloat = 6
    private let cardHeight: CGFloat = 65
    
    private var displayProducts: [Product] { Array(products.prefix(maxProducts)) }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: maxPerRow), spacing: spacing) {
            ForEach(displayProducts, id: \.id) { product in
                FastProductCard(
                    product: product,
                    theme: theme,
                    isPro: isPro,
                    onTap: { onTap(product) },
                    onLongPress: { onLongPress(product) }
                )
                .frame(height: cardHeight)
            }
        }
        .frame(height: calculateHeight(for: displayProducts.count))
    }
    
    private func calculateHeight(for productCount: Int) -> CGFloat {
        let rowCount = ceil(Double(productCount) / Double(maxPerRow))
        return CGFloat(rowCount) * cardHeight + CGFloat(max(0, Int(rowCount) - 1)) * spacing
    }
}

// Compact product cards - fits 4 per row - FIXED SIZE
struct FastProductCard: View {
    let product: Product
    let theme: AppTheme
    let isPro: Bool
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
            ZStack {
                if product.isEmpty {
                    // Empty product state - helpful copy
                    VStack(spacing: 6) {
                        Text("📦")
                            .font(.system(size: 22))
                        Image(systemName: "plus.circle.dashed")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(theme.textMuted.opacity(0.4))
                        Text(localization.localized(.holdToAddProduct))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(theme.textMuted.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if isPro, let imageData = product.imageData, let uiImage = UIImage(data: imageData) {
                    // WITH IMAGE - Pro only; image fills card
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
                        
                        // Content - Name (big) → Price (medium) → Stock badge or count
                        VStack(spacing: 2) {
                            Text(product.name.uppercased())
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                                .frame(maxWidth: .infinity)
                            
                            Text(formattedPrice)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(product.stock == 0 ? .gray : (product.hasDiscount ? .orange : .green))
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                                .lineLimit(1)
                            
                            Text("\(product.stock)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(product.stockColor)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                } else {
                    // NO IMAGE - Name (big) → Price (medium) → Stock badge or count
                    VStack(spacing: 2) {
                        Text(product.name.uppercased())
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(theme.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        Text(formattedPrice)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(product.stock == 0 ? theme.textMuted : (product.hasDiscount ? theme.warningColor : theme.successColor))
                            .lineLimit(1)
                        
                        Text("\(product.stock)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(product.stockColor)
                        if product.hasBarcode {
                            HStack(spacing: 2) {
                                Image(systemName: "barcode")
                                    .font(.system(size: 8))
                                Text(product.barcode)
                                    .font(.system(size: 8))
                                    .foregroundColor(theme.textMuted)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    @FocusState private var isQuantityFocused: Bool
    @State private var quantityInput: String = "1"
    
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
                
                // Quantity Selector - type or use +/-
                VStack(alignment: .leading, spacing: 6) {
                    Text("QUANTITY")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(theme.textSecondary)
                    
                    HStack(spacing: 20) {
                        Button {
                            if quantity > 1 { quantity -= 1; quantityInput = "\(quantity)" }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(quantity > 1 ? theme.accentColor : theme.textMuted)
                        }
                        .disabled(quantity <= 1)
                        
                        TextField("Qty", text: $quantityInput)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .frame(minWidth: 64)
                            .focused($isQuantityFocused)
                            .onChange(of: quantityInput) { _, s in
                                if s.isEmpty { quantity = 1; return }
                                let n = Int(s) ?? quantity
                                let clamped = min(max(n, 1), max(1, maxStock))
                                quantity = clamped
                                if "\(clamped)" != s { quantityInput = "\(clamped)" }
                            }
                            .onChange(of: isQuantityFocused) { _, focused in
                                if focused { quantityInput = "" }
                                else if quantityInput.isEmpty { quantityInput = "1"; quantity = 1 }
                            }
                        
                        Button {
                            if quantity < maxStock { quantity += 1; quantityInput = "\(quantity)" }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(quantity < maxStock ? theme.accentColor : theme.textMuted)
                        }
                        .disabled(quantity >= maxStock)
                        
                        Spacer()
                        
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
                    .onAppear { quantityInput = "\(quantity)" }
                    .onChange(of: quantity) { _, v in if !isQuantityFocused { quantityInput = "\(v)" } }
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
    var onUpgrade: (() -> Void)? = nil
    var authManager: AuthManager?
    
    @State private var stockText = ""
    @State private var priceText = ""
    @State private var discountText = ""
    @State private var lowStockText = ""
    @State private var criticalStockText = ""
    @State private var showImagePicker = false
    @State private var showProAlert = false
    @State private var showBarcodeProAlert = false
    @State private var showBarcodeScanner = false
    @State private var showAbbreviateAlert = false
    @State private var showSubscriptionView = false
    
    @ViewBuilder
    private var productImagePreview: some View {
        // Pro only: show image; Free users see placeholder (images hidden even if stored)
        if isPro, let imageData = product.imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
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
    }
    
    @ViewBuilder
    private var productImageButtons: some View {
        Button {
            if isPro { showImagePicker = true } else { showProAlert = true }
        } label: {
            HStack {
                Image(systemName: "photo.badge.plus")
                Text(product.imageData == nil ? "Add Image" : "Change Image")
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isPro ? .blue : .gray)
        }
        // Remove image only for Pro (Free users don't see image, so no Remove)
        if isPro && product.imageData != nil {
            Button {
                var updated = product
                updated.imageData = nil
                product = updated
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
    
    private var productImageSection: some View {
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
                productImagePreview
                VStack(alignment: .leading, spacing: 8) {
                    productImageButtons
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    private var productDetailsSection: some View {
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
    }
    
    private var barcodeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("BARCODE (OPTIONAL)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.gray)
                if !isPro {
                    Label("PRO", systemImage: "crown.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.orange)
                }
            }
            HStack(spacing: 10) {
                TextField("Enter or scan barcode", text: $product.barcode)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numbersAndPunctuation)
                if isPro {
                    Button { showBarcodeScanner = true } label: {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 22))
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                } else {
                    Button { showBarcodeProAlert = true } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "barcode.viewfinder")
                            Text("PRO").font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(8)
                    }
                }
            }
            if product.hasBarcode {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    Text("Barcode saved – will appear on receipts")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var discountSection: some View {
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
    }
    
    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ALERTS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.gray)
            VStack(spacing: 10) {
                HStack {
                    Circle().fill(Color.yellow).frame(width: 8, height: 8)
                    Text("Low").foregroundColor(.gray).frame(width: 60, alignment: .leading)
                    TextField("10", text: $lowStockText).textFieldStyle(.roundedBorder).keyboardType(.numberPad)
                        .onChange(of: lowStockText) { _, v in if let i = Int(v) { product.lowStockThreshold = max(1, i) } }
                }
                HStack {
                    Circle().fill(Color.red).frame(width: 8, height: 8)
                    Text("Critical").foregroundColor(.gray).frame(width: 60, alignment: .leading)
                    TextField("5", text: $criticalStockText).textFieldStyle(.roundedBorder).keyboardType(.numberPad)
                        .onChange(of: criticalStockText) { _, v in if let i = Int(v) { product.criticalStockThreshold = max(0, i) } }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    productImageSection
                    productDetailsSection
                    barcodeSection
                    discountSection
                    alertsSection
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
                    let data = image.jpegData(compressionQuality: 0.6) ?? image.pngData()
                    if let data = data {
                        DispatchQueue.main.async {
                            var updated = product
                            updated.imageData = data
                            product = updated
                        }
                    }
                }
            }
            .alert("Pro Feature", isPresented: $showProAlert) {
                Button("Upgrade to Pro") {
                    showProAlert = false
                    showSubscriptionView = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Product images are a Pro feature. Upgrade to access.")
            }
            .alert("Upgrade to Pro", isPresented: $showBarcodeProAlert) {
                Button("Upgrade Now") {
                    showBarcodeProAlert = false
                    showSubscriptionView = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Barcode scanning is a Pro feature. Upgrade to scan barcodes instantly and manage inventory faster!")
            }
            .fullScreenCover(isPresented: $showSubscriptionView) {
                if let auth = authManager {
                    SubscriptionView(authManager: auth)
                }
            }
            .sheet(isPresented: $showBarcodeScanner) {
                BarcodeScannerView(onBarcodeScanned: { code in
                    var updated = product
                    updated.barcode = code
                    product = updated
                    showBarcodeScanner = false
                    HapticManager.success()
                })
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
            let image: UIImage?
            if let edited = info[.editedImage] as? UIImage {
                image = edited
            } else if let original = info[.originalImage] as? UIImage {
                image = original
            } else {
                image = nil
            }
            if let image = image {
                self.parent.onImageSelected(image)
            }
            // Dismiss after a short delay so the parent view can process the state update before the sheet closes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.parent.dismiss()
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.dismiss()
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
