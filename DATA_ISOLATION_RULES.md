# Data Isolation Rules – Verification

## RULE 1: Sample data ONLY for applereview@liveledger.com

### 1. populateDemoData guard (SalesViewModel.swift ~line 317)

**Exact check at top:**

```swift
func populateDemoData(email: String?, isPro: Bool = false) {
    let normalized = (email ?? "").lowercased()
    guard normalized == "applereview@liveledger.com" else {
        print("[SampleData] Skipping - not review account")
        return
    }
    // ... rest of function
}
```

---

### 2. All 3 call sites (email checked before calling)

**A. MainAppView.swift – tryLoadSampleDataForReviewAccount() (~line 40)**

```swift
private func tryLoadSampleDataForReviewAccount() {
    guard let email = authManager.currentUser?.email else {
        print("[SampleData] MainAppView – no currentUser email")
        return
    }
    if email.lowercased() == "applereview@liveledger.com" {
        if !SampleDataGenerator.hasLoadedSampleData() {
            print("[SampleData] MainAppView – loading products for review account")
            viewModel.populateDemoData(email: email, isPro: authManager.currentUser?.isPro ?? false)
        }
    } else {
        viewModel.clearSampleDataForNonReviewUser(currentEmail: email)
    }
}
```
→ Only calls `populateDemoData` when email is applereview@liveledger.com.

**B. MainTabView.swift – onAppear (~line 40)**

```swift
if let email = authManager.currentUser?.email {
    // ...
    if email.lowercased() == "applereview@liveledger.com" {
        if !SampleDataGenerator.hasLoadedSampleData() {
            viewModel.populateDemoData(email: email, isPro: authManager.currentUser?.isPro ?? false)
        }
    } else {
        viewModel.clearSampleDataForNonReviewUser(currentEmail: email)
    }
}
```
→ Only calls `populateDemoData` when email is applereview@liveledger.com.

**C. SalesViewModel – notification observer (~line 282)**

```swift
) { [weak self] notification in
    let email = notification.userInfo?["email"] as? String
    print("[SampleData] Notification received – email: \(email ?? "nil")")
    guard let email = email, email.lowercased() == "applereview@liveledger.com" else {
        print("[SampleData] Observer skipping – not review account")
        return
    }
    let currentIsPro = self?.authManager?.currentUser?.isPro ?? false
    self?.populateDemoData(email: email, isPro: currentIsPro)
}
```
→ Only calls `populateDemoData` when email is applereview@liveledger.com.

---

### 3. Data loading – per-user keys (SalesViewModel.swift)

**Filename / key construction:**  
The app uses **UserDefaults** with **per-user keys** (no JSON file). Keys are built from user ID:

```swift
// ~line 243
private var userDataSuffix: String { "\(authManager?.currentUser?.id ?? "default")" }
private var catalogsKey: String { "livesales_catalogs_\(userDataSuffix)" }
private var selectedCatalogKey: String { "livesales_selected_catalog_\(userDataSuffix)" }
private var ordersKey: String { "livesales_orders_\(userDataSuffix)" }
private var platformsKey: String { "livesales_platforms_\(userDataSuffix)" }
```

So:
- Catalogs: `livesales_catalogs_<userId>`
- Orders: `livesales_orders_<userId>`
- Platforms: `livesales_platforms_<userId>`

**loadData()** uses these keys (~line 362):

```swift
func loadData() {
    if let catalogsData = UserDefaults.standard.data(forKey: catalogsKey), ...
    if let selectedIdString = UserDefaults.standard.string(forKey: selectedCatalogKey), ...
    if let ordersData = UserDefaults.standard.data(forKey: ordersKey), ...
    if let platformsData = UserDefaults.standard.data(forKey: platformsKey), ...
}
```

Each user’s data is isolated by `userDataSuffix` (current user id). There is no `liveledger_data_<userId>.json` file; isolation is via UserDefaults keys above.

---

## RULE 2: Account deletion – remove email completely, allow re-signup

### deleteAccountByEmail (AuthView.swift ~line 680)

**Complete function:**

```swift
func deleteAccountByEmail(_ email: String) {
    let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
    signUpError = nil
    var accounts = getAllAccounts()
    let countBefore = accounts.count
    accounts.removeAll(where: { $0.email.lowercased() == normalizedEmail })
    if accounts.isEmpty {
        UserDefaults.standard.removeObject(forKey: accountsKey)
    } else if countBefore != accounts.count {
        saveAllAccounts(accounts)
    }
    if currentUser?.email.lowercased() == normalizedEmail {
        currentUser = nil
        isAuthenticated = false
    }
    if let data = UserDefaults.standard.data(forKey: userKey),
       let savedUser = try? JSONDecoder().decode(AppUser.self, from: data),
       savedUser.email.lowercased() == normalizedEmail {
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    if normalizedEmail == "applereview@liveledger.com" {
        UserDefaults.standard.set(true, forKey: Self.applereviewDeletedByUserKey)
    }
    UserDefaults.standard.synchronize()
}
```

**Checklist:**

| Requirement | Done |
|-------------|------|
| 1. Remove from accounts array | ✅ `accounts.removeAll(where: ...)` then `saveAllAccounts(accounts)` or `removeObject(accountsKey)` |
| 2. Clear legacy userKey if it matches | ✅ Decode userKey, if email matches → `removeObject(forKey: userKey)` |
| 3. Clear currentUser if it matches | ✅ If `currentUser?.email` matches → `currentUser = nil` |
| 4. Set isAuthenticated = false | ✅ When currentUser matches |
| 5. Save accounts | ✅ `saveAllAccounts(accounts)` when list changed and not empty; or `removeObject(accountsKey)` when empty |

---

## Delete account on sign-up screen

**Finding:** There is **no** “Delete account for this email” button or alert on the **sign-up** flow.

- **Sign-up screen (SimpleAuthView, Sign Up tab):** Only sign-up fields and “Continue”. No delete-account option.
- **Log In screen (SimpleAuthView, Log In tab):** Has “Can’t sign in with applereview? Remove account to sign up again” – this is on **Log In**, not Sign Up, and is only for removing the applereview test account so the user can sign up again.
- **Settings:** “Delete Account” is for the **current** user to delete their own account, not “delete account for this email” during sign-up.

So no removal was required on the sign-up screen; the rules are satisfied as-is.
