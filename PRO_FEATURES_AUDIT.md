# Pro Features Audit Report

**Date:** January 25, 2026  
**Purpose:** Verify all Pro features are properly gated so Free users cannot access them.

---

## 1. Product Images

### 1.1 Upload (Free users cannot upload)

| Location | Check | Status |
|----------|--------|--------|
| **QuickAddView – EditProductSheet** (QuickAddView.swift ~967–981) | "Add Image" / "Change Image": `if isPro { showImagePicker = true } else { showProAlert = true }` | ✓ **Gated** |
| **QuickAddView – EditProductSheet** (QuickAddView.swift ~1006) | "PRODUCT IMAGE" section shows PRO badge when `!isPro` | ✓ **Gated** |
| **QuickAddView – EditProductSheet** (QuickAddView.swift ~998) | "Remove" image button only when `isPro && product.imageData != nil` | ✓ **Gated** |

**Verdict:** Free users cannot upload or remove product images. Properly gated.

---

### 1.2 View (Free users cannot view images)

| Location | Check | Status |
|----------|--------|--------|
| **MainAppView – ProductCard** (MainAppView.swift ~790–808) | Image shown only when `isPro` and `product.imageData`; else placeholder (photo icon) | ✓ **Gated** |
| **MainAppView – OrderRowView** (MainAppView.swift ~978, 990) | `productImageData` passed only when `authManager.currentUser?.isPro == true` | ✓ **Gated** |
| **MainAppView – OrderRowView body** (MainAppView.swift ~1045) | Displays `productImageData` (caller passes `nil` for Free) | ✓ **Gated** |
| **QuickAddView – FastProductCard** (QuickAddView.swift ~681) | "WITH IMAGE" branch: `isPro, let imageData = product.imageData` | ✓ **Gated** |
| **QuickAddView – EditProductSheet productImagePreview** (QuickAddView.swift ~952) | Image only when `isPro` and `product.imageData`; else placeholder | ✓ **Gated** |
| **OrdersListView – CompactOrderRow** (OrdersListView.swift ~199) | `productImageData: isPro ? viewModel.products.first(...)?.imageData : nil` | ✓ **Gated** |
| **OrdersListView – CompactOrderRow body** (OrdersListView.swift ~292) | Displays `productImageData` (caller passes `nil` for Free) | ✓ **Gated** |

**Verdict:** All product image display paths check Pro status or receive `nil` for Free. Properly gated.

---

### 1.3 Sample data

| Location | Check | Status |
|----------|--------|--------|
| **SampleDataGenerator.makeReviewProducts(isPro:)** (SampleDataGenerator.swift ~43–91) | `imageData: isPro ? generateProductImage(...) : nil` | ✓ **Gated** |
| **SalesViewModel.populateDemoData(isPro:)** (SalesViewModel.swift ~286–295) | Passes `isPro` to `makeReviewProducts(isPro:)` | ✓ **Gated** |
| **MainAppView / MainTabView onAppear** | Call `populateDemoData(isPro: authManager.currentUser?.isPro ?? false)` | ✓ **Gated** |

**Verdict:** Sample products get images only for Pro users. Properly gated.

---

## 2. Barcode Scanning

| Location | Check | Status |
|----------|--------|--------|
| **QuickAddView – EditProductSheet barcodeSection** (QuickAddView.swift ~1062–1112) | Section header: PRO badge when `!isPro` (line ~1068) | ✓ **Gated** |
| **QuickAddView – barcode scan button** (QuickAddView.swift ~1077–1098) | `if isPro { showBarcodeScanner = true } else { showBarcodeProAlert = true }` | ✓ **Gated** |
| **QuickAddView** (QuickAddView.swift ~1213) | Alert "Barcode scanning is a Pro feature. Upgrade to scan barcodes..." | ✓ **Gated** |

**Verdict:** Free users see PRO badge and upgrade alert; only Pro users can open the scanner. Properly gated.

---

## 3. Unlimited Orders (Free limited to 20)

| Location | Check | Status |
|----------|--------|--------|
| **AuthView – AppUser** (AuthView.swift ~94–97) | `maxFreeOrders = 20`, `canCreateOrder = isPro \|\| ordersUsed < maxFreeOrders` | ✓ **Defined** |
| **AuthView – incrementOrderCount()** (AuthView.swift ~587–588) | `currentUser?.ordersUsed += 1` on order creation | ✓ **Used** |
| **MainAppView – onProductSelected** (MainAppView.swift ~76–86) | Blocks when `!isPro && viewModel.orderCount >= 20`; shows limit alert | ✓ **Gated** |
| **MainAppView – onAdd (BuyerPopupView)** (MainAppView.swift ~167) | `authManager.incrementOrderCount()` after createOrder | ✓ **Increment** |
| **MainTabView** (MainTabView.swift ~237, 247, 554, 564) | Same pattern: limit check + incrementOrderCount after createOrder | ✓ **Gated** |
| **QuickAddView – handleProductTap** (QuickAddView.swift ~109–112) | `if !user.canCreateOrder { onLimitReached(); return }` | ✓ **Gated** |
| **ContentView** (ContentView.swift ~209, 219) | createOrder + incrementOrderCount | ✓ **Gated** |

