# Pro Status Audit – All Locations

## 1. `upgradeToPro()` – EVERY call site

| File | Line | Context |
|------|------|--------|
| **AuthView.swift** | 624-625 | **Definition**: `func upgradeToPro() { currentUser?.isPro = true ... }` |
| **LiveLedgerApp.swift** | 393 | **After StoreKit purchase success**: `authManager.upgradeToPro()` inside `purchasePro()` after `try await storeKit.purchase(product)` ✅ |
| **SubscriptionView.swift** | 215 | **After Restore Purchases**: when `storeKit.subscriptionStatus.isActive` after `restorePurchases()` ✅ |
| **SubscriptionView.swift** | 406 | **After purchase success**: inside `purchaseSubscription()` after `try await storeKit.purchase(product)` ✅ |
| **LocalizationManager.swift** | 240, 543, 795, 1047 | String key `upgradeToPro` (localization only – not code that sets Pro) |

---

## 2. `currentUser?.isPro = true` / `isPro = true` (assignment)

| File | Line | Context |
|------|------|--------|
| **AuthView.swift** | 625 | **Only assignment**: inside `upgradeToPro()` – sets `currentUser?.isPro = true` |
| **AuthView.swift** | 319-320 | **BUG**: Observer for `.subscriptionStatusChanged` sets `self?.currentUser?.isPro = isPro` from notification. StoreKitManager posts this on **app launch** when it calls `updateSubscriptionStatus()`. So if the **device** has a Pro entitlement (e.g. same Apple ID, or previous purchase), **any** logged-in user gets Pro. FREE users can get Pro automatically. |
| **AuthView.swift** | 634 | `markSubscriptionExpired()` sets `currentUser?.isPro = false` (correct) |

---

## 3. `isPro: true` (literal in struct/initializers)

| File | Line | Context |
|------|------|--------|
| **AuthView.swift** | 188 | Comment: demo account `isPro: true` |
| **AuthView.swift** | 208 | Demo account 1 (demo@liveledger.app) – hardcoded Pro for App Store review ✅ |
| **AuthView.swift** | 238 | Demo account 2 (review@liveledger.app) – **was** `isPro: true`; should be `false` for purchase flow testing (verify intent) |
| **ContentView.swift** | 433 | Preview/sample user for SwiftUI previews – not production |

---

## 4. Root cause of FREE users getting Pro

**AuthView.swift lines 312-323** – `setupSubscriptionObserver()`:

```swift
NotificationCenter.default.addObserver(
    forName: .subscriptionStatusChanged,
    ...
) { [weak self] notification in
    if let isPro = notification.userInfo?["isPro"] as? Bool {
        self?.currentUser?.isPro = isPro   // ← BUG: applies device-level status to current user
        self?.saveUser()
    }
}
```

**StoreKitManager** posts `.subscriptionStatusChanged` with `isPro: subscriptionStatus.isActive`:
- On **app launch** (init → `updateSubscriptionStatus()` → `syncWithAuthManager()`)
- After **purchase** (updateSubscriptionStatus → syncWithAuthManager)
- After **restore** (same)
- From **transaction listener** (same)

So when the app launches, StoreKit reports **device/Apple ID** entitlement. If the device has Pro, the notification sends `isPro: true`. The observer then sets **currentUser?.isPro = true** for **whoever is logged in** – including FREE accounts. That is why FREE users get Pro without paying.

---

## 5. Fix

**Remove** the logic in AuthView that sets `currentUser?.isPro` from the `.subscriptionStatusChanged` notification. Pro must only be set by:

1. **upgradeToPro()** after successful purchase (LiveLedgerApp, SubscriptionView).
2. **upgradeToPro()** after successful Restore in UI (SubscriptionView) when `subscriptionStatus.isActive`.

Do **not** sync Pro status from the notification on app launch or from the transaction listener into `currentUser`; that sync is device-level and does not belong to the app account.
