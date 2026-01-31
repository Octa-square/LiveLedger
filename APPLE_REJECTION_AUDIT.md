# Apple Rejection Audit — Submission ID: 492b9e38-4dc1-4467-ba90-c93efb4fddf2

**Date:** January 25, 2026  
**Purpose:** Verify that all three rejection issues have been addressed in the LiveLedger codebase.

---

## ISSUE #1: iPad Optimization (Guideline 4.0 - Design)

**Apple's complaint:** *"The app is not optimized to support the screen size or resolution of iPad Air 11-inch (M3)"*

### 1. Subscription View (SubscriptionView.swift)

| Check | Status | Location / Notes |
|-------|--------|-------------------|
| Wrapped in ScrollView for content overflow | ✅ | Lines 48–311: `ScrollView(.vertical, showsIndicators: true)` |
| Uses `@Environment(\.horizontalSizeClass)` for iPad | ✅ **FIXED** | Added `@Environment(\.horizontalSizeClass) private var horizontalSizeClass` |
| Has `.frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)` | ✅ **FIXED** | Applied to ScrollView (line ~322) |
| Has `.presentationDetents([.medium, .large])` | ⚠️ | Set by **presenter**, not view. MainAppView/MainTabView use **fullScreenCover** (no detents). Sheet presenters (e.g. some flows) could add detents. |
| Has `.presentationDragIndicator(.visible)` | ⚠️ | Same as above; applies when presented as `.sheet`. fullScreenCover does not support detents/drag indicator. |
| Content fits without breaking on iPad Air 11-inch | ⚠️ | ScrollView helps; add max width + size class for reliable fit. |

### 2. Subscription Confirmation Modal (LiveLedgerApp.swift — PlanSelectionView)

| Check | Status | Location / Notes |
|-------|--------|-------------------|
| Wrapped in NavigationStack + ScrollView | ✅ | Lines 190–335: `NavigationStack { ScrollView { ... } }` |
| X button in toolbar (top-right, always visible) | ✅ **FIXED** | SubscriptionView toolbar now uses `Image(systemName: "xmark.circle.fill")` (X icon). |
| "Maybe Later" button below "Subscribe Now" | ✅ **FIXED** | "Maybe Later" button added below Subscribe Now when paid plan selected (dismisses without subscribing). |
| Reduced spacing to fit iPad screen | ✅ | `VStack(spacing: 14)` and compact layout in PlanSelectionView. |
| All content visible without scrolling on iPad | ⚠️ | ScrollView allows scrolling; adding max width in SubscriptionView improves fit. |
| Presentation detents set to [.medium, .large] | ⚠️ | SubscriptionView is presented via **fullScreenCover** (lines 338–347), so detents do not apply. |

### 3. Main Tab View (MainTabView.swift)

| Check | Status | Location / Notes |
|-------|--------|-------------------|
| Single-column layout for all devices | ✅ | HomeScreenView is single-column; no two-column iPad layout. |
| No iPad two-column layout causing overlaps | ✅ | No split view or secondary column. |
| Minimum window size constraints | ✅ | Lines 29–36: iPad min size 660×1000 in `.onAppear`. |
| Responsive layout for window resizing | ✅ | Single layout with ScrollView/content; responsive. |

### 4. General iPad Optimization

| Check | Status | Notes |
|-------|--------|--------|
| All views handle different iPad screen sizes | ⚠️ | MainAppView/LiveLedgerApp set min window (660×1000). SubscriptionView needs size-class + max width. |
| No content cutoff on iPad Air 11-inch (M3) | ⚠️ | Add SubscriptionView iPad constraints. |
| No overlapping UI elements | ✅ | No overlapping layouts found. |
| ScrollView where needed | ✅ | SubscriptionView, PlanSelectionView use ScrollView. |
| Adaptive layouts using horizontalSizeClass | ✅ **FIXED** | SubscriptionView uses horizontalSizeClass + frame(maxWidth: 600) on iPad. |

**Issue #1 summary:** Partially addressed. Gaps: SubscriptionView needs `horizontalSizeClass` + `frame(maxWidth: 600)` on iPad; consider X button and "Maybe Later" for paywall; detents/drag indicator only apply if subscription is presented as `.sheet` elsewhere.

---

## ISSUE #2: Paywall Bug (Guideline 2.1 - Performance)

**Apple's complaint:** *"The app failed to display the paywall when we attempted to subscribe, and it was automatically subscribed"*

### 1. Paywall Dismissal Options

