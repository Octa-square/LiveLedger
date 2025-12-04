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
    @State private var editingProduct: Product?
    @State private var selectedProductForOrder: Product?
    @State private var buyerName: String = ""
    @State private var orderQuantity: Int = 1
    @State private var showBuyerPopup: Bool = false
    @State private var showMaxProductsAlert: Bool = false
    @State private var showCreateCatalogAlert: Bool = false
    @State private var showRenameCatalogAlert: Bool = false
    @State private var newCatalogName: String = ""
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                // Header with Catalog Dropdown
                HStack(spacing: 6) {
                    // Catalog Dropdown - Compact
                    Menu {
                        // Switch catalogs
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
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(theme.textPrimary)
                                .lineLimit(1)
                            Text("(\(viewModel.products.filter { !$0.isEmpty }.count)/12)")
                                .font(.system(size: 10))
                                .foregroundColor(theme.textSecondary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 8))
                                .foregroundColor(theme.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Text("Tap sell • Hold edit")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(theme.textSecondary)
                    
                    Button {
                        let added = viewModel.addNewProduct()
                        if !added {
                            showMaxProductsAlert = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(
                                LinearGradient(colors: [theme.accentColor, theme.secondaryColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                    }
                }
                
                // Products Grid - TAP TO ADD ORDER WITH BUYER NAME
                FlexibleProductGrid(
                    products: viewModel.products,
                    theme: theme,
                    onTap: { product in
                        if !product.isEmpty && product.stock > 0 {
                            // Check order limit for free users
                            if let user = authManager.currentUser, !user.canCreateOrder {
                                onLimitReached()
                                return
                            }
                            
                            // Show buyer name popup
                            selectedProductForOrder = product
                            buyerName = ""
                            orderQuantity = 1
                            showBuyerPopup = true
                            
                            // Haptic feedback
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }
                    },
                    onLongPress: { product in
                        editingProduct = product
                    }
                )
            }
            
            // Quick Add Popup - inline overlay
            if showBuyerPopup, let product = selectedProductForOrder {
                VStack(spacing: 8) {
                    // Buyer name field with pencil icon
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("Buyer Name", text: $buyerName)
                            .font(.system(size: 13))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // Quantity & Amount row
                    HStack(spacing: 12) {
                        Button {
                            if orderQuantity > 1 { orderQuantity -= 1 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(orderQuantity > 1 ? .blue : .gray.opacity(0.3))
                        }
                        
                        Text("\(orderQuantity)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .frame(width: 28)
                        
                        Button {
                            if orderQuantity < product.stock { orderQuantity += 1 }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(orderQuantity < product.stock ? .blue : .gray.opacity(0.3))
                        }
                        
                        // Amount - updates with quantity
                        Text("$\(product.finalPrice * Double(orderQuantity), specifier: "%.0f")")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                    }
                    
                    // Cancel & Add buttons
                    HStack(spacing: 10) {
                        // Cancel button
                        Button {
                            showBuyerPopup = false
                            selectedProductForOrder = nil
                            buyerName = ""
                            orderQuantity = 1
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 7)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        
                        // Add button
                        Button {
                            // Use grey "All" platform when no specific platform selected
                            let platform = viewModel.selectedPlatform ?? .all
                            let finalName = buyerName.isEmpty ? "SN-\(viewModel.orders.count + 1)" : buyerName
                            
                            viewModel.createOrder(
                                product: product,
                                buyerName: finalName,
                                phoneNumber: "",
                                address: "",
                                platform: platform,
                                quantity: orderQuantity
                            )
                            authManager.incrementOrderCount()
                            
                            // Play order added sound
                            SoundManager.shared.playOrderAddedSound()
                            
                            showBuyerPopup = false
                            selectedProductForOrder = nil
                            buyerName = ""
                            orderQuantity = 1
                        } label: {
                            Text("Add")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 7)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.2), radius: 8)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowDark.opacity(0.12), radius: 5, x: 3, y: 3)
                .shadow(color: theme.shadowLight.opacity(0.3), radius: 5, x: -3, y: -3)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(theme.cardBorder, lineWidth: 1)
                )
        )
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
    }
}

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
                            .frame(width: cardWidth, height: 75)
                        }
                        
                        // Fill empty spaces in incomplete rows
                        if rows[rowIndex].count < maxPerRow {
                            ForEach(0..<(maxPerRow - rows[rowIndex].count), id: \.self) { index in
                                Color.clear.frame(width: cardWidth, height: 75)
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
        let cardHeight: CGFloat = 75
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
                        // Empty product state - clean placeholder with ⊕ icon
                        VStack(spacing: 3) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(theme.textSecondary.opacity(0.7))
                            
                            Text("Hold to add")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(theme.textSecondary.opacity(0.75))
                            
                            Text("name, price")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(theme.textSecondary.opacity(0.65))
                            
                            Text("& stock")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(theme.textSecondary.opacity(0.65))
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
                    .fill(theme.cardBackground)
                    .shadow(color: theme.shadowDark.opacity(0.15), radius: 3, x: 2, y: 2)
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
        .accessibilityLabel(product.isEmpty ? "Empty product slot. Hold to add product" : "\(product.name), \(formattedPrice), \(product.stock) in stock")
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

// MARK: - Product Image Picker with Crop
struct ProductImagePicker: View {
    let onImageSelected: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCropPreview = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image = selectedImage {
                    // Preview the selected/cropped image
                    VStack(spacing: 16) {
                        Text("Preview")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                            )
                            .shadow(radius: 4)
                        
                        Text("Image will be cropped to square for product display")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 16) {
                            Button {
                                selectedImage = nil
                                showImagePicker = true
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Re-select")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Button {
                                onImageSelected(image)
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark")
                                    Text("Use Image")
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                } else {
                    // Initial state - show picker options
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Select a product image")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("After selecting, you can crop and resize the image")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            showImagePicker = true
                        } label: {
                            HStack {
                                Image(systemName: "photo.badge.plus")
                                Text("Choose from Library")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Product Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerWithCrop { image in
                    selectedImage = image
                }
            }
        }
    }
}

// MARK: - Image Picker with Crop (UIKit)
struct ImagePickerWithCrop: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true // Enables iOS built-in crop
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerWithCrop
        
        init(_ parent: ImagePickerWithCrop) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            // Prefer the edited (cropped) image
            if let editedImage = info[.editedImage] as? UIImage {
                parent.onImageSelected(editedImage)
            } else if let originalImage = info[.originalImage] as? UIImage {
                // If no edited image, crop to square from center
                let croppedImage = cropToSquare(originalImage)
                parent.onImageSelected(croppedImage)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
        
        // Crop image to square from center
        private func cropToSquare(_ image: UIImage) -> UIImage {
            let size = min(image.size.width, image.size.height)
            let x = (image.size.width - size) / 2
            let y = (image.size.height - size) / 2
            let cropRect = CGRect(x: x, y: y, width: size, height: size)
            
            guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
                return image
            }
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
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
