# LiveLedger – Technical Architecture

## Overview

LiveLedger is a native iOS app built with SwiftUI. It uses a single main screen (MainAppView) for home, stats, platform selector, product grid, and orders list. State is held in ObservableObject view models and managers; persistence is UserDefaults. There is no backend; all data is local. StoreKit 2 handles the Pro subscription.

## Data Models

### Order
```swift
struct Order: Identifiable, Codable, Equatable {
    let id: UUID
    var productId: UUID
    var productName: String
    var productBarcode: String
    var buyerName: String
    var phoneNumber: String
    var address: String
    var customerNotes: String?
    var orderSourceRaw: String?   // orderSource as raw value
    var platform: Platform
    var quantity: Int
    var pricePerUnit: Double
    var wasDiscounted: Bool
    var paymentStatus: PaymentStatus  // .unset, .pending, .paid
    var isFulfilled: Bool
    var timestamp: Date
    // Computed: orderSource (OrderSource), totalPrice, isPaid, hasBarcode
}
```

### Product
```swift
struct Product: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var price: Double
    var stock: Int
    var lowStockThreshold: Int
    var criticalStockThreshold: Int
    var discountType: DiscountType   // .none, .percentage, .amount
    var discountValue: Double
    var barcode: String
    var imageData: Data?
    // Computed: hasImage, hasBarcode, stockColor, isEmpty, finalPrice, hasDiscount
}
```

### ProductCatalog
```swift
struct ProductCatalog: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var products: [Product]
    static let maxProducts = 12
    // Computed: isFull, configuredProductsCount
}
```

### Platform
```swift
struct Platform: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var color: String
    var isCustom: Bool
    // Computed: swiftUIColor
    // Static: tiktok, instagram, facebook, all, defaultPlatforms
}
```

### AppUser (AuthView)
```swift
struct AppUser: Codable {
    var id: String
    var email: String
    var passwordHash: String
    var name: String
    var phoneNumber: String?
    var companyName: String
    var storeAddress: String?
    var businessPhone: String?
    var currency: String
    var isPro: Bool
    var ordersUsed: Int
    var exportsUsed: Int
    var referralCode: String
    var createdAt: Date
    var profileImageData: Data?
    var securityQuestions: [SecurityQuestion]?
    var loginAttempts: Int
    var accountLocked: Bool
    var resetToken: String?
    var resetTokenExpiry: Date?
    var lastLogin: Date?
    var hadPreviousSubscription: Bool?
    var subscriptionExpiredDate: Date?
    // Computed: currencySymbol, canCreateOrder, canExport, isLapsedSubscriber, formattedExpirationDate
}
```

### BackupData (DataManager)
```swift
struct BackupData: Codable {
    let orders: [Order]
    let catalogs: [ProductCatalog]
    let platforms: [Platform]
    let exportDate: Date
    let appVersion: String?
}
```

### Enums
- **PaymentStatus:** unset, pending, paid  
- **OrderSource:** liveStream, instagramDM, facebookDM, tiktokDM, whatsApp, other  
- **DiscountType:** none, percentage, amount  

---

## View Structure

```
LiveLedgerApp
├── Group
│   ├── LanguageSelectionView (if !hasSelectedLanguage)
│   ├── MainAppView (if isLoggedIn)
│   └── SimpleAuthView (else) → sets isLoggedIn
├── .onAppear / .onChange(scenePhase) → auto-save
```

**MainAppView**
- FixedHeaderView (logo, Analytics, Settings)
- ScrollView
  - StatsAndActionsSection (Total Orders, Total Sales, Top Seller)
  - PlatformSection (platform chips for new orders)
  - ProductsSection (product grid; tap → BuyerPopupView, long-press → EditProductSheet)
  - OrdersFlexibleSection (filters + List of OrderRowView; swipe delete, long-press edit → EditOrderSheet)
