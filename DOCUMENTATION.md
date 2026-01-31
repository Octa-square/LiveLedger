# LiveLedger – Code Audit & Documentation

## Executive Summary

LiveLedger is an iOS app (SwiftUI, iOS 17+) for live sellers on TikTok, Instagram, and Facebook. Users add orders during streams (buyer name, phone, notes, order source, quantity), manage product catalogs (up to 12 products per catalog with name, price, stock, discounts, and optional images for Pro), filter and edit/delete orders (swipe delete, long-press edit, quantity by typing or +/-), track payment status, and export/print reports. Free tier: 20 orders, 10 exports, no product images, no advanced analytics. Pro ($19.99/month): unlimited orders/exports, product images, advanced analytics, order filters, priority support. Data is stored locally (UserDefaults); backup/restore and delete-my-data are available. No backend; StoreKit 2 handles subscription.

---

## 1. Complete Feature Inventory

### FREE TIER
1. **Add orders (up to 20)** – Tap product → buyer popup; name, phone, notes, order source, quantity (type or +/-)
2. **View orders** – List with platform/status filters; product thumbnail, buyer, quantity, total, time
3. **Edit orders** – Long-press order → Edit Order sheet; buyer, platform, quantity (type or Stepper), payment
4. **Delete orders** – Swipe Delete with confirmation; in-list delete with confirmation
5. **Filter orders** – By platform, status (Pending/Completed), payment (All/Unpaid/Paid), order source
6. **Product catalogs** – Multiple catalogs, up to 12 products each; name, price, stock, discounts, alerts
7. **Edit/delete products** – Long-press product → Edit Product (no image in free)
8. **Order source** – Live Stream, Instagram DM, Facebook DM, TikTok DM, WhatsApp, Other
9. **Payment status** – Unset / Pending / Paid; mark paid/unpaid; payment filters
10. **Customer autocomplete** – From past orders (name, phone, notes) in buyer popup
11. **Platform selector** – TikTok, Instagram, Facebook, custom; used when adding orders
12. **Stats** – Total orders, total sales, top seller (filtered)
13. **CSV export** – Up to 10 exports (free limit)
14. **Print** – Daily order report, individual receipts (with loading/error states)
15. **Themes** – Multiple themes and background images
16. **13 languages** – English, French, Spanish, Portuguese, German, Italian, Chinese, Japanese, Korean, Arabic, Hindi, Russian, Dutch
17. **Data & Privacy** – Backup to file, restore from backup, Delete My Data (two-step confirmation)
18. **Haptic feedback** – On key actions (order added, deleted, paid, etc.)
19. **App Store review prompt** – After first export or 5th order, once per app version
20. **Quantity by typing** – Buyer popup, add order sheet, compact order row (tap to edit), edit order sheet

### PRO TIER ($19.99/month)
1. **Unlimited orders** – No 20-order cap
2. **Unlimited CSV exports** – No 10-export cap
3. **Product images** – Add/change/remove per product; shown in product cards and order rows
4. **Advanced analytics** – Average order value, units sold, today/week/month sales, best day, top platform, unpaid orders, order source breakdown
5. **Order filters** – By platform, payment, order source (in OrdersListView)
6. **Priority support** – Listed in Pro benefits

### TOTAL FEATURE COUNT
- Free: 20
- Pro: 7 (on top of free)
- Total distinct features: 27

---

## 2. File Structure Map

