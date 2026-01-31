# Hardcoded Values Report – LiveLedger

All locations where hardcoded values appear, with file, line, value, usage, and recommendation.

---

## 1. API endpoints / URLs

| File | Line | Value | Used for |
|------|------|--------|----------|
| AuthView.swift | 1273 | `https://octa-square.github.io/LiveLedger/terms-of-service.html` | Terms of Service link |
| AuthView.swift | 1288 | `https://octa-square.github.io/LiveLedger/privacy-policy.html` | Privacy Policy link |
| SubscriptionView.swift | 303 | `https://octa-square.github.io/LiveLedger/terms-of-service.html` | Terms link in paywall |
| SubscriptionView.swift | 305 | `https://octa-square.github.io/LiveLedger/privacy-policy.html` | Privacy link in paywall |
| SubscriptionView.swift | 414 | `https://apps.apple.com/account/subscriptions` | Manage subscriptions (Apple) |
| SettingsView.swift | 778 | `https://example.com/privacy` | Privacy Policy link (wrong URL) |
| SettingsView.swift | 783 | `https://example.com/terms` | Terms of Service link (wrong URL) |
| SettingsView.swift | 797 | `https://wa.me/\(phoneNumber)?text=...` | WhatsApp support (URL scheme) |
| SettingsView.swift | 1490 | `https://octa-square.github.io/LiveLedger/terms-of-service.html` | Terms link |
| SettingsView.swift | 1500 | `https://octa-square.github.io/LiveLedger/privacy-policy.html` | Privacy link |

---

## 2. Email addresses

| File | Line | Value | Used for |
|------|------|--------|----------|
| SalesViewModel.swift | 283, 290, 294, 305, 453, 456 | `applereview@liveledger.com` | Sample data only for this account |
| MainTabView.swift | 38, 40 | `applereview@liveledger.com` | Sample data check |
| MainAppView.swift | 192, 194 | `applereview@liveledger.com` | Sample data check |
| AuthView.swift | 196 | `demo@liveledger.app` | Demo account (Pro) |
| AuthView.swift | 226 | `applereview@liveledger.com` | Apple Review test account |
| AuthView.swift | 270 | `review@liveledger.app` | Expired-subscription test account |
| AuthView.swift | 380 | `name@example.com` | Error message example |
| AuthView.swift | 1307 | `name@domain.com` | Validation error example |
| SimpleAuthView.swift | 228 | `name@domain.com` | Validation error example |
| SampleDataGenerator.swift | 6, 18, 20 | `applereview@liveledger.com` | Review account constant |
| SubscriptionView.swift | 52, 87, 458 | `review@liveledger.app` | Comments (lapsed UI) |
| ContentView.swift | 428 | `preview@example.com` | Preview data |
| SettingsView.swift | 832–833 | `admin@octasquare.com` | Support mailto link |

---

## 3. Product IDs (com.octasquare)

| File | Line | Value | Used for |
|------|------|--------|----------|
| Products.storekit | 2 | `com.octasquare.liveledger.products` | StoreKit config identifier |
| Products.storekit | 91 | `com.octasquare.LiveLedger.yearly.subscription` | Yearly product ID |
| Products.storekit | 116 | `com.octasquare.LiveLedger.monthly.subscription` | Monthly product ID |
| StoreKitManager.swift | 18 | `com.octasquare.LiveLedger.monthly.subscription` | ProductID enum |
| StoreKitManager.swift | 19 | `com.octasquare.LiveLedger.yearly.subscription` | ProductID enum |
| StoreKitManager.swift | 34–35 | Same IDs | Raw value constants |

---

## 4. Prices

| File | Line | Value | Used for |
|------|------|--------|----------|
| SampleDataGenerator.swift | 44, 53, 62, 71, 80 | 29.99, 49.99, 19.99, 79.99, 89.99 | Sample product prices |
| LiveLedgerApp.swift | 257 | `"$19.99"` | Plan selection – Pro Monthly |
| LiveLedgerApp.swift | 278 | `"$179.99"` | Plan selection – Pro Yearly |
| LiveLedgerApp.swift | 281 | `"Best Value – Save $60"` | Yearly plan copy |
| SubscriptionView.swift | 102, 170 | `"$179.99"` | Fallback yearly price |
| SubscriptionView.swift | 114, 173 | `"$19.99"` | Fallback monthly price |
| SettingsView.swift | 588, 1243 | `"$19.99/mo"` | Upgrade / Pro display |

---

## 5. Limits (orders / exports)

| File | Line | Value | Used for |
|------|------|--------|----------|
| AuthView.swift | 94–95 | `20`, `10` | `maxFreeOrders`, `maxFreeExports` (AppUser) |
| AuthView.swift | 76 | (order check) | `viewModel.orderCount >= 20` – uses limit |
| MainAppView.swift | 76, 84 | `20` | Free order limit check + alert message |
| MainAppView.swift | 222 | `10` | Export limit message |
| MainTabView.swift | 189, 454, 534 | `20` | “20 free orders” alert |
| MainTabView.swift | 286, 633 | `10` | “10 free exports” alert |
| HeaderView.swift | 207 | `10` | Export limit message |
| ContentView.swift | 149, 264 | `20`, `10` | Order/export limit messages |
| SalesViewModel.swift | 174 | `10` | Low-stock threshold (products with stock < 10) |
| StockBadgeView.swift | 10, 12, 20 | `10` | Stock level badge (≥10 = healthy) |
| StatisticsDashboardView.swift | 282, 284 | `10` | Low-stock definition |
| SubscriptionView.swift | 128 | `"20 orders included"` | Free tier copy |

---

## 6. Currency codes / lists

