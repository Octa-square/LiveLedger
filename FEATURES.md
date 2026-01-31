# LiveLedger – Complete Feature List

## Dashboard & Home
- [x] Fixed header with logo and menu (Analytics, Settings)
- [x] Stats section: Total Orders, Total Sales, Top Seller
- [x] Platform selector (TikTok, Instagram, Facebook, custom) for adding orders
- [x] Product grid (tap to add order, long-press to edit product)
- [x] Orders section with platform/status filters and list of orders
- [x] Theme background (gradient + optional wallpaper)
- [x] Limit alert when free user reaches 20 orders (upgrade/resubscribe CTA)

## Order Management
- [x] Add orders (tap product → buyer popup: name, phone, notes, order source, quantity)
- [x] Type quantity or use +/- in buyer popup
- [x] View orders in list (MainAppView and OrdersListView)
- [x] Edit orders (long-press order → Edit Order sheet: buyer, phone, address, notes, order source, platform, quantity, payment)
- [x] Type quantity or use Stepper in Edit Order sheet
- [x] Delete orders (swipe Delete with confirmation; in-list delete with confirmation)
- [x] Filter orders by platform (All / TikTok / Instagram / Facebook / custom)
- [x] Filter orders by status (All / Pending / Completed) in MainAppView
- [x] Filter orders by payment (All / Unpaid / Paid) in OrdersListView
- [x] Filter orders by order source in OrdersListView
- [x] Order row shows product thumbnail (from product image), platform bar, buyer, product name, quantity, unit price, total, time
- [x] Compact order row: tap quantity to type; +/- buttons; payment badge; edit/delete
- [x] Mark order as paid/unpaid (payment status)
- [x] Fulfillment (Pending / Completed) toggle in OrdersListView

## Product Management
- [x] Add products (hold placeholder or +; Edit Product sheet)
- [x] Edit products (long-press product → Edit Product: name, price, stock, discount, alerts, image)
- [x] Delete products (Delete in Edit Product sheet)
- [x] Product images (Pro): add/change/remove; shown in product card and order rows
- [x] **Barcode scanning with camera (Pro)**: scan barcodes in product form; free users can type barcode or tap PRO to upgrade
- [x] Product barcode field: manual entry for all; scan button for Pro
- [x] Barcode displayed on product cards when set
- [x] Product name (max 15 chars), price, stock, low/critical stock thresholds
- [x] Discount: None / Percentage / Amount
- [x] Multiple catalogs (name, up to 12 products per catalog)

## Analytics & Reports
- [x] Total sales stat (filtered)
- [x] Top seller stat (filtered)
- [x] Stock tracking and low-stock indicators
- [x] Advanced analytics (Pro): average order value, units sold, today/week/month sales, best day, top platform, unpaid orders, order source breakdown
- [x] Analytics view (sheet) with charts and breakdowns
- [x] Statistics dashboard (Pro-gated stats)

## Export & Sharing
- [x] CSV export (Free: limited; Pro: unlimited)
- [x] Export loading/success/error states and haptics
- [x] Print daily order report (loading state, error handling)
- [x] Print individual receipts (loading state)
- [x] Share sheet after export

## Customer Management
- [x] Save customer names (stored with orders)
- [x] Customer autocomplete (name, phone, notes from past orders) in buyer popup
- [x] Buyer name, phone, address, notes in Edit Order sheet

## Payment Tracking
- [x] Mark orders as Paid / Pending / Unset
- [x] Payment status badges on order rows
- [x] Payment filters (All / Unpaid / Paid)
- [x] Paid amount / pending amount in stats (where shown)

## Settings & Preferences
- [x] Account / profile (name, email, store address, business phone, currency, profile image)
- [x] Subscription section: Restore Purchases, Why Pro?
- [x] Themes (multiple theme + background options)
- [x] Language (13 languages)
- [x] Data & Privacy: Backup to Files, Restore from Backup, Delete My Data (two-step confirmation)
- [x] Sign out
- [x] About / version

## Subscription / IAP
- [x] Free tier: 20 orders, 10 exports, no product images, no advanced analytics
- [x] Pro subscription ($19.99/month) via StoreKit 2
- [x] Restore purchases (with loading and alerts)
- [x] Paywall / subscription view (Why Pro, features, subscribe, restore)
- [x] Subscription status reflected in AuthManager/AppUser (isPro)
- [x] Lapsed subscriber messaging (resubscribe CTA)

## Platform Support
- [x] iPhone layout
- [x] iPad layout (minimum window size 660×1000)
- [x] Multiple themes (light/dark, gradient + wallpaper)
- [x] Localization (13 languages)
- [x] Haptic feedback
- [x] Sound effects (optional)

## Data & Privacy
- [x] Local data storage (UserDefaults)
- [x] Backup to JSON file (orders, catalogs, platforms)
- [x] Restore from backup (file importer)
- [x] Delete My Data (clear all app data + sign out, with type-DELETE confirmation)

## Additional Features
- [x] App Store review prompt (first export or 5th order, once per version)
- [x] Auto-save on background/inactive (NotificationCenter)
- [x] Simulator reset (optional, for testing)
- [x] Order source (Live Stream, Instagram DM, Facebook DM, TikTok DM, WhatsApp, Other)
- [x] Platform colors (TikTok, Instagram, Facebook brand colors + custom)