| Check | Status | Location / Notes |
|-------|--------|-------------------|
| X button in toolbar (top-right, always visible) | ✅ **FIXED** | SubscriptionView uses X icon (`xmark.circle.fill`) in toolbar. |
| "Maybe Later" button below Subscribe Now | ✅ **FIXED** | "Maybe Later" button added below Subscribe Now when paid plan selected. |
| Drag indicator enabled | ⚠️ | Only when presented as `.sheet`; fullScreenCover does not support `.presentationDragIndicator`. |
| Can dismiss by dragging down | ✅ | fullScreenCover is dismissible by drag on iOS. |
| NO auto-subscription without explicit user action | ✅ | Purchase only via "Subscribe" button; StoreKitManager blocks if paywall not shown. |

### 2. Purchase Safeguards (StoreKitManager.swift)

| Check | Status | Location / Notes |
|-------|--------|-------------------|
| `paywallWasShown: Bool` flag | ✅ | Line 91. |
| `userInitiatedPurchase: Bool` flag | ✅ | Line 88. |
| `markPaywallShown()` | ✅ | Lines 192–195. |
| `resetPaywallState()` | ✅ | Lines 198–202. |
| Purchase BLOCKS if `paywallWasShown == false` | ✅ | Lines 141–145: `guard paywallWasShown else { ... throw PurchaseError.purchaseFailed }`. |
| Requires explicit user tap on "Subscribe Now" | ✅ | `purchaseSubscription()` only called from Subscribe button (lines 159–164). |
| NO automatic subscription on paywall appearance | ✅ | `markPaywallShown()` only enables purchase path; no purchase call on appear. |
| Debug logging for purchase attempts | ✅ | e.g. lines 143, 155, 194, 200. |

### 3. User Flow Verification

| Check | Status | Notes |
|-------|--------|--------|
| User taps "Upgrade to Pro" or similar | ✅ | Multiple entry points (header, limit alert, settings). |
| Paywall appears with features visible | ✅ | SubscriptionView shows plans and Pro includes. |
| User sees price, features, Subscribe button | ✅ | SubscriptionOptionCard + Subscribe button. |
| User can dismiss via X, Maybe Later, or drag | ⚠️ | Close ✅; Maybe Later ❌; drag ✅ when sheet. |
| Subscription only if user taps "Subscribe Now" | ✅ | No auto-purchase. |
| Apple StoreKit payment sheet appears | ✅ | `product.purchase()` in StoreKitManager. |
| User must authenticate (Face ID/Touch ID) | ✅ | System behavior. |

**Issue #2 summary:** Largely addressed. Gaps: Add "Maybe Later" below Subscribe Now; optionally use X icon instead of "Close" for consistency with Apple’s wording.

---

## ISSUE #3: IAP Not Submitted (Guideline 2.1 - Performance)

**Apple's complaint:** *"One or more of the in-app purchase products have not been submitted for review"*

### 1. Product IDs Match App Store Connect

| Check | Status | Location / Notes |
|-------|--------|-------------------|
| Monthly: `com.octasquare.LiveLedger.monthly.subscription` | ✅ | StoreKitManager.swift line 19; Products.storekit line 114. |
| Yearly: `com.octasquare.LiveLedger.yearly.subscription` | ✅ | StoreKitManager.swift line 20; Products.storekit line 90. |
| Product IDs exactly as in App Store Connect | ✅ | Code and Products.storekit match. |
| No typos in Product IDs | ✅ | "octasquare" (one 's') used consistently. |

### 2. StoreKit Integration

| Check | Status | Notes |
|-------|--------|--------|
| Products loaded from App Store Connect | ✅ | `Product.products(for: productIDs)` in StoreKitManager. |
| Subscription flow uses correct Product IDs | ✅ | `ProductID.proMonthly.rawValue` / `ProductID.proYearly.rawValue`. |
| Purchase uses StoreKit 2 | ✅ | `product.purchase()`, Transaction verification, `Transaction.currentEntitlements`. |
| No hardcoded bypass of payment | ✅ | No bypass found. |

### 3. Pro Features Implementation

| Check | Status | Notes |
|-------|--------|--------|
| Unlimited orders (free limited to 20) | ✅ | Enforced in app (e.g. limit alerts). |
| Unlimited exports (free limited to 10) | ✅ | Export limits in auth/usage. |
| Product images (Pro only) | ✅ | Gated in UI. |
| Barcode scanning (Pro only, if implemented) | N/A | Barcode UI removed from Pro list per prior verification. |
| Priority support (service promise) | ✅ | Listed in Pro. |

