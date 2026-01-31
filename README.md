# LiveLedger

**Live Stream Sales Manager** – Track orders, manage products, and grow your social commerce business.

LiveLedger is an iOS app for sellers who run live sales on TikTok, Instagram, Facebook, and other platforms. Add orders quickly during streams, track payment status, save customer info for repeat buyers, manage product inventory, and export or print reports—all with a clean, themeable interface.

---

## Features

### Free Tier
- **Up to 20 orders** per account
- **Up to 10 CSV exports**
- Add, view, edit, and delete orders (swipe to delete; long-press to edit)
- Type or use +/- for quantity everywhere (buyer popup, order sheet, order list, edit order)
- Product catalogs (up to 12 products per catalog) with name, price, stock, discounts, alerts
- Order source (Live Stream, Instagram DM, Facebook DM, etc.) and payment status (Unset / Pending / Paid)
- Customer autocomplete from past orders (name, phone, notes)
- Platform filters (TikTok, Instagram, Facebook, custom) and status filters (Pending / Completed)
- Real-time stats: total orders, total sales, top seller
- Print daily order report and individual receipts
- CSV export (within free limit)
- Multiple themes and background images
- 13 languages (English, French, Spanish, Portuguese, German, Italian, Chinese, Japanese, Korean, Arabic, Hindi, Russian, Dutch)
- Data & Privacy: backup to file, restore from backup, delete my data (with confirmation)
- App Store review prompt (after first export or 5th order, once per version)
- Haptic feedback on key actions
- Works offline; data stored locally

### Pro ($19.99/month)
- **Unlimited orders**
- **Unlimited CSV exports**
- **Product images** (add/change/remove per product; shown in order rows)
- **Barcode scanning** (scan product barcodes with camera for fast inventory; free users can type barcode)
- **Advanced analytics** (average order value, units sold, today/week/month sales, best day, top platform, unpaid orders, order source breakdown)
- **Order filters** (by platform, payment, order source)
- **Priority support**
- All future Pro features

---

## Screenshots

*Placeholders: add screenshots of Home, Orders list, Product grid, Analytics, Settings.*

- iPhone 6.7" (1290 x 2796)
- iPhone 6.5" (1242 x 2688)
- iPad Pro 12.9" (2048 x 2732) if supported

---

## Requirements

- **iOS** 17.0+
- **Xcode** 15+
- **Swift** 5.9+

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/LiveLedger.git
   cd LiveLedger
   ```
2. Open `LiveLedger.xcodeproj` in Xcode.
3. Select a simulator or device and run (⌘R).

No third-party package manager; the app uses only Apple frameworks.

---

## Architecture

- **UI:** SwiftUI (iOS 17+)
- **State:** `ObservableObject` view models (`SalesViewModel`, `AuthManager`, `ThemeManager`, `StoreKitManager`, `LocalizationManager`) and `@State` / `@Binding` in views
- **Persistence:** `UserDefaults` for catalogs, orders, platforms, auth, theme, language; no Core Data or external DB
- **Patterns:** MVVM-style (views observe view models); managers for auth, StoreKit, backup/restore, haptics, sound, app review
- **Navigation:** Single main screen (MainAppView) with header, stats, platform selector, product grid, orders list; sheets for edit order, edit product, subscription, settings, analytics; no tab bar in current flow

---

## Project Structure

```
LiveLedger/
├── LiveLedger/
│   ├── LiveLedgerApp.swift      # App entry, language → auth → main
│   ├── ContentView.swift        # Alternate main content (grid layout)
│   ├── MainAppView.swift        # Primary home: stats, platform, products, orders
│   ├── MainTabView.swift        # Tab-style layout variant
│   ├── AuthView.swift           # Auth, AppUser, AuthManager, security questions
│   ├── SimpleAuthView.swift     # Simplified login/signup
│   ├── OnboardingView.swift     # Onboarding flow
│   ├── Models.swift             # Platform, Product, Order, ProductCatalog, etc.
│   ├── SalesViewModel.swift    # Orders, catalogs, platforms, filters, save/load
│   ├── OrdersListView.swift     # Orders list, CompactOrderRow, EditOrderSheet
│   ├── QuickAddView.swift       # Product grid, BuyerPopupView, AddOrderSheet, EditProductSheet
│   ├── HeaderView.swift         # Fixed header, stats, export, print, daily report
│   ├── AnalyticsView.swift      # Analytics / reports
│   ├── StatisticsDashboardView.swift # Stats dashboard
│   ├── SettingsView.swift       # Profile, themes, language, subscription, data & privacy
│   ├── SubscriptionView.swift  # Paywall, Pro features, restore purchases
│   ├── StoreKitManager.swift    # StoreKit 2 subscription state and purchase
│   ├── DataManager.swift        # Backup/restore/delete-all (BackupData, FileDocument)
│   ├── LocalizationManager.swift# 13 languages, LocalizedKey
│   ├── HapticManager.swift      # Haptic feedback
│   ├── SoundManager.swift      # Sound effects
│   ├── AppReviewHelper.swift    # Request App Store review (export/order count)
│   ├── BarcodeScannerView.swift # Barcode scanner (Pro – camera scan)
│   ├── PlatformSelectorView.swift
│   ├── LanguageSelectionView.swift
│   ├── AppIconView.swift
│   └── StockBadgeView.swift
├── LiveLedgerTests/
├── LiveLedgerUITests/
├── AppStoreDescription.txt
└── README.md
```

---

## Key Technologies

- **SwiftUI** – UI and layout
- **StoreKit 2** – In-app subscription (Pro monthly/yearly)
- **Combine** – Reactive updates in view models
- **UserDefaults** – Persistence for orders, catalogs, platforms, auth, settings
- **Foundation** – Codable, DateFormatter, NotificationCenter
- **UIKit** (minimal) – UIImagePickerController, haptics, window size (iPad)
- **AVFoundation** – BarcodeScannerView (camera scan), SoundManager (audio playback)

---

## App Store

*[Link when published]*

---

## License

*[Your license]*

---

## Contact

- Support: [Support URL from AppStoreDescription.txt]
- Privacy: [Privacy Policy URL]
- Marketing: https://octa-square.com  
- Email: admin@octasquare.com
