//
//  OrdersListView.swift
//  LiveLedger
//
//  Live Sales Tracker - Orders List (Compact for 10+ orders)
//

import SwiftUI

struct OrdersListView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var localization: LocalizationManager
    @ObservedObject var authManager: AuthManager
    @State private var editingOrder: Order?
    @State private var editingNameOrderId: UUID?
    
    private var theme: AppTheme { themeManager.currentTheme }
    private var isPro: Bool { authManager.currentUser?.isPro ?? false }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header with filters - Fixed height
            HStack(spacing: 8) {
                Text(localization.localized(.orders))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(theme.textPrimary)
                
                if !viewModel.filteredOrders.isEmpty {
                    Text("\(viewModel.filteredOrders.count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(theme.successColor)
                        .cornerRadius(5)
                }
                
                Spacer()
                
                // Filters - Pro Feature
                if isPro {
                    // Platform Filter
                    HStack(spacing: 4) {
                        Image(systemName: "iphone")
                            .font(.system(size: 11))
                            .foregroundColor(.blue)
                        Menu {
                            Button { viewModel.filterPlatform = nil } label: {
                                Text("All Platforms").font(.system(size: 12))
                            }
                            Divider()
                            ForEach(viewModel.platforms) { platform in
                                Button {
                                    viewModel.filterPlatform = platform
                                } label: {
                                    Label(platform.name, systemImage: platform.icon)
                                        .font(.system(size: 12))
                                }
                            }
                        } label: {
                            HStack(spacing: 3) {
                                if let p = viewModel.filterPlatform {
                                    Circle().fill(p.swiftUIColor).frame(width: 6, height: 6)
                                    Text(p.name)
                                } else {
                                    Text("All")
                                }
                                Image(systemName: "chevron.down").font(.system(size: 7))
                            }
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(theme.textPrimary)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(theme.cardBackground)
                    .cornerRadius(6)
                    
                    // Discount Filter
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.green)
                        Menu {
                            Button { viewModel.filterDiscount = .all } label: {
                                Text("All Prices").font(.system(size: 12))
                            }
                            Divider()
                            Button { viewModel.filterDiscount = .withDiscount } label: {
                                Text("Discounted").font(.system(size: 12))
                            }
                            Button { viewModel.filterDiscount = .withoutDiscount } label: {
                                Text("Full Price").font(.system(size: 12))
                            }
                        } label: {
                            HStack(spacing: 3) {
                                Text(viewModel.filterDiscount == .all ? "All" : 
                                     viewModel.filterDiscount == .withDiscount ? "Disc" : "Full")
                                Image(systemName: "chevron.down").font(.system(size: 7))
                            }
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(theme.textPrimary)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(theme.cardBackground)
                    .cornerRadius(6)
                }
            }
            
            if viewModel.filteredOrders.isEmpty {
                // Empty state - fills remaining space
                VStack {
                    Spacer()
                    Image(systemName: "bag")
                        .font(.system(size: 32))
                        .foregroundColor(theme.textMuted.opacity(0.4))
                    if viewModel.orders.isEmpty {
                        Text(localization.localized(.noOrders))
                            .font(.system(size: 15))
                            .foregroundColor(theme.textMuted.opacity(0.6))
                        Text("Tap a product to add orders")
                            .font(.system(size: 12))
                            .foregroundColor(theme.textMuted.opacity(0.4))
                    } else {
                        Text("No orders match filters")
                            .font(.system(size: 15))
                            .foregroundColor(theme.textMuted.opacity(0.6))
                        Text("Try adjusting platform or discount filter")
                            .font(.system(size: 12))
                            .foregroundColor(theme.textMuted.opacity(0.4))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Orders list - FIXED HEIGHT container with internal scroll
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 1) {
                        ForEach(viewModel.filteredOrders) { order in
                            MiniOrderRow(
                                order: order,
                                theme: theme,
                                isEditingName: editingNameOrderId == order.id,
                                onNameTap: {
                                    editingNameOrderId = order.id
                                },
                                onNameChange: { newName in
                                    var updated = order
                                    updated.buyerName = newName
                                    viewModel.updateOrder(updated)
                                },
                                onNameDone: {
                                    editingNameOrderId = nil
                                },
                                onQuantityChange: { viewModel.updateOrderQuantity(order, newQuantity: $0) },
                                onFulfilledTap: { viewModel.toggleFulfilled(order) },
                                onEdit: { editingOrder = order },
                                onDelete: { viewModel.deleteOrder(order) }
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
                .scrollIndicators(.visible)
            }
        }
        .padding(8)
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
        .sheet(item: $editingOrder) { order in
            EditOrderSheet(
                order: order,
                platforms: viewModel.platforms,
                onSave: { viewModel.updateOrder($0); editingOrder = nil },
                onCancel: { editingOrder = nil }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// Super compact order row with neumorphic style
struct MiniOrderRow: View {
    let order: Order
    let theme: AppTheme
    let isEditingName: Bool
    let onNameTap: () -> Void
    let onNameChange: (String) -> Void
    let onNameDone: () -> Void
    let onQuantityChange: (Int) -> Void
    let onFulfilledTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showDelete = false
    @State private var tempName: String = ""
    @FocusState private var nameFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            // Platform color box (tiny square)
            RoundedRectangle(cornerRadius: 3)
                .fill(order.platform.swiftUIColor)
                .frame(width: 10, height: 10)
            
            // Product name - smaller
            Text(order.productName.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(order.isFulfilled ? theme.textMuted : theme.textPrimary)
                .lineLimit(1)
                .frame(minWidth: 40, maxWidth: 60, alignment: .leading)
                .strikethrough(order.isFulfilled, color: theme.textMuted)
            
            // Buyer name - tappable
            if isEditingName {
                TextField("Buyer", text: $tempName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(theme.textPrimary)
                    .frame(width: 50)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 2)
                    .background(theme.cardBackground)
                    .cornerRadius(3)
                    .focused($nameFieldFocused)
                    .onSubmit {
                        if !tempName.isEmpty { onNameChange(tempName) }
                        onNameDone()
                    }
                    .onAppear {
                        tempName = order.buyerName
                        nameFieldFocused = true
                    }
            } else {
                Button(action: onNameTap) {
                    Text(order.buyerName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(1)
                }
                .frame(width: 50, alignment: .leading)
            }
            
            // Qty controls - smaller
            HStack(spacing: 4) {
                Button { if order.quantity > 1 { onQuantityChange(order.quantity - 1) } } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(order.quantity > 1 ? theme.textSecondary : theme.textMuted.opacity(0.3))
                }
                
                Text("\(order.quantity)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(theme.textPrimary)
                    .frame(width: 16)
                
                Button { onQuantityChange(order.quantity + 1) } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            Spacer()
            
            // Price - smaller
            Text("$\(order.totalPrice, specifier: "%.0f")")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(theme.successColor)
                .frame(minWidth: 35, alignment: .trailing)
            
            // More options
            Button(action: onEdit) {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 15))
                    .foregroundColor(theme.textMuted)
            }
            
            // Delete
            Button { showDelete = true } label: {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundColor(theme.dangerColor.opacity(0.7))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(height: 32)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.cardBackground.opacity(0.5))
        )
        .confirmationDialog("Delete?", isPresented: $showDelete) {
            Button("Delete", role: .destructive) { withAnimation { onDelete() } }
            Button("Cancel", role: .cancel) {}
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(order.productName), \(order.buyerName), quantity \(order.quantity), $\(Int(order.totalPrice)), \(order.platform.name) platform\(order.isFulfilled ? ", fulfilled" : "")")
        .accessibilityHint("Double tap for more options")
    }
}

struct EditOrderSheet: View {
    @State var order: Order
    let platforms: [Platform]
    let onSave: (Order) -> Void
    let onCancel: () -> Void
    @State private var showReceipt = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Product") {
                    HStack {
                        Text(order.productName)
                        Spacer()
                        Text("$\(order.pricePerUnit, specifier: "%.2f")/ea").foregroundColor(.gray)
                    }
                }
                
                Section("Buyer Details") {
                    HStack {
                        Image(systemName: "person.fill").foregroundColor(.gray).frame(width: 20)
                        TextField("Name", text: $order.buyerName)
                        Image(systemName: "pencil").foregroundColor(.blue).font(.system(size: 12))
                    }
                    HStack {
                        Image(systemName: "phone.fill").foregroundColor(.gray).frame(width: 20)
                        TextField("Phone", text: $order.phoneNumber).keyboardType(.phonePad)
                        Image(systemName: "pencil").foregroundColor(.blue).font(.system(size: 12))
                    }
                    HStack {
                        Image(systemName: "location.fill").foregroundColor(.gray).frame(width: 20)
                        TextField("Address", text: $order.address)
                        Image(systemName: "pencil").foregroundColor(.blue).font(.system(size: 12))
                    }
                }
                
                Section("Order") {
                    Picker("Platform", selection: $order.platform) {
                        ForEach(platforms) { Label($0.name, systemImage: $0.icon).tag($0) }
                    }
                    Stepper("Qty: \(order.quantity)", value: $order.quantity, in: 1...99)
                    Picker("Status", selection: $order.paymentStatus) {
                        ForEach(PaymentStatus.allCases, id: \.self) { Label($0.rawValue, systemImage: $0.icon).tag($0) }
                    }
                }
                
                Section {
                    HStack {
                        Text("Total").font(.headline)
                        Spacer()
                        Text("$\(order.totalPrice, specifier: "%.2f")").font(.title3.bold()).foregroundColor(.green)
                    }
                }
                
                // Print Receipt Button
                Section {
                    Button {
                        showReceipt = true
                    } label: {
                        Label("Print Receipt", systemImage: "printer.fill")
                    }
                }
            }
            .navigationTitle("Edit Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: onCancel) }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { onSave(order) } }
            }
            .sheet(isPresented: $showReceipt) {
                POSReceiptView(order: order)
            }
        }
    }
}

// MARK: - POS Receipt View (Like a real receipt)
struct POSReceiptView: View {
    let order: Order
    @Environment(\.dismiss) var dismiss
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yyyy hh:mm a"
        return f
    }()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Receipt paper style
                    VStack(spacing: 8) {
                        // Header
                        Text("SALES RECEIPT")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                        
                        Text(dateFormatter.string(from: order.timestamp))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text("Order #\(order.id.uuidString.prefix(8).uppercased())")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        // Dotted line
                        Text(String(repeating: "-", count: 32))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        // Product
                        HStack {
                            Text(order.productName)
                                .font(.system(size: 14, design: .monospaced))
                            Spacer()
                        }
                        
                        HStack {
                            Text("\(order.quantity) x $\(order.pricePerUnit, specifier: "%.2f")")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("$\(order.totalPrice, specifier: "%.2f")")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                        }
                        
                        // Dotted line
                        Text(String(repeating: "-", count: 32))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        // Total
                        HStack {
                            Text("TOTAL")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                            Spacer()
                            Text("$\(order.totalPrice, specifier: "%.2f")")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                        }
                        
                        // Payment Status
                        HStack {
                            Text("Status:")
                                .font(.system(size: 12, design: .monospaced))
                            Spacer()
                            Text(order.paymentStatus.rawValue.uppercased())
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(order.paymentStatus.color)
                        }
                        
                        // Dotted line
                        Text(String(repeating: "-", count: 32))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        // Customer Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CUSTOMER")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            Text(order.buyerName)
                                .font(.system(size: 12, design: .monospaced))
                            
                            if !order.phoneNumber.isEmpty {
                                Text(order.phoneNumber)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                            
                            if !order.address.isEmpty {
                                Text(order.address)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Platform
                        Text(String(repeating: "-", count: 32))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text("Via \(order.platform.name)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        // Footer
                        Text(String(repeating: "-", count: 32))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text("Thank you for your purchase!")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        // Barcode - show actual product barcode if available
                        if order.hasBarcode {
                            VStack(spacing: 4) {
                                // Visual barcode representation
                                HStack(spacing: 1) {
                                    ForEach(Array(order.productBarcode.enumerated()), id: \.offset) { index, char in
                                        Rectangle()
                                            .fill(Color.black)
                                            .frame(width: char.isNumber ? 2 : 1, height: 40)
                                    }
                                }
                                .padding(.top, 8)
                                
                                Text(order.productBarcode)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.black)
                            }
                        } else {
                            // Fallback to order ID barcode
                            Text("||||||||||||||||||||||||")
                                .font(.system(size: 20, design: .monospaced))
                                .foregroundColor(.black)
                                .padding(.top, 8)
                        }
                        
                        Text("Order #\(order.id.uuidString.prefix(8).uppercased())")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(20)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(4)
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                }
                .padding(20)
            }
            .background(Color.gray.opacity(0.2))
            .navigationTitle("Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    ShareLink(item: generateReceiptText()) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    func generateReceiptText() -> String {
        // Convert "SN-1" to just "1" for printing
        let customerDisplay = order.buyerName.hasPrefix("SN-") 
            ? String(order.buyerName.dropFirst(3))  // Remove "SN-" prefix
            : order.buyerName
        
        var receipt = """
        ================================
              SALES RECEIPT
        ================================
        Date: \(dateFormatter.string(from: order.timestamp))
        Order #: \(order.id.uuidString.prefix(8).uppercased())
        --------------------------------
        
        \(order.productName)
        \(order.quantity) x $\(String(format: "%.2f", order.pricePerUnit))
        """
        
        if order.hasBarcode {
            receipt += "\nBarcode: \(order.productBarcode)"
        }
        
        receipt += """
        
        --------------------------------
        TOTAL: $\(String(format: "%.2f", order.totalPrice))
        Status: \(order.paymentStatus.rawValue)
        --------------------------------
        
        CUSTOMER #\(customerDisplay)
        \(order.phoneNumber.isEmpty ? "" : order.phoneNumber + "\n")\(order.address.isEmpty ? "" : order.address)
        
        --------------------------------
        Via \(order.platform.name)
        --------------------------------
        
        Thank you for your purchase!
        
        ================================
        """
        
        return receipt
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        OrdersListView(viewModel: {
            let vm = SalesViewModel()
            vm.products[0] = Product(name: "T-Shirt", price: 25, stock: 50)
            for i in 1...12 {
                vm.createOrder(product: vm.products[0], buyerName: "Customer \(i)", phoneNumber: "", address: "", platform: .tiktok)
            }
            return vm
        }(), themeManager: ThemeManager(), localization: LocalizationManager.shared, authManager: AuthManager())
        .padding()
    }
}

