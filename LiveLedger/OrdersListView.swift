//
//  OrdersListView.swift
//  LiveLedger
//
//  Live Sales Tracker - Orders List (Compact for 10+ orders)
//

import SwiftUI
import UIKit

struct OrdersListView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var localization: LocalizationManager
    @ObservedObject var authManager: AuthManager
    @State private var editingOrder: Order?
    @State private var editingNameOrderId: UUID?
    @State private var orderToDelete: Order?
    @State private var showSwipeDeleteConfirmation = false
    
    private var theme: AppTheme { themeManager.currentTheme }
    private var isPro: Bool { authManager.currentUser?.isPro ?? false }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header with filters - FULL WIDTH ALIGNMENT
            // LEFT EDGE: "Orders" label aligns with container left
            // RIGHT EDGE: Filter dropdowns align with container right
            HStack(spacing: 8) {
                // Orders label - LEFT EDGE ALIGNMENT
                Text(localization.localized(.orders))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(theme.textPrimary)
                
                if !viewModel.filteredOrders.isEmpty {
                    Text("\(viewModel.filteredOrders.count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(theme.successColor)
                        .cornerRadius(6)
                }
                
                Spacer()
                
                // Filters - RIGHT EDGE ALIGNMENT (VISIBLE FOR ALL USERS)
                // Payment Filter - All / Unpaid / Paid
                HStack(spacing: 4) {
                    Menu {
                        Button { viewModel.filterPayment = .all } label: {
                            Text(localization.localized(.all)).font(.system(size: 12))
                        }
                        Button { viewModel.filterPayment = .unpaid } label: {
                            Label(localization.localized(.unpaid), systemImage: "circle").font(.system(size: 12))
                        }
                        Button { viewModel.filterPayment = .paid } label: {
                            Label(localization.localized(.paid), systemImage: "checkmark.circle.fill").font(.system(size: 12))
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Text(viewModel.filterPayment == .all ? localization.localized(.all) : viewModel.filterPayment == .unpaid ? localization.localized(.unpaid) : localization.localized(.paid))
                            Image(systemName: "chevron.down").font(.system(size: 7))
                        }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(theme.textPrimary)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(theme.cardBackgroundWithOpacity(0.4))
                .cornerRadius(6)
                
                // Order Source Filter
                HStack(spacing: 4) {
                    Menu {
                        Button { viewModel.filterOrderSource = nil } label: {
                            Text(localization.localized(.allSources)).font(.system(size: 12))
                        }
                        Divider()
                        ForEach(OrderSource.allCases, id: \.self) { source in
                            Button { viewModel.filterOrderSource = source } label: {
                                Text(source.rawValue).font(.system(size: 12))
                            }
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Text(viewModel.filterOrderSource?.shortLabel ?? localization.localized(.orderSource))
                            Image(systemName: "chevron.down").font(.system(size: 7))
                        }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(theme.textPrimary)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(theme.cardBackgroundWithOpacity(0.4))
                .cornerRadius(6)
                
                // Platform Filter - "All ▼"
                HStack(spacing: 4) {
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
                .background(theme.cardBackgroundWithOpacity(0.4))
                .cornerRadius(6)
                
                // Price Filter - "All ▼"
                HStack(spacing: 4) {
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
                .background(theme.cardBackgroundWithOpacity(0.4))
                .cornerRadius(6)
            }
            
            if viewModel.filteredOrders.isEmpty {
                // Empty state - helpful copy
                VStack(spacing: 12) {
                    Spacer()
                    Text("🛍️")
                        .font(.system(size: 48))
                    if viewModel.orders.isEmpty {
                        Text(localization.localized(.noOrders))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.textPrimary)
                        Text("Tap a product below to add your first order!")
                            .font(.system(size: 13))
                            .foregroundColor(theme.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Text("Or tap [+] to add a product first.")
                            .font(.system(size: 12))
                            .foregroundColor(theme.textMuted.opacity(0.8))
                    } else {
                        Text(localization.localized(.noOrders))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.textPrimary)
                        Text("Try adjusting platform or payment filter.")
                            .font(.system(size: 13))
                            .foregroundColor(theme.textMuted)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Orders list with swipe to delete
                List {
                    ForEach(viewModel.filteredOrders) { order in
                        CompactOrderRow(
                            order: order,
                            theme: theme,
                            productImageData: isPro ? viewModel.products.first(where: { $0.id == order.productId })?.imageData : nil,
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
                            onDelete: {
                                HapticManager.warning()
                                viewModel.deleteOrder(order)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
                        .listRowSeparator(.hidden)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(theme.cardBackground.opacity(0.4))
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                orderToDelete = order
                                showSwipeDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .padding(10)
        .confirmationDialog("Delete this order?", isPresented: $showSwipeDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let order = orderToDelete {
                    HapticManager.warning()
                    viewModel.deleteOrder(order)
                }
                orderToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                orderToDelete = nil
            }
        } message: {
            Text("This cannot be undone.")
        }
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

// Ultra-compact order row - fits 5-6 on screen
struct CompactOrderRow: View {
    let order: Order
    let theme: AppTheme
    var productImageData: Data?
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
    @State private var isEditingQuantity = false
    @State private var tempQuantity: String = ""
    @FocusState private var nameFieldFocused: Bool
    @FocusState private var quantityFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            // Product thumbnail when available
            if let data = productImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            // Platform color bar (thin vertical)
            RoundedRectangle(cornerRadius: 1.5)
                .fill(order.platform.swiftUIColor)
                .frame(width: 3, height: 24)
            
            // Product name
            Text(order.productName.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(theme.textPrimary)
                .lineLimit(1)
                .frame(minWidth: 35, maxWidth: 55, alignment: .leading)
            
            // Buyer name - tappable
            if isEditingName {
                TextField("Buyer", text: $tempName)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(theme.textPrimary)
                    .frame(width: 45)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 2)
                    .padding(.vertical, 1)
                    .background(theme.cardBackground)
                    .cornerRadius(2)
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
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(1)
                }
                .frame(width: 45, alignment: .leading)
            }
            
            // Qty - tap to type or use +/-
            HStack(spacing: 2) {
                Button { if order.quantity > 1 { onQuantityChange(order.quantity - 1) } } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(order.quantity > 1 ? theme.textSecondary : theme.textMuted.opacity(0.3))
                }
                
                if isEditingQuantity {
                    TextField("Qty", text: $tempQuantity)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(theme.textPrimary)
                        .keyboardType(.numberPad)
                        .frame(width: 24)
                        .focused($quantityFieldFocused)
                        .onChange(of: quantityFieldFocused) { _, focused in
                            if !focused {
                                if let n = Int(tempQuantity), n >= 1, n <= 99 { onQuantityChange(n) }
                                isEditingQuantity = false
                            }
                        }
                        .onAppear {
                            tempQuantity = "\(order.quantity)"
                            quantityFieldFocused = true
                        }
                } else {
                    Button(action: { isEditingQuantity = true }) {
                        Text("\(order.quantity)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(theme.textPrimary)
                            .frame(width: 14)
                    }
                }
                
                Button { onQuantityChange(order.quantity + 1) } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            Spacer()
            
            // Payment badge (Unpaid / Paid)
            Text(order.paymentStatus == .paid ? LocalizationManager.shared.localized(.paid) : LocalizationManager.shared.localized(.unpaid))
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(order.paymentStatus == .paid ? theme.successColor : theme.dangerColor)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background((order.paymentStatus == .paid ? theme.successColor : theme.dangerColor).opacity(0.2))
                .cornerRadius(4)
            
            // Order source badge
            Text(order.orderSource.shortLabel)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(theme.textSecondary)
                .lineLimit(1)
            
            // Price
            Text("$\(order.totalPrice, specifier: "%.0f")")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(theme.successColor)
                .frame(minWidth: 32, alignment: .trailing)
            
            // More options
            Button(action: onEdit) {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 13))
                    .foregroundColor(theme.textMuted)
            }
            
            // Delete
            Button { showDelete = true } label: {
                Image(systemName: "trash")
                    .font(.system(size: 11))
                    .foregroundColor(theme.dangerColor.opacity(0.7))
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .frame(height: 28) // Reduced from 36 to 28 (22% smaller)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.cardBackground.opacity(0.4))
        )
        .confirmationDialog("Delete this order?", isPresented: $showDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                HapticManager.warning()
                withAnimation { onDelete() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
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
    @State private var quantityInput: String = "1"
    
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
                    }
                    HStack {
                        Image(systemName: "phone.fill").foregroundColor(.gray).frame(width: 20)
                        TextField(LocalizationManager.shared.localized(.phoneOptional), text: $order.phoneNumber).keyboardType(.phonePad)
                    }
                    HStack {
                        Image(systemName: "location.fill").foregroundColor(.gray).frame(width: 20)
                        TextField("Address", text: $order.address)
                    }
                    HStack(alignment: .top) {
                        Image(systemName: "note.text").foregroundColor(.gray).frame(width: 20)
                        TextField(LocalizationManager.shared.localized(.notesOptional), text: Binding(
                            get: { order.customerNotes ?? "" },
                            set: { order.customerNotes = $0.isEmpty ? nil : $0 }
                        ), axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                
                Section("Order") {
                    Picker(LocalizationManager.shared.localized(.orderSource), selection: Binding(
                        get: { order.orderSource },
                        set: { order.orderSource = $0 }
                    )) {
                        ForEach(OrderSource.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    Picker("Platform", selection: $order.platform) {
                        ForEach(platforms) { Label($0.name, systemImage: $0.icon).tag($0) }
                    }
                    HStack {
                        Text("Qty")
                        Spacer()
                        TextField("Quantity", text: $quantityInput)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .onChange(of: quantityInput) { _, s in
                                let n = Int(s) ?? order.quantity
                                order.quantity = min(max(n, 1), 99)
                                if "\(order.quantity)" != s { quantityInput = "\(order.quantity)" }
                            }
                        Stepper("", value: $order.quantity, in: 1...99)
                            .onChange(of: order.quantity) { _, v in quantityInput = "\(v)" }
                    }
                    .onAppear { quantityInput = "\(order.quantity)" }
                    Picker("Payment", selection: $order.paymentStatus) {
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
                    Button {
                        printReceiptAsImage()
                    } label: {
                        Label("Print", systemImage: "printer.fill")
                    }
                }
            }
        }
    }
    
    // MARK: - Print as non-editable image
    @MainActor
    private func printReceiptAsImage() {
        // Create the receipt view
        let receiptContent = receiptContentView
        
        // Render to image
        let renderer = ImageRenderer(content: receiptContent)
        renderer.scale = 3.0 // High resolution
        
        guard let uiImage = renderer.uiImage else { return }
        
        // Print using UIPrintInteractionController
        let printController = UIPrintInteractionController.shared
        
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = "Receipt-\(order.id.uuidString.prefix(8))"
        printInfo.outputType = .photo // Non-editable image
        
        printController.printInfo = printInfo
        printController.printingItem = uiImage
        
        printController.present(animated: true)
    }
    
    // Receipt content for rendering
    private var receiptContentView: some View {
        VStack(spacing: 8) {
            Text("SALES RECEIPT")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
            
            Text(dateFormatter.string(from: order.timestamp))
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.gray)
            
            Text("Order #\(order.id.uuidString.prefix(8).uppercased())")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.gray)
            
            Text(String(repeating: "-", count: 32))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
            
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
            
            Text(String(repeating: "-", count: 32))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
            
            HStack {
                Text("TOTAL")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                Spacer()
                Text("$\(order.totalPrice, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
            }
            
            HStack {
                Text("Status:")
                    .font(.system(size: 12, design: .monospaced))
                Spacer()
                Text(order.paymentStatus.rawValue.uppercased())
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(order.paymentStatus.color)
            }
            
            Text(String(repeating: "-", count: 32))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
            
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
            
            Text(String(repeating: "-", count: 32))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
            
            Text("Via \(order.platform.name)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.gray)
            
            Text(String(repeating: "-", count: 32))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
            
            Text("Thank you for your purchase!")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.gray)
            
            Text("Order #\(order.id.uuidString.prefix(8).uppercased())")
                .font(.system(size: 8, design: .monospaced))
                .foregroundColor(.gray)
        }
        .padding(20)
        .background(Color.white)
        .foregroundColor(.black)
        .frame(width: 300)
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