```
LiveLedger/
├── LiveLedger/
│   ├── LiveLedgerApp.swift         # @main; language → auth → MainAppView; auto-save; simulator reset
│   ├── ContentView.swift            # MainContentView (alternate home with grid layout)
│   ├── MainAppView.swift            # Primary home: header, stats, platform, products, orders; BuyerPopupView; sheets
│   ├── MainTabView.swift            # Tab-style layout variant
│   ├── AuthView.swift               # Auth UI, AppUser, AuthManager, security questions, sign out
│   ├── SimpleAuthView.swift        # Simplified login/signup
│   ├── OnboardingView.swift         # Onboarding flow
│   ├── Models.swift                 # Platform, Product, Order, ProductCatalog, PaymentStatus, OrderSource, DiscountType
│   ├── SalesViewModel.swift        # Orders, catalogs, platforms, filters, save/load, CSV, createOrder, updateOrder, deleteOrder
│   ├── OrdersListView.swift        # Orders list, CompactOrderRow, EditOrderSheet, receipt view
│   ├── QuickAddView.swift           # Product grid, BuyerPopupView, AddOrderSheet, EditProductSheet, ProductImagePicker
│   ├── HeaderView.swift             # Fixed header, stats, export, print, daily report, export state
│   ├── AnalyticsView.swift          # Analytics / reports view
│   ├── StatisticsDashboardView.swift # Stats dashboard (Pro-gated)
│   ├── SettingsView.swift           # Profile, themes, language, subscription, data & privacy, delete data sheet
│   ├── SubscriptionView.swift       # Paywall, Pro features, restore purchases, Why Pro
│   ├── StoreKitManager.swift        # StoreKit 2 products, subscription status, purchase, restore
│   ├── DataManager.swift            # BackupData, BackupFileDocument, buildBackup, export/restore JSON, deleteAllUserData
│   ├── LocalizationManager.swift    # AppLanguage, LocalizedKey, 13 languages
│   ├── HapticManager.swift          # success, error, warning, lightImpact, selection
│   ├── SoundManager.swift           # Sound effects (e.g. order added)
│   ├── AppReviewHelper.swift        # Request review (first export or 5th order, once per version)
│   ├── BarcodeScannerView.swift     # Barcode scanner (Pro – camera scan)
│   ├── PlatformSelectorView.swift   # Platform selection UI
│   ├── LanguageSelectionView.swift  # Language picker
│   ├── AppIconView.swift            # App icon display
│   └── StockBadgeView.swift         # Stock badge for products
├── LiveLedgerTests/
│   └── LiveLedgerTests.swift
├── LiveLedgerUITests/
│   ├── LiveLedgerUITests.swift
│   └── LiveLedgerUITestsLaunchTests.swift
├── AppStoreDescription.txt
├── README.md
├── FEATURES.md
├── CHANGELOG.md
├── ARCHITECTURE.md
├── DOCUMENTATION.md
└── (this file)
```

---

## 3. Data Model Documentation

### Order
| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Unique order ID |
| productId | UUID | Reference to Product |
| productName | String | Snapshot of product name |
| productBarcode | String | Snapshot for receipts (backward compat) |
| buyerName | String | Customer name |
| phoneNumber | String | Customer phone |
| address | String | Customer address |
| customerNotes | String? | Optional notes |
| orderSourceRaw | String? | Order source raw (e.g. "Live Stream") |
| platform | Platform | TikTok/Instagram/Facebook/custom |
| quantity | Int | Units |
| pricePerUnit | Double | Price per unit at time of order |
| wasDiscounted | Bool | Whether discount was applied |
| paymentStatus | PaymentStatus | Unset / Pending / Paid |
| isFulfilled | Bool | Completed/delivered |
| timestamp | Date | Order time |

### Product
| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Unique product ID |
| name | String | Product name (max 15 in UI) |
| price | Double | Base price |
| stock | Int | Current stock |
| lowStockThreshold | Int | Low-stock alert |
| criticalStockThreshold | Int | Critical-stock alert |
| discountType | DiscountType | None / Percentage / Amount |
| discountValue | Double | Discount value |
| barcode | String | Legacy field (no UI; kept for data compatibility) |
| imageData | Data? | Product image (Pro) |

### ProductCatalog
| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Unique catalog ID |
| name | String | Catalog name |
| products | [Product] | Up to 12 products |

### Platform
| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Unique platform ID |
| name | String | e.g. TikTok, Instagram |
| icon | String | SF Symbol name |
| color | String | Theme color key |
| isCustom | Bool | User-created |

### AppUser (AuthView)
| Field | Type | Description |
|-------|------|-------------|
| id | String | User ID |
| email | String | Email |
| passwordHash | String | Local hash |
| name | String | Display name |
| phoneNumber | String? | Phone |
| companyName | String | Company |
| storeAddress | String? | For receipts |
| businessPhone | String? | Business phone |
| currency | String | e.g. "USD ($)" |
| isPro | Bool | Pro subscription active |
| ordersUsed | Int | Free-tier order count |
| exportsUsed | Int | Free-tier export count |
| referralCode | String | Referral |
| createdAt | Date | Account creation |
| profileImageData | Data? | Profile picture |
| securityQuestions | [SecurityQuestion]? | Security Q&A |
| loginAttempts | Int | For lockout |
| accountLocked | Bool | Lockout flag |
| hadPreviousSubscription | Bool? | For lapsed-subscriber messaging |
| subscriptionExpiredDate | Date? | When Pro expired |

---

## 4. Third-Party Dependencies