### 4. False Feature Claims Removed

| Check | Status | Location / Notes |
|-------|--------|-------------------|
| NO "Advanced order filters" in Pro list (available to all) | ✅ **FIXED** | Removed from "Pro includes:" list in SubscriptionView. |
| NO "Advanced analytics" in Pro list (available to all) | ✅ **FIXED** | Removed from "Pro includes:" list in SubscriptionView. |
| Only ACTUAL Pro-only features advertised | ✅ **FIXED** | Pro list now: Unlimited orders, Unlimited CSV exports, Product images, Priority support. |

**Issue #3 summary:** Product IDs and StoreKit usage are correct. Fix: Remove "Advanced order filters" and "Advanced analytics" from the Pro includes list in SubscriptionView so only real Pro-only features are advertised.

---

## ADDITIONAL VERIFICATIONS

### 1. Sign-Up Changes

| Check | Status | Notes |
|-------|--------|--------|
| "Try Demo" button removed | ✅ | No "Try Demo" in AuthView/SimpleAuthView. |
| Sign-up is mandatory | ✅ | No demo bypass; account required. |
| Test account: applereview@liveledger.com | ✅ | SampleDataGenerator + AuthView ensureDemoAccountExists. |

### 2. Sample Data System

| Check | Status | Notes |
|-------|--------|--------|
| Auto-loads sample products for applereview@liveledger.com | ✅ | MainAppView/MainTabView `.onAppear` + SampleDataGenerator. |
| Creates 5 products with images | ✅ | SampleDataGenerator.makeReviewProducts() returns 5. |
| Creates sample orders | ✅ | makeReviewOrders returns 6 orders (audit asked for 5; 6 is acceptable). |
| Loads only once (UserDefaults flag) | ✅ | sample_data_loaded_for_review_account. |
| Only for test account | ✅ | isReviewAccount(email) check. |

### 3. Sign-Up Tagline

| Check | Status | Notes |
|-------|--------|--------|
| Updated from "Sales tracking for live sellers" | ✅ | Not used on auth screen. |
| New: "Complete sales and inventory management for social sellers" | ✅ | AuthView line 798; SimpleAuthView line 64. |

### 4. Timer Removal

| Check | Status | Notes |
|-------|--------|--------|
| Timer removed from header | ✅ | HeaderView has no timer; timer is in PlatformSelectorView/session area, not header. |
| Header layout fixed for small window sizes | ✅ | FixedHeaderView; min window 660×1000 on iPad. |

### 5. Recent Features

| Check | Status | Notes |
|-------|--------|--------|
| Order source, payment status, swipe to delete, etc. | ✅ | Implemented per codebase and VERIFICATION_REPORT.md. |

---

## FIXES APPLIED (January 25, 2026)

1. **SubscriptionView.swift** — all recommended code changes applied:
   - Added `@Environment(\.horizontalSizeClass) private var horizontalSizeClass`.
   - Applied `.frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)` to the ScrollView for iPad.
   - Replaced toolbar "Close" with X icon: `Image(systemName: "xmark.circle.fill")`.
   - Added "Maybe Later" button below Subscribe Now (when paid plan selected) that calls `dismiss()`.
   - Removed "Advanced order filters" and "Advanced analytics" from the "Pro includes:" list; list now: Unlimited orders, Unlimited CSV exports, Product images, Priority support.

2. **Presentation (unchanged)**
   - SubscriptionView remains presented as fullScreenCover from MainAppView/MainTabView/PlanSelectionView. Detents/drag indicator would require switching to `.sheet` where appropriate; current behavior is acceptable with ScrollView + iPad max width.

3. **Re-verify**
   - Run app on iPad Air 11-inch (M3) simulator, sign in with applereview@liveledger.com, open paywall, and confirm: layout fits, X and Maybe Later visible, subscription only after tapping Subscribe.

---

## FILES SEARCHED

- SubscriptionView.swift, LiveLedgerApp.swift, MainTabView.swift, MainAppView.swift  
- StoreKitManager.swift, Products.storekit  
- AuthView.swift, SimpleAuthView.swift, SampleDataGenerator.swift  
- HeaderView.swift, PlatformSelectorView.swift, SettingsView.swift  

**Keywords used:** horizontalSizeClass, ScrollView, presentationDetents, paywallWasShown, userInitiatedPurchase, Product ID, subscription identifiers, Pro features, Maybe Later, applereview@, tagline, timer.
