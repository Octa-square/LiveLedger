# Sample Data Debug – Exact Code & What to Check

## 1. SalesViewModel.swift – `populateDemoData` (lines 313–341)

**CURRENT CODE:**

```swift
/// Populates the app with sample data ONLY for Apple Review test account (applereview@liveledger.com). All other emails get no sample data.
/// Loads once per device for that account only.
func populateDemoData(email: String?, isPro: Bool = false) {
    let normalized = (email ?? "").lowercased()
    guard normalized == "applereview@liveledger.com" else {
        print("[SampleData] Skipping sample data – not review account (email: \(email ?? "nil"))")
        return
    }
    print("[SampleData] populateDemoData() called for review account, isPro: \(isPro)")
    let alreadyLoaded = SampleDataGenerator.hasLoadedSampleData()
    print("UserDefaults sample_data_loaded_for_review_account: \(alreadyLoaded)")
    guard !alreadyLoaded else {
        print("[SampleData] Sample data already loaded, skipping")
        return
    }
    // Only create products for applereview@liveledger.com – no products for any other email (guard above ensures this)
    print("🔄 Creating sample products... (with images: \(isPro))")
    let reviewProducts = SampleDataGenerator.makeReviewProducts(isPro: isPro)
    let reviewOrders = SampleDataGenerator.makeReviewOrders(products: reviewProducts)
    let catalog = ProductCatalog(name: "Sample Products", products: reviewProducts)
    catalogs = [catalog]
    selectedCatalogId = catalog.id
    orders = reviewOrders
    print("✅ Saved \(reviewProducts.count) products")
    print("✅ Created \(reviewOrders.count) orders")
    saveData()
    SampleDataGenerator.markSampleDataLoaded()
    print("[SampleData] Data persisted and marked as loaded")
}
```

---

## 2. Where `populateDemoData` is called (3 locations)

### A. MainAppView.swift (onAppear ~lines 191–207)

**HOW IT'S CALLED:**

```swift
viewModel.authManager = authManager
viewModel.loadData() // Load this user's data (per-user keys)
// Sample data ONLY for applereview@liveledger.com – no sample data for any other email
if let email = authManager.currentUser?.email {
    print("[SampleData] MainAppView onAppear – email: \(email), hasLoadedSampleData: \(SampleDataGenerator.hasLoadedSampleData())")
    if email.lowercased() == "applereview@liveledger.com" {
        if !SampleDataGenerator.hasLoadedSampleData() {
            print("[SampleData] MainAppView – calling populateDemoData for review account")
            viewModel.populateDemoData(email: email, isPro: authManager.currentUser?.isPro ?? false)
        } else {
            print("[SampleData] MainAppView – skipping (already loaded)")
        }
    } else {
        // Non-review user: clear any sample data that was loaded from UserDefaults (e.g. from previous applereview session)
        viewModel.clearSampleDataForNonReviewUser(currentEmail: email)
    }
}
```

**When it runs:** After sign-in, when the user reaches **MainAppView** (LiveLedgerApp flow: Language → Sign in → Onboarding → Plan Selection → **MainAppView**).

---

### B. MainTabView.swift (onAppear ~lines 37–52)

**HOW IT'S CALLED:**

```swift
viewModel.authManager = authManager
viewModel.loadData() // Load this user's data (per-user keys)
// Sample data ONLY for applereview@liveledger.com – clear any loaded sample data for other users
if let email = authManager.currentUser?.email {
    print("[SampleData] MainTabView onAppear – email: \(email), hasLoadedSampleData: \(SampleDataGenerator.hasLoadedSampleData())")
    if email.lowercased() == "applereview@liveledger.com" {
        if !SampleDataGenerator.hasLoadedSampleData() {
            print("[SampleData] MainTabView – calling populateDemoData for review account")
            viewModel.populateDemoData(email: email, isPro: authManager.currentUser?.isPro ?? false)
        } else {
            print("[SampleData] MainTabView – skipping (already loaded)")
        }
    } else {
        viewModel.clearSampleDataForNonReviewUser(currentEmail: email)
    }
}
```

**When it runs:** When the user reaches **MainTabView** (RootView flow: after onboarding, if `hasSelectedPlan || isPro`).

---

### C. SalesViewModel notification observer (setupDemoDataObserver ~lines 278–293)

**HOW IT'S TRIGGERED:**

The observer is registered in `SalesViewModel.init()`. It runs when **AuthView** posts `.populateDemoData` **on sign-in success** (not sign-up). AuthView code (AuthView.swift ~498–504):