- BuyerPopupView overlay (when product selected): customer name, autocomplete, phone, notes, order source, quantity (type or +/-), Add/Cancel
- Sheets: Subscription, Analytics, Settings, EditOrderSheet

**OrdersListView** (alternate/compact orders flow)
- Filters (payment, order source, platform)
- List of CompactOrderRow (tap quantity to type, +/-; edit, delete)
- EditOrderSheet (buyer, platform, quantity TextField + Stepper, payment, receipt)

**HeaderView**
- Stats cards, Export (CSV), Print (daily report / all receipts)
- Export/print loading and error handling

---

## Managers & Services

| Component | Purpose |
|----------|--------|
| **SalesViewModel** | Orders, catalogs, platforms; filters; add/update/delete order; update product; save/load from UserDefaults; CSV build; customer list for autocomplete |
| **AuthManager** | Current user (AppUser), login/signup, upgrade/reset Pro, order/export usage, demo account |
| **StoreKitManager** | StoreKit 2 products, subscription status, purchase, restore; notifies AuthManager (isPro) |
| **DataManager** | Build BackupData from SalesViewModel; export/import JSON (FileDocument); deleteAllUserData keys |
| **ThemeManager** | Current theme (AppTheme), background image, persistence |
| **LocalizationManager** | Current language, LocalizedKey strings, 13 locales |
| **HapticManager** | success, error, warning, lightImpact, selection |
| **SoundManager** | Play sounds (e.g. order added) |
| **AppReviewHelper** | Request review when eligible (first export or 5th order, once per version) |

---

## State Management

- **Global:** `AuthManager`, `LocalizationManager` as `@StateObject` or shared; `StoreKitManager.shared`
- **Screen:** `SalesViewModel`, `ThemeManager` as `@StateObject` in main content
- **Local:** `@State` for sheet visibility, selected product/order, form fields; `@Binding` for parent-driven values (e.g. quantity, buyer name)
- **Persistence:** UserDefaults keys for catalogs, orders, platforms, auth, theme, language; auto-save on scene phase background/inactive

---

## Data Persistence

- **UserDefaults** for:
  - Catalogs (encoded as JSON)
  - Orders (encoded as JSON)
  - Platforms (encoded as JSON)
  - Auth (current user, accounts)
  - Theme, language, onboarding/plan flags
- **Backup:** DataManager builds BackupData and exports via SwiftUI `fileExporter` (JSON file)
- **Restore:** User selects file → fileImporter → DataManager.restoreFromJSON → SalesViewModel.loadFromBackup
- **Delete all:** DataManager.deleteAllUserData clears app UserDefaults keys; AuthManager signOut clears in-memory user

---

## Third-Party Dependencies

None. Apple frameworks only:

- SwiftUI, Combine
- StoreKit (StoreKit 2)
- Foundation (Codable, UserDefaults, NotificationCenter, DateFormatter)
- UIKit (minimal: UIImagePickerController, UIImpactFeedbackGenerator, window size)
- AVFoundation (BarcodeScannerView – camera barcode scan; SoundManager – audio playback)

### Barcode Scanning (Pro Feature)
- **View:** BarcodeScannerView.swift
- **Technology:** AVFoundation (AVCaptureSession, AVCaptureMetadataOutput)
- **Permission:** NSCameraUsageDescription
- **Integration:** Product add/edit form (EditProductSheet in QuickAddView); scan button for Pro, PRO badge + upgrade prompt for free users
- **Restriction:** Pro subscribers only (scan); free users can type barcode
- **Purpose:** Fast product identification and inventory management

---

## Design Patterns

- **MVVM-style:** Views observe `SalesViewModel`, `AuthManager`, `ThemeManager`; business logic and persistence in view model and managers
- **Managers as singletons or shared:** StoreKitManager.shared; LocalizationManager.shared
- **Sheets for flows:** Edit Order, Edit Product, Subscription, Settings, Analytics
- **Callbacks:** onSave, onCancel, onDelete, onQuantityChange passed into child views