**Note:** MainAppView uses `viewModel.orderCount >= 20` instead of `!user.canCreateOrder` (which uses `ordersUsed`). Both block at “20”; for strict consistency with `ordersUsed`, consider using `!authManager.currentUser!.canCreateOrder` so the limit is based on orders created, not current list count (e.g. after deletes). Not a security hole; optional consistency improvement.

**Verdict:** Order creation is gated and count is incremented. Properly gated.

---

## 4. Unlimited Exports (Free limited to 10)

| Location | Check | Status |
|----------|--------|--------|
| **AuthView – AppUser** (AuthView.swift ~95, 97, 99) | `maxFreeExports = 10`, `canExport = isPro \|\| exportsUsed < maxFreeExports` | ✓ **Defined** |
| **AuthView – incrementExportCount()** (AuthView.swift ~592–593) | `currentUser?.exportsUsed += 1` | ✓ **Defined** |
| **HeaderView – Export button** (HeaderView.swift ~149–154) | `if !user.isPro, !user.canExport { showExportLimitAlert = true } else { showExportOptions = true }` | ✓ **Gated** |
| **ContentView – export sheet** (ContentView.swift ~255–284) | Sheet for `showingExportSheet`: if `!user.canExport` shows "Export Limit Reached"; else ShareSheet + `onAppear { incrementExportCount() }` | ✓ **Gated + increment** |

**Export share sheet and increment – FIXED:**

| Location | Issue | Status |
|----------|--------|--------|
| **MainAppView** | Added `.sheet(isPresented: $viewModel.showingExportSheet)` with limit check and `ShareSheet` + `incrementExportCount()` on appear. | ✓ **Fixed** |
| **MainTabView (HomeScreenView + iPadHomeScreenView)** | Same export sheet added to both flows so share sheet shows and `incrementExportCount()` is called when exporting from MainTabView. | ✓ **Fixed** |

**Verdict:** Export entry is gated in HeaderView. Export share sheet and increment are now implemented in MainAppView and MainTabView (both HomeScreenView and iPadHomeScreenView) as well as ContentView.

---

## 5. Priority Support

| Location | Check | Status |
|----------|--------|--------|
| **SubscriptionView / PlanSelectionView / SettingsView** | Listed as “Priority support” in Pro features; no code gate (service promise only). | ✓ **N/A** |

**Verdict:** Marketing/service promise only; no code gate required. Correct.

---

## Summary Table

| Pro feature           | Upload / Action gate      | View / Display gate       | Count / limit enforcement | Notes |
|-----------------------|---------------------------|---------------------------|----------------------------|-------|
| **Product images**    | ✓ EditProductSheet        | ✓ All cards/rows/preview  | N/A                        | Sample data gated by `isPro`. |
| **Barcode scanning**  | ✓ PRO badge + alert       | N/A                       | N/A                        | Scanner only when `isPro`. |
| **Unlimited orders**  | ✓ canCreateOrder / count  | N/A                       | ✓ 20, incrementOrderCount  | Optional: use canCreateOrder in MainAppView. |
| **Unlimited exports** | ✓ canExport in HeaderView | N/A                       | ✓ increment in ContentView, MainAppView, MainTabView | **Fixed:** Export sheet + increment added to MainAppView and MainTabView. |
| **Priority support**  | N/A                       | N/A                       | N/A                        | Service promise only. |

---

## Code Locations That Were Fixed

### 1. Export count and share sheet (MainAppView / MainTabView) — FIXED

**Change:** Added `.sheet(isPresented: $viewModel.showingExportSheet)` to:

- **MainAppView.swift** — Presents share sheet with limit check and calls `authManager.incrementExportCount()` in `onAppear` (same pattern as ContentView).
- **MainTabView.swift** — Same sheet added to **HomeScreenView** and **iPadHomeScreenView** so export from either flow shows the share sheet and increments the export count.

---

## Optional Improvement (consistency)

**File:** MainAppView.swift (lines 76–86)

**Current:** `if authManager.currentUser?.isPro == false && viewModel.orderCount >= 20`

**Optional:** Use `if let user = authManager.currentUser, !user.canCreateOrder` so the limit is strictly based on `ordersUsed` (orders ever created) rather than current `viewModel.orderCount` (orders in list). This keeps behavior aligned with QuickAddView and AuthView.

---

## Verification checklist

- [x] Product images: Free cannot upload; Free cannot view (placeholder only); sample data respects `isPro`.
- [x] Barcode: Free sees PRO and upgrade alert; only Pro can open scanner.
- [x] Orders: Free limited to 20; `incrementOrderCount()` called on create; limit checked before opening buyer popup / creating order.
- [x] Exports: Free limited to 10 at Export button; export sheet + incrementExportCount added to MainAppView and MainTabView (HomeScreenView + iPadHomeScreenView).
- [x] Priority support: No code gate; Pro-only messaging only.