```swift
// Inside signInWithResult when password matches and account is applereview@liveledger.com:
let alreadyLoaded = SampleDataGenerator.hasLoadedSampleData()
print("UserDefaults sample_data_loaded_for_review_account: \(alreadyLoaded)")
if !alreadyLoaded {
    let isPro = currentUser?.isPro ?? true
    print("Posting .populateDemoData notification (isPro: \(isPro), email: \(email))")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        NotificationCenter.default.post(name: .populateDemoData, object: nil, userInfo: ["isPro": isPro, "email": email])
    }
}
```

**Observer code (SalesViewModel ~278–293):**

```swift
private func setupDemoDataObserver() {
    NotificationCenter.default.addObserver(
        forName: .populateDemoData,
        object: nil,
        queue: .main
    ) { [weak self] notification in
        let email = notification.userInfo?["email"] as? String
        print("[SampleData] Notification received – email: \(email ?? "nil")")
        guard let email = email, email.lowercased() == "applereview@liveledger.com" else {
            print("[SampleData] Observer skipping – not review account")
            return
        }
        let currentIsPro = self?.authManager?.currentUser?.isPro ?? false
        print("[SampleData] Observer calling populateDemoData (isPro: \(currentIsPro))")
        self?.populateDemoData(email: email, isPro: currentIsPro)
    }
}
```

**When it runs:** Only on **sign-in** (not sign-up), and only if the notification is posted from AuthView. The observer only runs if **SalesViewModel** (and thus MainAppView/MainTabView) already exists; if the app shows Plan Selection first, the view model exists and the observer will fire when the notification is posted.

---

## 3. Console output when you sign in as applereview@liveledger.com

**If sample data loads (first time, flag not set):**

- From **sign-in** (notification path):
  - `[SampleData] Posting .populateDemoData notification (isPro: false, email: applereview@liveledger.com)` (AuthView)
  - `UserDefaults sample_data_loaded_for_review_account: false`
  - `[SampleData] Notification received – email: applereview@liveledger.com`
  - `[SampleData] Observer calling populateDemoData (isPro: false)`
  - `[SampleData] populateDemoData() called for review account, isPro: false`
  - `[SampleData] Checking UserDefaults sample_data_loaded_for_review_account: false`
  - `UserDefaults sample_data_loaded_for_review_account: false`
  - `🔄 Creating sample products... (with images: false)`
  - `✅ Saved 5 products`
  - `✅ Created 5 orders`
  - `[SampleData] Data persisted and marked as loaded`

- When **MainAppView** or **MainTabView** then appears:
  - `[SampleData] MainAppView onAppear – email: applereview@liveledger.com, hasLoadedSampleData: true`  
    **or**  
  - `[SampleData] MainTabView onAppear – email: applereview@liveledger.com, hasLoadedSampleData: true`
  - Then they **do not** call `populateDemoData` again (already loaded).

**If sample data is skipped (flag already true):**

- `[SampleData] MainAppView onAppear – email: applereview@liveledger.com, hasLoadedSampleData: true`
- `[SampleData] MainAppView – skipping (already loaded)`

**If you don’t see any `[SampleData]` lines:**  
Neither the notification nor the MainAppView/MainTabView path is running for that email (wrong flow or email not applereview@liveledger.com).

**Possible errors:**  
None in the code above; failures would be from wrong flow, wrong email, or `hasLoadedSampleData() == true` from a previous run.

---

## 4. Xcode debugger after signing in as applereview@liveledger.com

**Where to break:**  
After you’re on the main screen (MainAppView or MainTabView), e.g. in a button action or in `body` of that view.

**Commands:**

```text
po viewModel.products.count
po authManager.currentUser?.email
```

**Expected if sample data loaded:**

- `viewModel.products.count` → **5**
- `authManager.currentUser?.email` → **"applereview@liveledger.com"** (or equivalent normalized string)

**If sample data did not load:**

- `viewModel.products.count` → **0** (or whatever the default/empty catalog has)
- `authManager.currentUser?.email` → **"applereview@liveledger.com"** (email can still be correct)

**Optional checks:**

```text
po viewModel.catalogs.count
po viewModel.catalogs.first?.name
po SampleDataGenerator.hasLoadedSampleData()
```

- After successful load: `catalogs.count` ≥ 1, `catalogs.first?.name` might be `"Sample Products"`, `hasLoadedSampleData()` → `true`.
- If the flag was already true before this sign-in: `hasLoadedSampleData()` is `true` but `products.count` could be 0 if data was cleared or never loaded in this session.

Paste your actual console output and these `po` results to see exactly what path ran and why sample data did or didn’t load.
