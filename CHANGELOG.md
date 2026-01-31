# Changelog

## Version 1.2 (Pending / In Development)

### Added
- Quantity editable by typing: buyer popup, add order sheet, compact order row (tap to edit), edit order sheet (TextField + Stepper)
- Long-press on order in main orders list to open Edit Order sheet
- Swipe-to-delete orders in MainAppView orders list with confirmation and haptics
- Order rows show product image thumbnail (lookup by productId)
- Haptic feedback (success, error, warning, light impact, selection) via HapticManager
- App Store review prompt (AppReviewHelper) after first export or 5th order, once per app version
- Export/print loading and error states (ExportState, loading overlays, success message, error alerts)
- “Why Pro?” and Restore Purchases in Settings and Subscription view (with loading and alerts)
- Data & Privacy: Backup to Files, Restore from Backup, Delete My Data (two-step confirmation, DataManager)
- Improved empty states (orders, products) with short actionable copy
- Product grid collapses when no products (zero height) for cleaner layout

### Fixed
- Product image not persisting when adding new product (MainAppView now calls `saveData()` after save)
- Product image “Remove” in Edit Product sheet now updates state correctly (struct mutation)
- Edit Order sheet and compact order row support quantity by typing

### Changed
- MainAppView orders section uses List with swipe-to-delete instead of ScrollView + LazyVStack
- Barcode UI removed from Edit Product sheet, Subscription, Settings, receipts, and export text (model fields kept for compatibility)
- Pro feature copy updated (product images only; barcode scanning no longer in UI)

### Changed (barcode)
- Barcode scanning re-implemented as Pro feature: BarcodeScannerView with camera; barcode section in Edit Product form; Pro upgrade prompt for free users; camera permission (NSCameraUsageDescription) restored.

---

## Version 1.1 (Previous)

### Features
- Order source and payment status
- Customer autocomplete (name, phone, notes)
- Multiple themes and backgrounds
- Localization (13 languages)
- Subscription/paywall and restore purchases
- CSV export and print (daily report, receipts)
- Product catalogs and inventory
- Platform filters and stats

---

## Version 1.0 (Initial Release)

### Features
- Tap-to-sell order entry
- Multi-platform support (TikTok, Instagram, Facebook)
- Real-time sales dashboard
- Order source and payment status
- Customer autocomplete
- Inventory tracking with alerts
- Print receipts and daily reports
- Export to CSV
- 13 languages
- Themes
- Pro subscription