| File | Line | Value | Used for |
|------|------|--------|----------|
| AuthView.swift | 64–67 | `"USD ($)", "EUR (€)", ...` | AppUser.currencies list |
| AuthView.swift | 71–86 | Currency → symbol mapping | AppUser.currencySymbol |
| AuthView.swift | 759 | `"USD ($)"` | Default selectedCurrency (sign-up) |
| AuthView.swift | 207, 237, 288 | `"USD ($)"` | Demo/review account currency |
| SimpleAuthView.swift | 19, 28 | `"USD"`, `["USD", "EUR", "GBP", "NGN", "KES"]` | Default + currency list |
| SettingsView.swift | 1791 | `"USD ($)"` | Default in currency picker |
| ContentView.swift | 432 | `"USD ($)"` | Preview user |
| HeaderView.swift, etc. | (multiple) | `"$"` | Fallback currency symbol |

---

## 7. Phone numbers / test data

| File | Line | Value | Used for |
|------|------|--------|----------|
| SettingsView.swift | 795 | `"13477855007"` | WhatsApp support number (347-785-5007) |
| SettingsView.swift | 796 | `"Hi, I need help with LiveLedger app"` | WhatsApp pre-filled message |

---

## 8. Company / store names (test accounts)

| File | Line | Value | Used for |
|------|------|--------|----------|
| AuthView.swift | 202, 204–205 | "Demo User", "Demo Store", "123 Demo Street" | Demo account (demo@liveledger.app) |
| AuthView.swift | 232, 234–235 | "Apple Review", "Review Store", "1 Infinite Loop" | applereview@liveledger.com account |
| AuthView.swift | 285–286 | "Review Store", "1 Infinite Loop" | review@liveledger.app (expired) |

---

## 9. Security questions

| File | Line | Value | Used for |
|------|------|--------|----------|
| AuthView.swift | 18–20 | "What city were you born in?", "What is the name of your first pet?", "What is your mother's maiden name?" | SecurityQuestion default questions |
| AuthView.swift | 215–217, 245–247, 296–298 | Same 3 questions + answers "demo"/"review" | Demo/review account questions |
| AuthView.swift | 421–423 | Same 3 questions, answer "" | Legacy signUp default questions |
| AuthView.swift | 1242, 1246, 1251 | Same 3 questions | Sign-up form labels |
| AuthView.swift | 1346–1348 | Same 3 questions | Sign-up submission |

---

## 10. Passwords / referral codes (test accounts)

| File | Line | Value | Used for |
|------|------|--------|----------|
| AuthView.swift | 201 | `simpleHash("Demo123!")` | Demo account password |
| AuthView.swift | 211 | `"DEMO2024"` | Demo referral code |
| AuthView.swift | 231, 282 | `simpleHash("Review123!")` | Review / Apple Review passwords |
| AuthView.swift | 292 | `"REVIEW2024"` | Review account referral code |

---

## 11. Other notable hardcoded strings

| File | Line | Value | Used for |
|------|------|--------|----------|
| AuthView.swift | 1374, SimpleAuthView 310 | "First 20 orders FREE • No credit card required" | Marketing line |
| SubscriptionView.swift | 281 | "Best Value – Save $60" (or similar) | Yearly plan copy |
| LiveLedgerApp.swift | 66, 76, 163, 168 | 680, 1100, 660, 1000 | Window/default size, iPad min size |
| AuthView.swift | 272–274, 290–291, 303 | Dec 15 2025, 15 orders, 5 exports | Expired review account state |

---

# Recommendations

## Move to Config file (e.g. `AppConfig.swift` or plist)

- **URLs:** Terms, Privacy, Support (octa-square.github.io URLs, mailto, WhatsApp).  
  **Why:** Single place to change for legal/region or domain change.
- **Limits:** `maxFreeOrders` (20), `maxFreeExports` (10).  
  **Why:** Easier to run experiments or regional limits without code changes.
- **Support:** Support email (`admin@octasquare.com`), WhatsApp number, pre-filled message.  
  **Why:** Config per environment or region.
- **Fallback prices:** `"$19.99"`, `"$179.99"` in SubscriptionView / LiveLedgerApp.  
  **Why:** Fallback when StoreKit not loaded; keep in one place.

## Move to Environment / build config

- **Product IDs** (`com.octasquare.LiveLedger.*`).  
  **Why:** Different IDs for dev/sandbox/prod if you ever split.
- **API base URL** (if you add a real API later).  
  **Why:** Standard env-based config.

## Fetched from server (future)

- **Limits** (20 orders, 10 exports) – if you want A/B tests or regional limits.
- **Prices** – real prices come from StoreKit; server could drive copy or promos.
- **Security questions** – if you ever want configurable questions.

## User-configurable (already or in UI)

- **Currency:** Already user choice (AppUser.currencies, selectedCurrency). **Leave as is.**
- **Company/store name:** Already in sign-up and account. **Leave as is.**

## Left as is (truly constant)

- **applereview@liveledger.com** – Apple Review test account; single well-known constant.
- **demo@liveledger.app**, **review@liveledger.app** – Test accounts; change only if you rename accounts.
- **Security question text** – Same 3 questions everywhere; change only if product requirement changes.
- **Sample product prices** (29.99, 49.99, etc.) – Demo data only; no need to configure.
- **UI constants** – Opacity (0.15, 0.85), spacing (10, 20), font sizes, colors. **Leave as is.**
- **StoreKit product IDs** – Tied to App Store Connect; change only when products change.
- **Apple URLs** (e.g. apps.apple.com/account/subscriptions). **Leave as is.**

## Fix immediately

- **SettingsView.swift 778, 783:** Replace `https://example.com/privacy` and `https://example.com/terms` with real URLs (e.g. same octa-square.github.io URLs as elsewhere).

---

*Generated from project search. Line numbers are approximate; verify in IDE.*
