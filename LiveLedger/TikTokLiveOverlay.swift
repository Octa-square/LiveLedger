//
//  TikTokLiveOverlay.swift
//  LiveLedger
//
//  Floating overlay for quick order entry during live streams
//

import SwiftUI
import Combine

// MARK: - Overlay Manager
class TikTokLiveOverlayManager: ObservableObject {
    static let shared = TikTokLiveOverlayManager()
    
    @Published var isOverlayVisible: Bool = false
    @Published var overlayPosition: CGPoint = CGPoint(x: 50, y: 200)
    @Published var overlaySize: CGSize = CGSize(width: 280, height: 320)
    @Published var overlayOpacity: Double = 0.95
    
    private init() {
        loadPreferences()
    }
    
    func showOverlay() {
        DispatchQueue.main.async { self.isOverlayVisible = true }
    }
    
    func hideOverlay() {
        DispatchQueue.main.async { self.isOverlayVisible = false }
    }
    
    func toggleOverlay() {
        DispatchQueue.main.async { self.isOverlayVisible.toggle() }
    }
    
    func savePreferences() {
        UserDefaults.standard.set(overlayPosition.x, forKey: "overlay_position_x")
        UserDefaults.standard.set(overlayPosition.y, forKey: "overlay_position_y")
        UserDefaults.standard.set(overlaySize.width, forKey: "overlay_size_width")
        UserDefaults.standard.set(overlaySize.height, forKey: "overlay_size_height")
        UserDefaults.standard.set(overlayOpacity, forKey: "overlay_opacity")
    }
    
    func loadPreferences() {
        if UserDefaults.standard.object(forKey: "overlay_position_x") != nil {
            overlayPosition.x = UserDefaults.standard.double(forKey: "overlay_position_x")
            overlayPosition.y = UserDefaults.standard.double(forKey: "overlay_position_y")
        }
        if UserDefaults.standard.object(forKey: "overlay_size_width") != nil {
            overlaySize.width = UserDefaults.standard.double(forKey: "overlay_size_width")
            overlaySize.height = UserDefaults.standard.double(forKey: "overlay_size_height")
        }
        if UserDefaults.standard.object(forKey: "overlay_opacity") != nil {
            overlayOpacity = UserDefaults.standard.double(forKey: "overlay_opacity")
        }
    }
}

// MARK: - Overlay View
struct TikTokLiveOverlayView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @StateObject private var overlayManager = TikTokLiveOverlayManager.shared
    
    @State private var selectedProduct: Product?
    @State private var showOrderPopup = false
    @State private var buyerName = ""
    @State private var orderQuantity = 1
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        if overlayManager.isOverlayVisible {
            GeometryReader { geometry in
                ZStack {
                    overlayContent
                        .position(
                            x: overlayManager.overlayPosition.x + dragOffset.width,
                            y: overlayManager.overlayPosition.y + dragOffset.height
                        )
                        .gesture(DragGesture()
                            .onChanged { dragOffset = $0.translation }
                            .onEnded { value in
                                overlayManager.overlayPosition.x += value.translation.width
                                overlayManager.overlayPosition.y += value.translation.height
                                dragOffset = .zero
                                overlayManager.savePreferences()
                            }
                        )
                    
                    if showOrderPopup, let product = selectedProduct {
                        orderEntryPopup(product: product)
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
    
    private var overlayContent: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Quick Add")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button { overlayManager.hideOverlay() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.8))
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ], spacing: 8) {
                    ForEach(viewModel.products.filter { !$0.isEmpty }) { product in
                        ProductOverlayCard(product: product) {
                            selectedProduct = product
                            buyerName = ""
                            orderQuantity = 1
                            showOrderPopup = true
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                }
                .padding(8)
            }
            
            HStack {
                Text("Orders: \(viewModel.orderCount)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text("$\(viewModel.totalRevenue, specifier: "%.2f")")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.8))
        }
        .frame(width: overlayManager.overlaySize.width, height: overlayManager.overlaySize.height)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(overlayManager.overlayOpacity)))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.green.opacity(0.5), lineWidth: 2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.5), radius: 10)
    }
    
    private func orderEntryPopup(product: Product) -> some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea().onTapGesture { showOrderPopup = false }
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    if let imageData = product.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage).resizable().scaledToFill()
                            .frame(width: 50, height: 50).clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay(Text(String(product.name.prefix(1))).font(.system(size: 20, weight: .bold)).foregroundColor(.green))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(product.name).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        Text("$\(product.price, specifier: "%.2f")").font(.system(size: 14, weight: .semibold)).foregroundColor(.green)
                        Text("Stock: \(product.stock)").font(.system(size: 12)).foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                Divider().background(Color.gray.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Buyer Name (Optional)").font(.system(size: 12, weight: .medium)).foregroundColor(.gray)
                    TextField("Enter buyer name", text: $buyerName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10).background(Color.white.opacity(0.1)).cornerRadius(8).foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quantity").font(.system(size: 12, weight: .medium)).foregroundColor(.gray)
                    HStack {
                        Button { if orderQuantity > 1 { orderQuantity -= 1 } } label: {
                            Image(systemName: "minus.circle.fill").font(.system(size: 28)).foregroundColor(.red)
                        }
                        Text("\(orderQuantity)").font(.system(size: 24, weight: .bold)).foregroundColor(.white).frame(minWidth: 50)
                        Button { if orderQuantity < product.stock { orderQuantity += 1 } } label: {
                            Image(systemName: "plus.circle.fill").font(.system(size: 28)).foregroundColor(.green)
                        }
                    }.frame(maxWidth: .infinity)
                }
                
                HStack {
                    Text("Total:").font(.system(size: 14)).foregroundColor(.gray)
                    Spacer()
                    Text("$\(product.price * Double(orderQuantity), specifier: "%.2f")").font(.system(size: 18, weight: .bold)).foregroundColor(.green)
                }
                
                HStack(spacing: 12) {
                    Button { showOrderPopup = false } label: {
                        Text("Cancel").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color.gray.opacity(0.3)).cornerRadius(8)
                    }
                    Button { addOrder(product: product) } label: {
                        Text("Add Order").font(.system(size: 14, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color.green).cornerRadius(8)
                    }
                }
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 0.15)))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.green.opacity(0.3), lineWidth: 1))
            .frame(width: 300)
            .shadow(color: .black.opacity(0.5), radius: 20)
        }
    }
    
    private func addOrder(product: Product) {
        viewModel.addOrder(product: product, quantity: orderQuantity, buyerName: buyerName.isEmpty ? nil : buyerName)
        SoundManager.shared.playOrderAddedSound()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        showOrderPopup = false
        selectedProduct = nil
    }
}

// MARK: - Product Card
struct ProductOverlayCard: View {
    let product: Product
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                if let imageData = product.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage).resizable().scaledToFill()
                        .frame(width: 60, height: 60).clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(Text(String(product.name.prefix(2))).font(.system(size: 16, weight: .bold)).foregroundColor(.green))
                }
                Text(product.name).font(.system(size: 10, weight: .medium)).foregroundColor(.white).lineLimit(1)
                Text("$\(product.price, specifier: "%.0f")").font(.system(size: 10, weight: .bold)).foregroundColor(.green)
            }
            .frame(maxWidth: .infinity).padding(6).background(Color.white.opacity(0.1)).cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}