### Apple Frameworks
| Framework | Purpose |
|-----------|---------|
| SwiftUI | UI and layout |
| Combine | Reactive updates in view models |
| StoreKit | StoreKit 2 subscription (Pro) |
| Foundation | Codable, UserDefaults, DateFormatter, NotificationCenter |
| UIKit | UIImagePickerController, UIImpactFeedbackGenerator, window size (iPad) |
| AVFoundation | BarcodeScannerView (camera barcode scan), SoundManager (audio playback) |
| UniformTypeIdentifiers | FileDocument for backup (DataManager) |

### Third-Party Libraries
None. The app uses only Apple frameworks.

---

## 5. Settings & Configuration

### Account Settings (SettingsView / AuthView)
- Profile: name, email, store address, business phone, currency, profile image
- Security questions (auth)
- Sign out
- Delete account (if present)

### App Settings
- Themes: select theme and background image
- Language: select from 13 languages
- Sound: optional sound effects

### Subscription Settings
- Restore Purchases (with loading and alerts)
- Why Pro? (benefits sheet)

### Data & Privacy
- Backup to Files (fileExporter, JSON)
- Restore from Backup (fileImporter)
- Delete My Data (two-step: alert + type "DELETE" to confirm)

---

## 6. Localization Status

### Supported Languages
- English (en) – Complete
- French (fr) – Complete
- Spanish (es) – Complete
- Portuguese (pt) – Complete
- German (de) – Complete
- Italian (it) – Complete
- Chinese (zh) – Complete
- Japanese (ja) – Complete
- Korean (ko) – Complete
- Arabic (ar) – Complete
- Hindi (hi) – Complete
- Russian (ru) – Complete
- Dutch (nl) – Complete

All strings go through LocalizationManager and LocalizedKey; 13 locales with full key sets.

---

## 7. Known Issues & TODOs

### From codebase search (TODO / FIXME / HACK / NOTE)
- **StoreKitManager.swift:103** – `// NOTE: We do NOT auto-process pending transactions on launch` (intentional to avoid auto-subscription)

### Recommendations
- Consider moving hardcoded strings (e.g. "Delete this order?", "This cannot be undone.") into LocalizationManager for full localization.
- Consider accessibility labels for all interactive elements (some already present).
- Simulator reset in LiveLedgerApp clears UserDefaults on simulator only; ensure production builds do not call it.

---

## 8. Feature Comparison Table (Free vs Pro)

| Feature | Free | Pro |
|---------|------|-----|
| Add orders | Up to 20 | Unlimited |
| CSV export | Up to 10 | Unlimited |
| Product images | ❌ | ✅ |
| Barcode scanning | Manual entry only | ✅ (camera scan) |
| Advanced analytics | ❌ | ✅ |
| Order filters (platform, payment, source) | Basic (platform/status in main; full in OrdersListView) | Full (same + analytics) |
| Priority support | ❌ | ✅ |
| Edit/delete orders | ✅ | ✅ |
| Customer autocomplete | ✅ | ✅ |
| Payment tracking | ✅ | ✅ |
| Print receipts & daily report | ✅ | ✅ |
| Themes & 13 languages | ✅ | ✅ |
| Backup / Restore / Delete data | ✅ | ✅ |

---

## 9. App Store Assets Audit

### Current Status (from AppStoreDescription.txt)
- **App name:** LiveLedger  
- **Subtitle:** Live Stream Sales Manager  
- **Category:** Business (Primary), Finance (Secondary)  
- **Keywords:** live sales, tiktok shop, instagram live, facebook live, order tracker, pos, inventory, receipt, sales tracker  
- **Description:** Sales tracking for social sellers; real-time tracking, order source, payment status, customer autocomplete, analytics, export/print; Pro: unlimited orders/exports, product images, barcode scanning, advanced analytics, priority support.

### Screenshots Needed
- iPhone 6.7" (1290 × 2796) – Status: placeholder  
- iPhone 6.5" (1242 × 2688) – Status: placeholder  
- iPad Pro 12.9" (2048 × 2732) – Status: placeholder if iPad is supported  

### In-App Purchases
- **Pro Monthly** – Product ID: `com.octasquare.LiveLedger.monthly.subscription` – Status: configured (StoreKitManager, Products.storekit)  
- **Pro Yearly** – Product ID: `com.octasquare.LiveLedger.yearly.subscription` – Status: configured  

### Support / Legal URLs (from AppStoreDescription.txt)
- Support: https://octa-square.github.io/LiveLedger/support.html  
- Privacy: https://octa-square.github.io/LiveLedger/privacy-policy.html  
- Terms: https://octa-square.github.io/LiveLedger/terms-of-service.html  
- Marketing: https://octa-square.com  
- Email: admin@octasquare.com  
