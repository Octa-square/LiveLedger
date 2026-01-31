//
//  LocalizationManager.swift
//  LiveLedger
//
//  LiveLedger - Multi-language Support
//

import SwiftUI
import Combine

// MARK: - Supported Languages
enum AppLanguage: String, CaseIterable, Codable {
    case english = "en"
    case french = "fr"
    case spanish = "es"
    case portuguese = "pt"
    case german = "de"
    case italian = "it"
    case chinese = "zh"
    case japanese = "ja"
    case korean = "ko"
    case arabic = "ar"
    case hindi = "hi"
    case russian = "ru"
    case dutch = "nl"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .french: return "Français"
        case .spanish: return "Español"
        case .portuguese: return "Português"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .chinese: return "中文"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .arabic: return "العربية"
        case .hindi: return "हिन्दी"
        case .russian: return "Русский"
        case .dutch: return "Nederlands"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .french: return "🇫🇷"
        case .spanish: return "🇪🇸"
        case .portuguese: return "🇧🇷"
        case .german: return "🇩🇪"
        case .italian: return "🇮🇹"
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .arabic: return "🇸🇦"
        case .hindi: return "🇮🇳"
        case .russian: return "🇷🇺"
        case .dutch: return "🇳🇱"
        }
    }
}

// MARK: - Localization Keys
enum LocalizedKey: String {
    // General
    case appName = "app_name"
    case save = "save"
    case cancel = "cancel"
    case delete = "delete"
    case edit = "edit"
    case add = "add"
    case done = "done"
    case close = "close"
    case settings = "settings"
    case upgrade = "upgrade"
    case free = "free"
    case pro = "pro"
    
    // Main Screen
    case totalSales = "total_sales"
    case outstanding = "outstanding"
    case itemsSold = "items_sold"
    case orders = "orders"
    case products = "products"
    case platform = "platform"
    case clear = "clear"
    case export = "export"
    case print = "print"
    case autoSaving = "auto_saving"
    case addPlatform = "add_platform"
    case platformName = "platform_name"
    case all = "all"
    case topSeller = "top_seller"
    case stockLeft = "stock_left"
    case totalOrders = "total_orders"
    case myProducts = "my_products"
    case quickAdd = "quick_add"
    
    // Products
    case tapToSell = "tap_to_sell"
    case holdToEdit = "hold_to_edit"
    case tapSellHoldEdit = "tap_sell_hold_edit"
    case holdToAddProduct = "hold_to_add_product"
    case stock = "stock"
    case price = "price"
    case discount = "discount"
    case outOfStock = "out_of_stock"
    case addProduct = "add_product"
    case editProduct = "edit_product"
    
    // Platforms
    case tiktok = "tiktok"
    case instagram = "instagram"
    case facebook = "facebook"
    
    // Settings Sections
    case analytics = "analytics"
    case displaySettings = "display_settings"
    case soundSettings = "sound_settings"
    case profileSettings = "profile_settings"
    case myStore = "my_store"
    case showOverlay = "show_overlay"
    case hideOverlay = "hide_overlay"
    
    // Orders
    case noOrders = "no_orders"
    case customer = "customer"
    case customerName = "customer_name"
    case quantity = "quantity"
    case total = "total"
    case paid = "paid"
    case unpaid = "unpaid"
    case pending = "pending"
    case unset = "unset"
    case fulfilled = "fulfilled"
    case printReceipt = "print_receipt"
    case orderSource = "order_source"
    case orderSources = "order_sources"
    case unpaidOrders = "unpaid_orders"
    case allSources = "all_sources"
    case phoneOptional = "phone_optional"
    case notesOptional = "notes_optional"
    case markAsPaid = "mark_as_paid"
    case markAsUnpaid = "mark_as_unpaid"
    case liveStream = "live_stream"
    case instagramDM = "instagram_dm"
    case facebookDM = "facebook_dm"
    case tiktokDM = "tiktok_dm"
    case whatsApp = "whatsapp"
    
    // Analytics
    case topSelling = "top_selling"
    case currentMonth = "current_month"
    case previousMonth = "previous_month"
    case salesAnalytics = "sales_analytics"
    case today = "today"
    case week = "week"
    case month = "month"
    case revenue = "revenue"
    case avgOrder = "avg_order"
    case salesTrend = "sales_trend"
    case byPlatform = "by_platform"
    case compare = "compare"
    case version = "version"
    case product = "product"
    case sold = "sold"
    case about = "about"
    
    // Settings
    case profile = "profile"
    case themes = "themes"
    case language = "language"
    case tutorial = "tutorial"
    case sendFeedback = "send_feedback"
    case privacyPolicy = "privacy_policy"
    case termsOfService = "terms_of_service"
    case signOut = "sign_out"
    case deleteAccount = "delete_account"
    case support = "support"
    
    // Having Issues / Support
    case havingIssues = "having_issues"
    case liveSupport = "live_support"
    case chatOnWhatsApp = "chat_on_whatsapp"
    case emailSupport = "email_support"
    case sendUsEmail = "send_us_email"
    case supportResponseTime = "support_response_time"
    
    // Auth
    case createAccount = "create_account"
    case fullName = "full_name"
    case email = "email"
    case password = "password"
    case companyName = "company_name"
    case referralCode = "referral_code"
    case agreeTerms = "agree_terms"
    case getStarted = "get_started"
    
    // Tutorial
    case welcomeTo = "welcome_to"
    case tutorialProducts = "tutorial_products"
    case tutorialOrders = "tutorial_orders"
    case tutorialPlatforms = "tutorial_platforms"
    case tutorialAnalytics = "tutorial_analytics"
    case tutorialExport = "tutorial_export"
    case letsGo = "lets_go"
    case next = "next"
    case skip = "skip"
    
    // Plan Selection
    case choosePlan = "choose_plan"
    case selectPlanDescription = "select_plan_description"
    case basicPlan = "basic_plan"
    case proPlan = "pro_plan"
    case forever = "forever"
    case perMonth = "per_month"
    case greatForStarting = "great_for_starting"
    case unlimited = "unlimited_everything"
    case firstOrdersFree = "first_orders_free"
    case basicInventory = "basic_inventory"
    case csvExports = "csv_exports"
    case standardReports = "standard_reports"
    case limitedOrders = "limited_orders"
    case noAdvancedFilters = "no_advanced_filters"
    case noProductImages = "no_product_images"
    case unlimitedOrders = "unlimited_orders"
    case unlimitedExports = "unlimited_exports"
    case productImages = "product_images"
    case advancedAnalytics = "advanced_analytics"
    case orderFilters = "order_filters"
    case prioritySupport = "priority_support"
    case allFutureFeatures = "all_future_features"
    case continueWithPro = "continue_with_pro"
    case continueWithBasic = "continue_with_basic"
    case cancelAnytime = "cancel_anytime"
    case dayFreeTrial = "day_free_trial"
    case welcomeToPro = "welcome_to_pro"
    case proSubscriptionActive = "pro_subscription_active"
    case upgradeToPro = "upgrade_to_pro"
    case subscribeNow = "subscribe_now"
    case maybeLater = "maybe_later"
    case benefits = "benefits"
    
    // Language Selection
    case welcomeToLiveLedger = "welcome_to_liveledger"
    case selectLanguage = "select_language"
    case selectYourLanguage = "select_your_language"
    case continueText = "continue"
    
    // Common UI Elements
    case back = "back"
    case getStartedText = "get_started_text"
    case description = "description"
    case developer = "developer"
    case termsAndPrivacy = "terms_and_privacy"
    case company = "company"
    case yourName = "your_name"
    case personalInformation = "personal_information"
    case security = "security"
    case changePassword = "change_password"
    case currentPassword = "current_password"
    case newPassword = "new_password"
    case confirmNewPassword = "confirm_new_password"
    case passwordMustContain = "password_must_contain"
    case atLeastChars = "at_least_chars"
    case atLeastOneLetter = "at_least_one_letter"
    case atLeastOneSymbol = "at_least_one_symbol"
    case currentPasswordIncorrect = "current_password_incorrect"
    case storeInformation = "store_information"
    case storeName = "store_name"
    case address = "address"
    case businessPhone = "business_phone"
    case infoAppearsOnReceipts = "info_appears_on_receipts"
    case currency = "currency"
    case phoneNumber = "phone_number"
    case changePhoto = "change_photo"
    
    // Feedback
    case sendFeedbackTitle = "send_feedback_title"
    case type = "type"
    case feedbackType = "feedback_type"
    case message = "message"
    case suggestion = "suggestion"
    case bugReport = "bug_report"
    case question = "question"
    case other = "other"
    
    // Network Test
    case network = "network"
    case connection = "connection"
    case connectionStatus = "connection_status"
    case connected = "connected"
    case wifi = "wifi"
    case speedTestResults = "speed_test_results"
    case download = "download"
    case upload = "upload"
    case latency = "latency"
    case assessment = "assessment"
    case streamQuality = "stream_quality"
    case notTested = "not_tested"
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    case testNetwork = "test_network"
    case testingText = "testing"
    case forBestStreaming = "for_best_streaming"
    
    // Display Settings
    case display = "display"
    case screenBrightness = "screen_brightness"
    case useControlCenter = "use_control_center"
    case swipeDownFromTop = "swipe_down_from_top"
    case theme = "theme"
    case chooseTheme = "choose_theme"
    case reset = "reset"
    case resetToDefaults = "reset_to_defaults"
    
    // Subscription Status
    case subscriptionExpired = "subscription_expired"
    case expiredOn = "expired_on"
    case resubscribeMessage = "resubscribe_message"
    case resubscribeToPro = "resubscribe_to_pro"
    case freePlan = "free_plan"
    case expired = "expired"
    
    // Privacy & Terms
    case dataCollection = "data_collection"
    case dataCollectionMessage = "data_collection_message"
    case thirdPartyServices = "third_party_services"
    case thirdPartyMessage = "third_party_message"
    case privacySummary = "privacy_summary"
    
    // Alerts & Confirmations
    case deleteAccountQuestion = "delete_account_question"
    case deleteAccountMessage = "delete_account_message"
    case cannotBeUndone = "cannot_be_undone"
    
    // Onboarding Extended
    case welcomeMessage = "welcome_message"
    case step1 = "step_1"
    case step2 = "step_2"
    case step3 = "step_3"
    case step4 = "step_4"
    case step5 = "step_5"
    case step6 = "step_6"
    case addYourProducts = "add_your_products"
    case recordSales = "record_sales"
    case startLiveSession = "start_live_session"
    case selectYourPlatform = "select_your_platform"
    case manageYourOrders = "manage_your_orders"
    case exportYourData = "export_your_data"
    case navigation = "navigation"
    case customizeExperience = "customize_experience"
    case proTips = "pro_tips"
}

// MARK: - Localization Manager
class LocalizationManager: ObservableObject {
    @Published var currentLanguage: AppLanguage {
        didSet {
            if let encoded = try? JSONEncoder().encode(currentLanguage) {
                UserDefaults.standard.set(encoded, forKey: "app_language")
            }
        }
    }
    
    static let shared = LocalizationManager()
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "app_language"),
           let language = try? JSONDecoder().decode(AppLanguage.self, from: data) {
            currentLanguage = language
        } else {
            currentLanguage = .english
        }
    }
    
    func localized(_ key: LocalizedKey) -> String {
        // Try current language first
        if let translation = translations[currentLanguage]?[key] {
            return translation
        }
        // Fallback to English if key doesn't exist in current language
        return translations[.english]?[key] ?? key.rawValue
    }
    
    // MARK: - Translations Dictionary
    private let translations: [AppLanguage: [LocalizedKey: String]] = [
        .english: [
            .appName: "LiveLedger",
            .save: "Save",
            .cancel: "Cancel",
            .delete: "Delete",
            .edit: "Edit",
            .add: "Add",
            .done: "Done",
            .close: "Close",
            .settings: "Settings",
            .upgrade: "Upgrade",
            .free: "Free",
            .pro: "Pro",
            .totalSales: "Total Sales",
            .outstanding: "Outstanding",
            .itemsSold: "Items Sold",
            .orders: "Orders",
            .products: "Products",
            .platform: "Platform",
            .clear: "Clear",
            .export: "Export",
            .print: "Print",
            .autoSaving: "Auto-saving",
            .addPlatform: "Add Platform",
            .platformName: "Platform Name",
            .all: "All",
            .topSeller: "Top Seller",
            .stockLeft: "Stock Left",
            .totalOrders: "Total Orders",
            .myProducts: "My Products",
            .quickAdd: "Quick Add",
            .tapToSell: "Tap to sell",
            .holdToEdit: "Hold to edit",
            .tapSellHoldEdit: "Tap: Sell • Hold: Edit",
            .holdToAddProduct: "Hold to add product",
            .stock: "Stock",
            .price: "Price",
            .discount: "Discount",
            .outOfStock: "Out of stock",
            .addProduct: "Add Product",
            .editProduct: "Edit Product",
            .tiktok: "TikTok",
            .instagram: "Instagram",
            .facebook: "Facebook",
            .analytics: "Analytics",
            .displaySettings: "Display Settings",
            .soundSettings: "Sound Settings",
            .profileSettings: "Profile Settings",
            .myStore: "My Store",
            .showOverlay: "Show Overlay",
            .hideOverlay: "Hide Overlay",
            .noOrders: "No orders yet",
            .customer: "Customer",
            .quantity: "Quantity",
            .total: "Total",
            .paid: "Paid",
            .pending: "Pending",
            .unset: "Unset",
            .fulfilled: "Done",
            .printReceipt: "Print Receipt",
            .unpaid: "Unpaid",
            .orderSource: "Order Source",
            .orderSources: "Order Sources",
            .unpaidOrders: "Unpaid Orders",
            .allSources: "All Sources",
            .customerName: "Customer Name",
            .phoneOptional: "Phone (optional)",
            .notesOptional: "Notes (optional)",
            .markAsPaid: "Mark as Paid",
            .markAsUnpaid: "Mark as Unpaid",
            .liveStream: "Live Stream",
            .instagramDM: "Instagram DM",
            .facebookDM: "Facebook DM",
            .tiktokDM: "TikTok DM",
            .whatsApp: "WhatsApp",
            .topSelling: "Top Selling",
            .currentMonth: "This Month",
            .previousMonth: "Last Month",
            .salesAnalytics: "Sales Analytics",
            .today: "Today",
            .week: "Week",
            .month: "Month",
            .revenue: "Revenue",
            .avgOrder: "Avg Order",
            .salesTrend: "Sales Trend",
            .byPlatform: "By Platform",
            .compare: "Compare",
            .version: "Version",
            .product: "Product",
            .sold: "sold",
            .about: "About",
            .profile: "Profile",
            .themes: "Themes",
            .language: "Language",
            .tutorial: "Tutorial",
            .sendFeedback: "Send Feedback",
            .privacyPolicy: "Privacy Policy",
            .termsOfService: "Terms of Service",
            .signOut: "Sign Out",
            .deleteAccount: "Delete Account",
            .createAccount: "Create Account",
            .fullName: "Full Name",
            .email: "Email",
            .password: "Password",
            .companyName: "Company Name",
            .referralCode: "Referral Code",
            .agreeTerms: "I agree to the Terms",
            .getStarted: "Get Started",
            .welcomeTo: "Welcome to",
            .tutorialProducts: "Add products before, during, or after your live streams. Tap to instantly create orders!",
            .tutorialOrders: "Track orders with total sales, top seller, stock levels & order count",
            .tutorialPlatforms: "Switch between TikTok, Instagram, Facebook or add custom platforms",
            .tutorialAnalytics: "View real-time dashboard with sales analytics and inventory alerts",
            .tutorialExport: "Export orders to CSV, print receipts, and share reports with VoiceOver accessibility",
            .letsGo: "Let's Go!",
            .next: "Next",
            .skip: "Skip",
            .support: "Support",
            .havingIssues: "Having Issues?",
            .liveSupport: "Live Support",
            .chatOnWhatsApp: "Chat with us on WhatsApp",
            .emailSupport: "Email Support",
            .sendUsEmail: "Send us an email",
            .supportResponseTime: "We typically respond within 24 hours",
            .choosePlan: "Choose Your Plan",
            .selectPlanDescription: "Select how you want to use LiveLedger",
            .basicPlan: "Basic",
            .proPlan: "Pro",
            .forever: "forever",
            .perMonth: "/month",
            .greatForStarting: "Great for getting started",
            .unlimited: "Unlimited everything for serious sellers",
            .firstOrdersFree: "First 20 orders free",
            .basicInventory: "Basic inventory management",
            .csvExports: "10 CSV exports",
            .standardReports: "Standard reports",
            .limitedOrders: "Limited orders",
            .noAdvancedFilters: "No advanced filters",
            .noProductImages: "No product images",
            .unlimitedOrders: "Unlimited orders",
            .unlimitedExports: "Unlimited exports",
            .productImages: "Product images",
            .advancedAnalytics: "Advanced analytics",
            .orderFilters: "Order filters",
            .prioritySupport: "Priority support",
            .allFutureFeatures: "All future features",
            .continueWithPro: "Continue with Pro",
            .continueWithBasic: "Continue with Basic",
            .cancelAnytime: "Cancel anytime",
            .dayFreeTrial: "7-day free trial",
            .welcomeToPro: "Welcome to Pro! 🎉",
            .proSubscriptionActive: "Your Pro subscription is now active. Enjoy unlimited orders and all premium features!",
            .upgradeToPro: "Upgrade to Pro",
            .subscribeNow: "Subscribe Now",
            .maybeLater: "Maybe Later",
            .benefits: "Benefits",
            .welcomeToLiveLedger: "Welcome to LiveLedger",
            .selectLanguage: "Select Language",
            .selectYourLanguage: "Select Your Language",
            .continueText: "Continue",
            .back: "Back",
            .getStartedText: "Get Started!",
            .description: "Description",
            .developer: "Developer",
            .termsAndPrivacy: "Terms & Privacy",
            .company: "Company",
            .yourName: "Your Name",
            .personalInformation: "Personal Information",
            .security: "Security",
            .changePassword: "Change Password",
            .currentPassword: "Current Password",
            .newPassword: "New Password",
            .confirmNewPassword: "Confirm New Password",
            .passwordMustContain: "Password must contain:",
            .atLeastChars: "At least 6 characters",
            .atLeastOneLetter: "At least one letter",
            .atLeastOneSymbol: "At least one symbol (!@#$%...)",
            .currentPasswordIncorrect: "Current password is incorrect",
            .storeInformation: "Store Information",
            .storeName: "Store Name",
            .address: "Address",
            .businessPhone: "Business Phone",
            .infoAppearsOnReceipts: "This information appears on receipts and reports",
            .currency: "Currency",
            .phoneNumber: "Phone Number",
            .changePhoto: "Change Photo",
            .sendFeedbackTitle: "Send Feedback",
            .type: "Type",
            .feedbackType: "Feedback Type",
            .message: "Message",
            .suggestion: "Suggestion",
            .bugReport: "Bug Report",
            .question: "Question",
            .other: "Other",
            .network: "Network",
            .connection: "Connection",
            .connectionStatus: "Connection Status",
            .connected: "Connected",
            .wifi: "Wi-Fi",
            .speedTestResults: "Speed Test Results",
            .download: "Download",
            .upload: "Upload",
            .latency: "Latency",
            .assessment: "Assessment",
            .streamQuality: "Stream Quality",
            .notTested: "Not Tested",
            .excellent: "Excellent",
            .good: "Good",
            .fair: "Fair",
            .poor: "Poor",
            .testNetwork: "Test Network Bandwidth",
            .testingText: "Testing...",
            .forBestStreaming: "For best streaming: Download > 50 Mbps, Upload > 10 Mbps, Latency < 50ms",
            .display: "Display",
            .screenBrightness: "Screen Brightness",
            .useControlCenter: "Use iPhone Control Center to adjust brightness",
            .swipeDownFromTop: "Swipe down from top-right corner to access Control Center",
            .theme: "Theme",
            .chooseTheme: "Choose your preferred visual theme",
            .reset: "Reset",
            .resetToDefaults: "Reset to Defaults",
            .subscriptionExpired: "Your Pro subscription expired",
            .expiredOn: "Expired on",
            .resubscribeMessage: "Resubscribe to continue using unlimited orders, exports, and all Pro features.",
            .resubscribeToPro: "Resubscribe to Pro",
            .freePlan: "Free Plan",
            .expired: "EXPIRED",
            .dataCollection: "Data Collection",
            .dataCollectionMessage: "LiveLedger stores all your data locally on your device. We do not collect, transmit, or store your sales data on any external servers.",
            .thirdPartyServices: "Third-Party Services",
            .thirdPartyMessage: "We use Apple's StoreKit for in-app purchases. No personal data is shared with third parties.",
            .privacySummary: "Privacy Summary",
            .deleteAccountQuestion: "Delete Account?",
            .deleteAccountMessage: "This will permanently delete your account and all data.",
            .cannotBeUndone: "This cannot be undone.",
            .welcomeMessage: "Your complete live selling companion! Track orders in real-time, manage multiple platforms, and grow your business with powerful insights. Let's show you how it works.",
            .step1: "Step 1",
            .step2: "Step 2",
            .step3: "Step 3",
            .step4: "Step 4",
            .step5: "Step 5",
            .step6: "Step 6",
            .addYourProducts: "Add Your Products",
            .recordSales: "Record Sales",
            .startLiveSession: "Start Your Live Session",
            .selectYourPlatform: "Select Your Platform",
            .manageYourOrders: "Manage Your Orders",
            .exportYourData: "Export Your Data",
            .navigation: "Using the Bottom Navigation",
            .customizeExperience: "Customize Your Experience",
            .proTips: "Pro Tips for Success"
        ],
        .french: [
            .appName: "LiveLedger",
            .save: "Enregistrer",
            .cancel: "Annuler",
            .delete: "Supprimer",
            .edit: "Modifier",
            .add: "Ajouter",
            .done: "Terminé",
            .close: "Fermer",
            .settings: "Paramètres",
            .upgrade: "Améliorer",
            .free: "Gratuit",
            .pro: "Pro",
            .totalSales: "Ventes Totales",
            .outstanding: "En Attente",
            .itemsSold: "Articles Vendus",
            .orders: "Commandes",
            .products: "Produits",
            .platform: "Plateforme",
            .clear: "Effacer",
            .export: "Exporter",
            .print: "Imprimer",
            .autoSaving: "Sauvegarde auto",
            .addPlatform: "Ajouter Plateforme",
            .platformName: "Nom de Plateforme",
            .all: "Tous",
            .topSeller: "Meilleure Vente",
            .stockLeft: "Stock Restant",
            .totalOrders: "Total Commandes",
            .myProducts: "Mes Produits",
            .quickAdd: "Ajout Rapide",
            .tapToSell: "Appuyez pour vendre",
            .holdToEdit: "Maintenez pour modifier",
            .tapSellHoldEdit: "Tap: Vendre • Tenir: Modifier",
            .holdToAddProduct: "Maintenez pour ajouter",
            .stock: "Stock",
            .price: "Prix",
            .discount: "Réduction",
            .outOfStock: "Rupture de stock",
            .addProduct: "Ajouter Produit",
            .editProduct: "Modifier Produit",
            .tiktok: "TikTok",
            .instagram: "Instagram",
            .facebook: "Facebook",
            .analytics: "Analytique",
            .displaySettings: "Affichage",
            .soundSettings: "Sons",
            .profileSettings: "Profil",
            .myStore: "Ma Boutique",
            .showOverlay: "Afficher Overlay",
            .hideOverlay: "Masquer Overlay",
            .noOrders: "Aucune commande",
            .customer: "Client",
            .quantity: "Quantité",
            .total: "Total",
            .paid: "Payé",
            .pending: "En attente",
            .unset: "Non défini",
            .fulfilled: "Terminé",
            .printReceipt: "Imprimer Reçu",
            .unpaid: "Impayé",
            .orderSource: "Source de commande",
            .orderSources: "Sources de commandes",
            .unpaidOrders: "Commandes impayées",
            .allSources: "Toutes sources",
            .customerName: "Nom du client",
            .phoneOptional: "Téléphone (optionnel)",
            .notesOptional: "Notes (optionnel)",
            .markAsPaid: "Marquer comme payé",
            .markAsUnpaid: "Marquer comme impayé",
            .liveStream: "Live Stream",
            .instagramDM: "Instagram DM",
            .facebookDM: "Facebook DM",
            .tiktokDM: "TikTok DM",
            .whatsApp: "WhatsApp",
            .topSelling: "Meilleures Ventes",
            .currentMonth: "Ce Mois",
            .previousMonth: "Mois Dernier",
            .salesAnalytics: "Analyse des Ventes",
            .today: "Aujourd'hui",
            .week: "Semaine",
            .month: "Mois",
            .revenue: "Revenu",
            .avgOrder: "Commande Moy.",
            .salesTrend: "Tendance des Ventes",
            .byPlatform: "Par Plateforme",
            .compare: "Comparer",
            .version: "Version",
            .product: "Produit",
            .sold: "vendu(s)",
            .about: "À propos",
            .profile: "Profil",
            .themes: "Thèmes",
            .language: "Langue",
            .tutorial: "Tutoriel",
            .sendFeedback: "Envoyer Commentaires",
            .privacyPolicy: "Politique de Confidentialité",
            .termsOfService: "Conditions d'Utilisation",
            .signOut: "Déconnexion",
            .deleteAccount: "Supprimer le Compte",
            .createAccount: "Créer un Compte",
            .fullName: "Nom Complet",
            .email: "E-mail",
            .password: "Mot de passe",
            .companyName: "Nom de l'Entreprise",
            .referralCode: "Code de Parrainage",
            .agreeTerms: "J'accepte les conditions",
            .getStarted: "Commencer",
            .welcomeTo: "Bienvenue sur",
            .tutorialProducts: "Ajoutez vos produits et appuyez pour créer des commandes instantanément",
            .tutorialOrders: "Suivez toutes les commandes avec les détails des acheteurs",
            .tutorialPlatforms: "Passez de TikTok à Instagram, Facebook ou ajoutez des plateformes",
            .tutorialAnalytics: "Consultez les rapports de ventes et exportez les données",
            .tutorialExport: "Exportez les commandes en CSV et imprimez les reçus",
            .letsGo: "C'est Parti!",
            .next: "Suivant",
            .skip: "Passer",
            .support: "Support",
            .havingIssues: "Des Problèmes?",
            .liveSupport: "Support en Direct",
            .chatOnWhatsApp: "Discutez avec nous sur WhatsApp",
            .emailSupport: "Support par Email",
            .sendUsEmail: "Envoyez-nous un email",
            .supportResponseTime: "Nous répondons généralement sous 24 heures",
            .choosePlan: "Choisissez Votre Plan",
            .selectPlanDescription: "Sélectionnez comment vous souhaitez utiliser LiveLedger",
            .basicPlan: "Basique",
            .proPlan: "Pro",
            .forever: "pour toujours",
            .perMonth: "/mois",
            .greatForStarting: "Parfait pour commencer",
            .unlimited: "Tout illimité pour les vendeurs sérieux",
            .firstOrdersFree: "Premières 20 commandes gratuites",
            .basicInventory: "Gestion basique d'inventaire",
            .csvExports: "10 exportations CSV",
            .standardReports: "Rapports standard",
            .limitedOrders: "Commandes limitées",
            .noAdvancedFilters: "Pas de filtres avancés",
            .noProductImages: "Pas d'images de produits",
            .unlimitedOrders: "Commandes illimitées",
            .unlimitedExports: "Exportations illimitées",
            .productImages: "Images de produits",
            .advancedAnalytics: "Analyses avancées",
            .orderFilters: "Filtres de commandes",
            .prioritySupport: "Support prioritaire",
            .allFutureFeatures: "Toutes les fonctionnalités futures",
            .continueWithPro: "Continuer avec Pro",
            .continueWithBasic: "Continuer avec Basique",
            .cancelAnytime: "Annuler à tout moment",
            .dayFreeTrial: "7 jours d'essai gratuit",
            .welcomeToPro: "Bienvenue à Pro! 🎉",
            .proSubscriptionActive: "Votre abonnement Pro est maintenant actif. Profitez de commandes illimitées et toutes les fonctionnalités premium!",
            .upgradeToPro: "Passer à Pro",
            .subscribeNow: "S'abonner Maintenant",
            .maybeLater: "Peut-être Plus Tard",
            .benefits: "Avantages",
            .welcomeToLiveLedger: "Bienvenue sur LiveLedger",
            .selectLanguage: "Sélectionner la Langue",
            .selectYourLanguage: "Sélectionnez Votre Langue",
            .continueText: "Continuer",
            .back: "Retour",
            .getStartedText: "Commencer!",
            .description: "Description",
            .developer: "Développeur",
            .termsAndPrivacy: "Conditions et Confidentialité",
            .company: "Entreprise",
            .yourName: "Votre Nom",
            .personalInformation: "Informations Personnelles",
            .security: "Sécurité",
            .changePassword: "Changer le Mot de Passe",
            .currentPassword: "Mot de Passe Actuel",
            .newPassword: "Nouveau Mot de Passe",
            .confirmNewPassword: "Confirmer le Nouveau Mot de Passe",
            .passwordMustContain: "Le mot de passe doit contenir:",
            .atLeastChars: "Au moins 6 caractères",
            .atLeastOneLetter: "Au moins une lettre",
            .atLeastOneSymbol: "Au moins un symbole (!@#$%...)",
            .currentPasswordIncorrect: "Le mot de passe actuel est incorrect",
            .storeInformation: "Informations de Boutique",
            .storeName: "Nom de Boutique",
            .address: "Adresse",
            .businessPhone: "Téléphone Professionnel",
            .infoAppearsOnReceipts: "Ces informations apparaissent sur les reçus et rapports",
            .currency: "Devise",
            .phoneNumber: "Numéro de Téléphone",
            .changePhoto: "Changer la Photo",
            .sendFeedbackTitle: "Envoyer un Commentaire",
            .type: "Type",
            .feedbackType: "Type de Commentaire",
            .message: "Message",
            .suggestion: "Suggestion",
            .bugReport: "Rapport de Bug",
            .question: "Question",
            .other: "Autre",
            .network: "Réseau",
            .connection: "Connexion",
            .connectionStatus: "État de Connexion",
            .connected: "Connecté",
            .wifi: "Wi-Fi",
            .speedTestResults: "Résultats du Test de Vitesse",
            .download: "Téléchargement",
            .upload: "Envoi",
            .latency: "Latence",
            .assessment: "Évaluation",
            .streamQuality: "Qualité du Stream",
            .notTested: "Non Testé",
            .excellent: "Excellent",
            .good: "Bon",
            .fair: "Moyen",
            .poor: "Faible",
            .testNetwork: "Tester la Bande Passante",
            .testingText: "Test en cours...",
            .forBestStreaming: "Pour un meilleur streaming: Téléchargement > 50 Mbps, Envoi > 10 Mbps, Latence < 50ms",
            .display: "Affichage",
            .screenBrightness: "Luminosité de l'Écran",
            .useControlCenter: "Utilisez le Centre de Contrôle de l'iPhone pour ajuster la luminosité",
            .swipeDownFromTop: "Glissez vers le bas depuis le coin supérieur droit pour accéder au Centre de Contrôle",
            .theme: "Thème",
            .chooseTheme: "Choisissez votre thème visuel préféré",
            .reset: "Réinitialiser",
            .resetToDefaults: "Réinitialiser par Défaut",
            .subscriptionExpired: "Votre abonnement Pro a expiré",
            .expiredOn: "Expiré le",
            .resubscribeMessage: "Réabonnez-vous pour continuer à utiliser les commandes illimitées, les exportations et toutes les fonctionnalités Pro.",
            .resubscribeToPro: "Se Réabonner à Pro",
            .freePlan: "Plan Gratuit",
            .expired: "EXPIRÉ",
            .dataCollection: "Collecte de Données",
            .dataCollectionMessage: "LiveLedger stocke toutes vos données localement sur votre appareil. Nous ne collectons, ne transmettons ni ne stockons vos données de ventes sur des serveurs externes.",
            .thirdPartyServices: "Services Tiers",
            .thirdPartyMessage: "Nous utilisons StoreKit d'Apple pour les achats intégrés. Aucune donnée personnelle n'est partagée avec des tiers.",
            .privacySummary: "Résumé de Confidentialité",
            .deleteAccountQuestion: "Supprimer le Compte?",
            .deleteAccountMessage: "Cela supprimera définitivement votre compte et toutes les données.",
            .cannotBeUndone: "Cela ne peut pas être annulé.",
            .welcomeMessage: "Votre compagnon complet de vente en direct! Suivez les commandes en temps réel, gérez plusieurs plateformes et développez votre entreprise avec des informations puissantes. Laissez-nous vous montrer comment cela fonctionne.",
            .step1: "Étape 1",
            .step2: "Étape 2",
            .step3: "Étape 3",
            .step4: "Étape 4",
            .step5: "Étape 5",
            .step6: "Étape 6",
            .addYourProducts: "Ajoutez Vos Produits",
            .recordSales: "Enregistrer les Ventes",
            .startLiveSession: "Démarrez Votre Session en Direct",
            .selectYourPlatform: "Sélectionnez Votre Plateforme",
            .manageYourOrders: "Gérez Vos Commandes",
            .exportYourData: "Exportez Vos Données",
            .navigation: "Utiliser la Navigation Inférieure",
            .customizeExperience: "Personnalisez Votre Expérience",
            .proTips: "Conseils Pro pour Réussir"
        ],
        .spanish: [
            .appName: "LiveLedger",
            .save: "Guardar",
            .cancel: "Cancelar",
            .delete: "Eliminar",
            .edit: "Editar",
            .add: "Añadir",
            .done: "Hecho",
            .close: "Cerrar",
            .settings: "Ajustes",
            .upgrade: "Mejorar",
            .free: "Gratis",
            .pro: "Pro",
            .totalSales: "Ventas Totales",
            .outstanding: "Pendiente",
            .itemsSold: "Artículos Vendidos",
            .orders: "Pedidos",
            .products: "Productos",
            .platform: "Plataforma",
            .clear: "Limpiar",
            .export: "Exportar",
            .print: "Imprimir",
            .autoSaving: "Guardado auto",
            .addPlatform: "Añadir Plataforma",
            .platformName: "Nombre de Plataforma",
            .all: "Todos",
            .topSeller: "Más Vendido",
            .stockLeft: "Stock Restante",
            .totalOrders: "Total Pedidos",
            .myProducts: "Mis Productos",
            .quickAdd: "Agregar Rápido",
            .tapToSell: "Toca para vender",
            .holdToEdit: "Mantén para editar",
            .tapSellHoldEdit: "Tap: Vender • Mantener: Editar",
            .holdToAddProduct: "Mantén para agregar",
            .stock: "Stock",
            .price: "Precio",
            .discount: "Descuento",
            .outOfStock: "Agotado",
            .addProduct: "Añadir Producto",
            .editProduct: "Editar Producto",
            .tiktok: "TikTok",
            .instagram: "Instagram",
            .facebook: "Facebook",
            .analytics: "Analíticas",
            .displaySettings: "Pantalla",
            .soundSettings: "Sonidos",
            .profileSettings: "Perfil",
            .myStore: "Mi Tienda",
            .showOverlay: "Mostrar Overlay",
            .hideOverlay: "Ocultar Overlay",
            .noOrders: "Sin pedidos",
            .customer: "Cliente",
            .quantity: "Cantidad",
            .total: "Total",
            .paid: "Pagado",
            .pending: "Pendiente",
            .unset: "Sin definir",
            .fulfilled: "Hecho",
            .printReceipt: "Imprimir Recibo",
            .unpaid: "Impago",
            .orderSource: "Origen del pedido",
            .orderSources: "Orígenes de pedidos",
            .unpaidOrders: "Pedidos impagos",
            .allSources: "Todos los orígenes",
            .customerName: "Nombre del cliente",
            .phoneOptional: "Teléfono (opcional)",
            .notesOptional: "Notas (opcional)",
            .markAsPaid: "Marcar como pagado",
            .markAsUnpaid: "Marcar como impago",
            .liveStream: "Transmisión en vivo",
            .instagramDM: "Instagram DM",
            .facebookDM: "Facebook DM",
            .tiktokDM: "TikTok DM",
            .whatsApp: "WhatsApp",
            .topSelling: "Más Vendidos",
            .currentMonth: "Este Mes",
            .previousMonth: "Mes Anterior",
            .salesAnalytics: "Análisis de Ventas",
            .today: "Hoy",
            .week: "Semana",
            .month: "Mes",
            .revenue: "Ingresos",
            .avgOrder: "Pedido Prom.",
            .salesTrend: "Tendencia de Ventas",
            .byPlatform: "Por Plataforma",
            .compare: "Comparar",
            .version: "Versión",
            .product: "Producto",
            .sold: "vendido(s)",
            .about: "Acerca de",
            .profile: "Perfil",
            .themes: "Temas",
            .language: "Idioma",
            .tutorial: "Tutorial",
            .sendFeedback: "Enviar Comentarios",
            .privacyPolicy: "Política de Privacidad",
            .termsOfService: "Términos de Servicio",
            .signOut: "Cerrar Sesión",
            .deleteAccount: "Eliminar Cuenta",
            .createAccount: "Crear Cuenta",
            .fullName: "Nombre Completo",
            .email: "Correo",
            .password: "Contraseña",
            .companyName: "Nombre de Empresa",
            .referralCode: "Código de Referido",
            .agreeTerms: "Acepto los términos",
            .getStarted: "Empezar",
            .welcomeTo: "Bienvenido a",
            .tutorialProducts: "Añade productos y toca para crear pedidos al instante",
            .tutorialOrders: "Rastrea todos los pedidos con detalles del comprador",
            .tutorialPlatforms: "Cambia entre TikTok, Instagram, Facebook o añade plataformas",
            .tutorialAnalytics: "Ve reportes de ventas y exporta datos",
            .tutorialExport: "Exporta pedidos a CSV e imprime recibos",
            .letsGo: "¡Vamos!",
            .next: "Siguiente",
            .skip: "Saltar",
            .support: "Soporte",
            .havingIssues: "¿Tienes Problemas?",
            .liveSupport: "Soporte en Vivo",
            .chatOnWhatsApp: "Chatea con nosotros en WhatsApp",
            .emailSupport: "Soporte por Email",
            .sendUsEmail: "Envíanos un email",
            .supportResponseTime: "Normalmente respondemos en 24 horas",
            .choosePlan: "Elige Tu Plan",
            .selectPlanDescription: "Selecciona cómo quieres usar LiveLedger",
            .basicPlan: "Básico",
            .proPlan: "Pro",
            .forever: "para siempre",
            .perMonth: "/mes",
            .greatForStarting: "Perfecto para empezar",
            .unlimited: "Todo ilimitado para vendedores serios",
            .firstOrdersFree: "Primeros 20 pedidos gratis",
            .basicInventory: "Gestión básica de inventario",
            .csvExports: "10 exportaciones CSV",
            .standardReports: "Informes estándar",
            .limitedOrders: "Pedidos limitados",
            .noAdvancedFilters: "Sin filtros avanzados",
            .noProductImages: "Sin imágenes de productos",
            .unlimitedOrders: "Pedidos ilimitados",
            .unlimitedExports: "Exportaciones ilimitadas",
            .productImages: "Imágenes de productos",
            .advancedAnalytics: "Análisis avanzado",
            .orderFilters: "Filtros de pedidos",
            .prioritySupport: "Soporte prioritario",
            .allFutureFeatures: "Todas las funciones futuras",
            .continueWithPro: "Continuar con Pro",
            .continueWithBasic: "Continuar con Básico",
            .cancelAnytime: "Cancela cuando quieras",
            .dayFreeTrial: "7 días de prueba gratis",
            .welcomeToPro: "¡Bienvenido a Pro! 🎉",
            .proSubscriptionActive: "¡Tu suscripción Pro está activa! Disfruta de pedidos ilimitados y todas las funciones premium.",
            .upgradeToPro: "Actualizar a Pro",
            .subscribeNow: "Suscríbete Ahora",
            .maybeLater: "Quizás Más Tarde",
            .benefits: "Beneficios",
            .welcomeToLiveLedger: "Bienvenido a LiveLedger",
            .selectLanguage: "Seleccionar Idioma",
            .selectYourLanguage: "Selecciona Tu Idioma",
            .continueText: "Continuar",
            .back: "Atrás",
            .getStartedText: "¡Empezar!",
            .description: "Descripción",
            .developer: "Desarrollador",
            .termsAndPrivacy: "Términos y Privacidad",
            .company: "Empresa",
            .yourName: "Tu Nombre",
            .personalInformation: "Información Personal",
            .security: "Seguridad",
            .changePassword: "Cambiar Contraseña",
            .currentPassword: "Contraseña Actual",
            .newPassword: "Nueva Contraseña",
            .confirmNewPassword: "Confirmar Nueva Contraseña",
            .passwordMustContain: "La contraseña debe contener:",
            .atLeastChars: "Al menos 6 caracteres",
            .atLeastOneLetter: "Al menos una letra",
            .atLeastOneSymbol: "Al menos un símbolo (!@#$%...)",
            .currentPasswordIncorrect: "La contraseña actual es incorrecta",
            .storeInformation: "Información de Tienda",
            .storeName: "Nombre de Tienda",
            .address: "Dirección",
            .businessPhone: "Teléfono de Negocio",
            .infoAppearsOnReceipts: "Esta información aparece en recibos e informes",
            .currency: "Moneda",
            .phoneNumber: "Número de Teléfono",
            .changePhoto: "Cambiar Foto",
            .sendFeedbackTitle: "Enviar Comentarios",
            .type: "Tipo",
            .feedbackType: "Tipo de Comentario",
            .message: "Mensaje",
            .suggestion: "Sugerencia",
            .bugReport: "Reporte de Error",
            .question: "Pregunta",
            .other: "Otro",
            .network: "Red",
            .connection: "Conexión",
            .connectionStatus: "Estado de Conexión",
            .connected: "Conectado",
            .wifi: "Wi-Fi",
            .speedTestResults: "Resultados de Prueba de Velocidad",
            .download: "Descarga",
            .upload: "Subida",
            .latency: "Latencia",
            .assessment: "Evaluación",
            .streamQuality: "Calidad de Transmisión",
            .notTested: "Sin Probar",
            .excellent: "Excelente",
            .good: "Bueno",
            .fair: "Regular",
            .poor: "Malo",
            .testNetwork: "Probar Ancho de Banda",
            .testingText: "Probando...",
            .forBestStreaming: "Para mejor transmisión: Descarga > 50 Mbps, Subida > 10 Mbps, Latencia < 50ms",
            .display: "Pantalla",
            .screenBrightness: "Brillo de Pantalla",
            .useControlCenter: "Usa el Centro de Control del iPhone para ajustar el brillo",
            .swipeDownFromTop: "Desliza desde arriba a la derecha para acceder al Centro de Control",
            .theme: "Tema",
            .chooseTheme: "Elige tu tema visual preferido",
            .reset: "Restablecer",
            .resetToDefaults: "Restablecer a Predeterminado",
            .subscriptionExpired: "Tu suscripción Pro ha expirado",
            .expiredOn: "Expiró el",
            .resubscribeMessage: "Vuelve a suscribirte para continuar usando pedidos ilimitados, exportaciones y todas las funciones Pro.",
            .resubscribeToPro: "Volver a Suscribir a Pro",
            .freePlan: "Plan Gratuito",
            .expired: "EXPIRADO",
            .dataCollection: "Recopilación de Datos",
            .dataCollectionMessage: "LiveLedger almacena todos tus datos localmente en tu dispositivo. No recopilamos, transmitimos ni almacenamos tus datos de ventas en servidores externos.",
            .thirdPartyServices: "Servicios de Terceros",
            .thirdPartyMessage: "Usamos StoreKit de Apple para compras dentro de la app. No se comparte información personal con terceros.",
            .privacySummary: "Resumen de Privacidad",
            .deleteAccountQuestion: "¿Eliminar Cuenta?",
            .deleteAccountMessage: "Esto eliminará permanentemente tu cuenta y todos los datos.",
            .cannotBeUndone: "Esto no se puede deshacer.",
            .welcomeMessage: "¡Tu compañero completo de ventas en vivo! Rastrea pedidos en tiempo real, gestiona múltiples plataformas y haz crecer tu negocio con información poderosa. Te mostramos cómo funciona.",
            .step1: "Paso 1",
            .step2: "Paso 2",
            .step3: "Paso 3",
            .step4: "Paso 4",
            .step5: "Paso 5",
            .step6: "Paso 6",
            .addYourProducts: "Añade Tus Productos",
            .recordSales: "Registra Ventas",
            .startLiveSession: "Inicia Tu Sesión en Vivo",
            .selectYourPlatform: "Selecciona Tu Plataforma",
            .manageYourOrders: "Gestiona Tus Pedidos",
            .exportYourData: "Exporta Tus Datos",
            .navigation: "Usar la Navegación Inferior",
            .customizeExperience: "Personaliza Tu Experiencia",
            .proTips: "Consejos Pro para el Éxito"
        ],
        .portuguese: [
            .appName: "LiveLedger",
            .save: "Salvar",
            .cancel: "Cancelar",
            .delete: "Excluir",
            .edit: "Editar",
            .add: "Adicionar",
            .done: "Concluído",
            .close: "Fechar",
            .settings: "Configurações",
            .upgrade: "Atualizar",
            .free: "Grátis",
            .pro: "Pro",
            .totalSales: "Vendas Totais",
            .outstanding: "Pendente",
            .itemsSold: "Itens Vendidos",
            .orders: "Pedidos",
            .products: "Produtos",
            .platform: "Plataforma",
            .clear: "Limpar",
            .export: "Exportar",
            .print: "Imprimir",
            .autoSaving: "Salvando auto",
            .addPlatform: "Adicionar Plataforma",
            .platformName: "Nome da Plataforma",
            .all: "Todos",
            .topSeller: "Mais Vendido",
            .stockLeft: "Estoque Restante",
            .totalOrders: "Total de Pedidos",
            .myProducts: "Meus Produtos",
            .quickAdd: "Adicionar Rápido",
            .tapToSell: "Toque para vender",
            .holdToEdit: "Segure para editar",
            .tapSellHoldEdit: "Toque: Vender • Segure: Editar",
            .holdToAddProduct: "Segure para adicionar",
            .stock: "Estoque",
            .price: "Preço",
            .discount: "Desconto",
            .outOfStock: "Esgotado",
            .addProduct: "Adicionar Produto",
            .editProduct: "Editar Produto",
            .tiktok: "TikTok",
            .instagram: "Instagram",
            .facebook: "Facebook",
            .analytics: "Análises",
            .displaySettings: "Exibição",
            .soundSettings: "Sons",
            .profileSettings: "Perfil",
            .myStore: "Minha Loja",
            .showOverlay: "Mostrar Overlay",
            .hideOverlay: "Ocultar Overlay",
            .noOrders: "Sem pedidos",
            .customer: "Cliente",
            .quantity: "Quantidade",
            .total: "Total",
            .paid: "Pago",
            .pending: "Pendente",
            .fulfilled: "Concluído",
            .topSelling: "Mais Vendidos",
            .currentMonth: "Este Mês",
            .previousMonth: "Mês Anterior",
            .salesAnalytics: "Análise de Vendas",
            .today: "Hoje",
            .week: "Semana",
            .month: "Mês",
            .revenue: "Receita",
            .profile: "Perfil",
            .themes: "Temas",
            .language: "Idioma",
            .tutorial: "Tutorial",
            .sendFeedback: "Enviar Feedback",
            .privacyPolicy: "Política de Privacidade",
            .termsOfService: "Termos de Serviço",
            .signOut: "Sair",
            .letsGo: "Vamos!",
            .next: "Próximo",
            .skip: "Pular"
        ],
        .german: [
            .appName: "LiveLedger",
            .save: "Speichern",
            .cancel: "Abbrechen",
            .delete: "Löschen",
            .edit: "Bearbeiten",
            .add: "Hinzufügen",
            .done: "Fertig",
            .close: "Schließen",
            .settings: "Einstellungen",
            .upgrade: "Upgrade",
            .free: "Kostenlos",
            .pro: "Pro",
            .totalSales: "Gesamtumsatz",
            .outstanding: "Ausstehend",
            .itemsSold: "Verkaufte Artikel",
            .orders: "Bestellungen",
            .products: "Produkte",
            .platform: "Plattform",
            .clear: "Löschen",
            .export: "Exportieren",
            .print: "Drucken",
            .autoSaving: "Auto-Speichern",
            .addPlatform: "Plattform hinzufügen",
            .platformName: "Plattformname",
            .all: "Alle",
            .topSeller: "Bestseller",
            .stockLeft: "Lagerbestand",
            .totalOrders: "Alle Bestellungen",
            .myProducts: "Meine Produkte",
            .quickAdd: "Schnell hinzufügen",
            .tapToSell: "Tippen zum Verkaufen",
            .holdToEdit: "Halten zum Bearbeiten",
            .tapSellHoldEdit: "Tippen: Verkaufen • Halten: Bearbeiten",
            .holdToAddProduct: "Halten zum Hinzufügen",
            .stock: "Lager",
            .price: "Preis",
            .discount: "Rabatt",
            .outOfStock: "Ausverkauft",
            .addProduct: "Produkt hinzufügen",
            .editProduct: "Produkt bearbeiten",
            .tiktok: "TikTok",
            .instagram: "Instagram",
            .facebook: "Facebook",
            .analytics: "Analysen",
            .displaySettings: "Anzeige",
            .soundSettings: "Töne",
            .profileSettings: "Profil",
            .myStore: "Mein Geschäft",
            .showOverlay: "Overlay anzeigen",
            .hideOverlay: "Overlay ausblenden",
            .noOrders: "Keine Bestellungen",
            .customer: "Kunde",
            .quantity: "Menge",
            .total: "Gesamt",
            .paid: "Bezahlt",
            .pending: "Ausstehend",
            .fulfilled: "Erledigt",
            .topSelling: "Bestseller",
            .currentMonth: "Dieser Monat",
            .previousMonth: "Letzter Monat",
            .salesAnalytics: "Verkaufsanalyse",
            .today: "Heute",
            .week: "Woche",
            .month: "Monat",
            .revenue: "Umsatz",
            .profile: "Profil",
            .themes: "Themen",
            .language: "Sprache",
            .tutorial: "Tutorial",
            .sendFeedback: "Feedback senden",
            .privacyPolicy: "Datenschutz",
            .termsOfService: "Nutzungsbedingungen",
            .signOut: "Abmelden",
            .letsGo: "Los geht's!",
            .next: "Weiter",
            .skip: "Überspringen"
        ],
        .italian: [
            .appName: "LiveLedger",
            .save: "Salva",
            .cancel: "Annulla",
            .delete: "Elimina",
            .edit: "Modifica",
            .add: "Aggiungi",
            .done: "Fatto",
            .close: "Chiudi",
            .settings: "Impostazioni",
            .upgrade: "Aggiorna",
            .free: "Gratis",
            .pro: "Pro",
            .totalSales: "Vendite Totali",
            .outstanding: "In sospeso",
            .itemsSold: "Articoli Venduti",
            .orders: "Ordini",
            .products: "Prodotti",
            .platform: "Piattaforma",
            .clear: "Cancella",
            .export: "Esporta",
            .print: "Stampa",
            .autoSaving: "Salvataggio auto",
            .addPlatform: "Aggiungi Piattaforma",
            .platformName: "Nome Piattaforma",
            .all: "Tutti",
            .topSeller: "Più Venduto",
            .stockLeft: "Scorte Rimanenti",
            .totalOrders: "Ordini Totali",
            .myProducts: "I Miei Prodotti",
            .quickAdd: "Aggiungi Rapido",
            .tapToSell: "Tocca per vendere",
            .holdToEdit: "Tieni per modificare",
            .tapSellHoldEdit: "Tocca: Vendi • Tieni: Modifica",
            .holdToAddProduct: "Tieni per aggiungere",
            .stock: "Scorte",
            .price: "Prezzo",
            .discount: "Sconto",
            .outOfStock: "Esaurito",
            .addProduct: "Aggiungi Prodotto",
            .editProduct: "Modifica Prodotto",
            .tiktok: "TikTok",
            .instagram: "Instagram",
            .facebook: "Facebook",
            .analytics: "Analisi",
            .displaySettings: "Display",
            .soundSettings: "Suoni",
            .profileSettings: "Profilo",
            .myStore: "Il Mio Negozio",
            .showOverlay: "Mostra Overlay",
            .hideOverlay: "Nascondi Overlay",
            .noOrders: "Nessun ordine",
            .customer: "Cliente",
            .quantity: "Quantità",
            .total: "Totale",
            .paid: "Pagato",
            .pending: "In attesa",
            .fulfilled: "Completato",
            .topSelling: "Più Venduti",
            .currentMonth: "Questo Mese",
            .previousMonth: "Mese Scorso",
            .salesAnalytics: "Analisi Vendite",
            .today: "Oggi",
            .week: "Settimana",
            .month: "Mese",
            .revenue: "Entrate",
            .profile: "Profilo",
            .themes: "Temi",
            .language: "Lingua",
            .tutorial: "Tutorial",
            .sendFeedback: "Invia Feedback",
            .privacyPolicy: "Privacy",
            .termsOfService: "Termini di Servizio",
            .signOut: "Esci",
            .letsGo: "Andiamo!",
            .next: "Avanti",
            .skip: "Salta"
        ],
        .chinese: [
            .appName: "LiveLedger",
            .save: "保存",
            .cancel: "取消",
            .delete: "删除",
            .edit: "编辑",
            .add: "添加",
            .done: "完成",
            .close: "关闭",
            .settings: "设置",
            .upgrade: "升级",
            .free: "免费",
            .pro: "专业版",
            .totalSales: "总销售额",
            .outstanding: "待处理",
            .itemsSold: "已售商品",
            .orders: "订单",
            .products: "产品",
            .platform: "平台",
            .clear: "清除",
            .export: "导出",
            .print: "打印",
            .autoSaving: "自动保存",
            .addPlatform: "添加平台",
            .platformName: "平台名称",
            .all: "全部",
            .topSeller: "畅销品",
            .stockLeft: "剩余库存",
            .totalOrders: "订单总数",
            .myProducts: "我的产品",
            .quickAdd: "快速添加",
            .tapToSell: "点击销售",
            .holdToEdit: "长按编辑",
            .tapSellHoldEdit: "点击：销售 • 长按：编辑",
            .holdToAddProduct: "长按添加产品",
            .stock: "库存",
            .price: "价格",
            .discount: "折扣",
            .outOfStock: "缺货",
            .addProduct: "添加产品",
            .editProduct: "编辑产品",
            .tiktok: "抖音",
            .instagram: "Instagram",
            .facebook: "Facebook",
            .analytics: "分析",
            .displaySettings: "显示",
            .soundSettings: "声音",
            .profileSettings: "个人资料",
            .myStore: "我的店铺",
            .showOverlay: "显示浮窗",
            .hideOverlay: "隐藏浮窗",
            .noOrders: "暂无订单",
            .customer: "客户",
            .quantity: "数量",
            .total: "合计",
            .paid: "已付款",
            .pending: "待处理",
            .fulfilled: "已完成",
            .topSelling: "畅销商品",
            .currentMonth: "本月",
            .previousMonth: "上月",
            .salesAnalytics: "销售分析",
            .today: "今天",
            .week: "本周",
            .month: "本月",
            .revenue: "收入",
            .profile: "个人资料",
            .themes: "主题",
            .language: "语言",
            .tutorial: "教程",
            .sendFeedback: "发送反馈",
            .privacyPolicy: "隐私政策",
            .termsOfService: "服务条款",
            .signOut: "退出登录",
            .letsGo: "开始吧！",
            .next: "下一步",
            .skip: "跳过"
        ],
        .japanese: [
            .appName: "LiveLedger",
            .save: "保存",
            .cancel: "キャンセル",
            .delete: "削除",
            .edit: "編集",
            .add: "追加",
            .done: "完了",
            .close: "閉じる",
            .settings: "設定",
            .upgrade: "アップグレード",
            .free: "無料",
            .pro: "プロ",
            .totalSales: "総売上",
            .outstanding: "未処理",
            .itemsSold: "販売数",
            .orders: "注文",
            .products: "商品",
            .platform: "プラットフォーム",
            .clear: "クリア",
            .export: "エクスポート",
            .print: "印刷",
            .autoSaving: "自動保存",
            .addPlatform: "プラットフォーム追加",
            .platformName: "プラットフォーム名",
            .all: "すべて",
            .topSeller: "ベストセラー",
            .stockLeft: "在庫残",
            .totalOrders: "注文合計",
            .myProducts: "マイ商品",
            .quickAdd: "クイック追加",
            .tapToSell: "タップで販売",
            .holdToEdit: "長押しで編集",
            .tapSellHoldEdit: "タップ：販売 • 長押し：編集",
            .holdToAddProduct: "長押しで追加",
            .stock: "在庫",
            .price: "価格",
            .discount: "割引",
            .outOfStock: "在庫切れ",
            .addProduct: "商品追加",
            .editProduct: "商品編集",
            .tiktok: "TikTok",
            .instagram: "Instagram",
            .facebook: "Facebook",
            .analytics: "分析",
            .displaySettings: "表示",
            .soundSettings: "サウンド",
            .profileSettings: "プロフィール",
            .myStore: "マイストア",
            .showOverlay: "オーバーレイ表示",
            .hideOverlay: "オーバーレイ非表示",
            .noOrders: "注文なし",
            .customer: "顧客",
            .quantity: "数量",
            .total: "合計",
            .paid: "支払済",
            .pending: "保留中",
            .fulfilled: "完了",
            .topSelling: "売れ筋",
            .currentMonth: "今月",
            .previousMonth: "先月",
            .salesAnalytics: "売上分析",
            .today: "今日",
            .week: "週",
            .month: "月",
            .revenue: "収益",
            .profile: "プロフィール",
            .themes: "テーマ",
            .language: "言語",
            .tutorial: "チュートリアル",
            .sendFeedback: "フィードバック",
            .privacyPolicy: "プライバシー",
            .termsOfService: "利用規約",
            .signOut: "ログアウト",
            .letsGo: "始めよう！",
            .next: "次へ",
            .skip: "スキップ"
        ],
        .korean: [
            .appName: "LiveLedger",
            .save: "저장",
            .cancel: "취소",
            .delete: "삭제",
            .edit: "편집",
            .add: "추가",
            .done: "완료",
            .close: "닫기",
            .settings: "설정",
            .upgrade: "업그레이드",
            .free: "무료",
            .pro: "프로",
            .totalSales: "총 매출",
            .outstanding: "미결제",
            .itemsSold: "판매량",
            .orders: "주문",
            .products: "상품",
            .platform: "플랫폼",
            .clear: "지우기",
            .export: "내보내기",
            .print: "인쇄",
            .autoSaving: "자동 저장",
            .addPlatform: "플랫폼 추가",
            .platformName: "플랫폼 이름",
            .all: "전체",
            .topSeller: "베스트셀러",
            .stockLeft: "재고 현황",
            .totalOrders: "총 주문",
            .myProducts: "내 상품",
            .quickAdd: "빠른 추가",
            .tapToSell: "탭하여 판매",
            .holdToEdit: "길게 눌러 편집",
            .tapSellHoldEdit: "탭: 판매 • 길게: 편집",
            .holdToAddProduct: "길게 눌러 추가",
            .stock: "재고",
            .price: "가격",
            .discount: "할인",
            .outOfStock: "품절",
            .addProduct: "상품 추가",
            .editProduct: "상품 편집",
            .tiktok: "틱톡",
            .instagram: "인스타그램",
            .facebook: "페이스북",
            .analytics: "분석",
            .displaySettings: "디스플레이",
            .soundSettings: "소리",
            .profileSettings: "프로필",
            .myStore: "내 스토어",
            .showOverlay: "오버레이 표시",
            .hideOverlay: "오버레이 숨기기",
            .noOrders: "주문 없음",
            .customer: "고객",
            .quantity: "수량",
            .total: "합계",
            .paid: "결제 완료",
            .pending: "대기 중",
            .fulfilled: "완료",
            .topSelling: "베스트셀러",
            .currentMonth: "이번 달",
            .previousMonth: "지난 달",
            .salesAnalytics: "매출 분석",
            .today: "오늘",
            .week: "주",
            .month: "월",
            .revenue: "수익",
            .profile: "프로필",
            .themes: "테마",
            .language: "언어",
            .tutorial: "튜토리얼",
            .sendFeedback: "피드백 보내기",
            .privacyPolicy: "개인정보 보호",
            .termsOfService: "서비스 약관",
            .signOut: "로그아웃",
            .letsGo: "시작하기!",
            .next: "다음",
            .skip: "건너뛰기"
        ],
        .arabic: [
            .appName: "LiveLedger",
            .save: "حفظ",
            .cancel: "إلغاء",
            .delete: "حذف",
            .edit: "تعديل",
            .add: "إضافة",
            .done: "تم",
            .close: "إغلاق",
            .settings: "الإعدادات",
            .upgrade: "ترقية",
            .free: "مجاني",
            .pro: "احترافي",
            .totalSales: "إجمالي المبيعات",
            .outstanding: "معلق",
            .itemsSold: "المباعات",
            .orders: "الطلبات",
            .products: "المنتجات",
            .platform: "المنصة",
            .clear: "مسح",
            .export: "تصدير",
            .print: "طباعة",
            .autoSaving: "حفظ تلقائي",
            .addPlatform: "إضافة منصة",
            .platformName: "اسم المنصة",
            .all: "الكل",
            .topSeller: "الأكثر مبيعاً",
            .stockLeft: "المخزون المتبقي",
            .totalOrders: "إجمالي الطلبات",
            .myProducts: "منتجاتي",
            .quickAdd: "إضافة سريعة",
            .tapToSell: "انقر للبيع",
            .holdToEdit: "اضغط للتعديل",
            .tapSellHoldEdit: "انقر: بيع • اضغط: تعديل",
            .holdToAddProduct: "اضغط للإضافة",
            .stock: "المخزون",
            .price: "السعر",
            .discount: "خصم",
            .outOfStock: "نفذ المخزون",
            .addProduct: "إضافة منتج",
            .editProduct: "تعديل منتج",
            .tiktok: "تيك توك",
            .instagram: "انستغرام",
            .facebook: "فيسبوك",
            .analytics: "التحليلات",
            .displaySettings: "العرض",
            .soundSettings: "الأصوات",
            .profileSettings: "الملف الشخصي",
            .myStore: "متجري",
            .showOverlay: "إظهار النافذة",
            .hideOverlay: "إخفاء النافذة",
            .noOrders: "لا توجد طلبات",
            .customer: "العميل",
            .quantity: "الكمية",
            .total: "المجموع",
            .paid: "مدفوع",
            .pending: "معلق",
            .fulfilled: "مكتمل",
            .topSelling: "الأكثر مبيعاً",
            .currentMonth: "هذا الشهر",
            .previousMonth: "الشهر الماضي",
            .salesAnalytics: "تحليل المبيعات",
            .today: "اليوم",
            .week: "الأسبوع",
            .month: "الشهر",
            .revenue: "الإيرادات",
            .profile: "الملف الشخصي",
            .themes: "السمات",
            .language: "اللغة",
            .tutorial: "الدليل",
            .sendFeedback: "إرسال ملاحظات",
            .privacyPolicy: "سياسة الخصوصية",
            .termsOfService: "شروط الخدمة",
            .signOut: "تسجيل الخروج",
            .letsGo: "!هيا بنا",
            .next: "التالي",
            .skip: "تخطي"
        ],
        .hindi: [
            .appName: "LiveLedger",
            .save: "सहेजें",
            .cancel: "रद्द करें",
            .delete: "हटाएं",
            .edit: "संपादित करें",
            .add: "जोड़ें",
            .done: "हो गया",
            .close: "बंद करें",
            .settings: "सेटिंग्स",
            .upgrade: "अपग्रेड",
            .free: "मुफ्त",
            .pro: "प्रो",
            .totalSales: "कुल बिक्री",
            .outstanding: "बकाया",
            .itemsSold: "बेचे गए आइटम",
            .orders: "ऑर्डर",
            .products: "उत्पाद",
            .platform: "प्लेटफॉर्म",
            .clear: "साफ करें",
            .export: "निर्यात",
            .print: "प्रिंट",
            .autoSaving: "ऑटो सेव",
            .addPlatform: "प्लेटफॉर्म जोड़ें",
            .platformName: "प्लेटफॉर्म का नाम",
            .all: "सभी",
            .topSeller: "टॉप सेलर",
            .stockLeft: "बचा हुआ स्टॉक",
            .totalOrders: "कुल ऑर्डर",
            .myProducts: "मेरे उत्पाद",
            .quickAdd: "त्वरित जोड़ें",
            .tapToSell: "बेचने के लिए टैप करें",
            .holdToEdit: "संपादित करने के लिए दबाएं",
            .tapSellHoldEdit: "टैप: बेचें • दबाएं: संपादित करें",
            .holdToAddProduct: "जोड़ने के लिए दबाएं",
            .stock: "स्टॉक",
            .price: "कीमत",
            .discount: "छूट",
            .outOfStock: "स्टॉक में नहीं",
            .addProduct: "उत्पाद जोड़ें",
            .editProduct: "उत्पाद संपादित करें",
            .tiktok: "टिकटॉक",
            .instagram: "इंस्टाग्राम",
            .facebook: "फेसबुक",
            .analytics: "एनालिटिक्स",
            .displaySettings: "डिस्प्ले",
            .soundSettings: "ध्वनि",
            .profileSettings: "प्रोफाइल",
            .myStore: "मेरा स्टोर",
            .showOverlay: "ओवरले दिखाएं",
            .hideOverlay: "ओवरले छिपाएं",
            .noOrders: "कोई ऑर्डर नहीं",
            .customer: "ग्राहक",
            .quantity: "मात्रा",
            .total: "कुल",
            .paid: "भुगतान किया",
            .pending: "लंबित",
            .fulfilled: "पूर्ण",
            .topSelling: "सबसे ज़्यादा बिकने वाले",
            .currentMonth: "इस महीने",
            .previousMonth: "पिछले महीने",
            .salesAnalytics: "बिक्री विश्लेषण",
            .today: "आज",
            .week: "सप्ताह",
            .month: "महीना",
            .revenue: "राजस्व",
            .profile: "प्रोफाइल",
            .themes: "थीम",
            .language: "भाषा",
            .tutorial: "ट्यूटोरियल",
            .sendFeedback: "प्रतिक्रिया भेजें",
            .privacyPolicy: "गोपनीयता नीति",
            .termsOfService: "सेवा की शर्तें",
            .signOut: "साइन आउट",
            .letsGo: "चलो शुरू करें!",
            .next: "अगला",
            .skip: "छोड़ें"
        ],
        .russian: [
            .appName: "LiveLedger",
            .save: "Сохранить",
            .cancel: "Отмена",
            .delete: "Удалить",
            .edit: "Редактировать",
            .add: "Добавить",
            .done: "Готово",
            .close: "Закрыть",
            .settings: "Настройки",
            .upgrade: "Улучшить",
            .free: "Бесплатно",
            .pro: "Про",
            .totalSales: "Общие продажи",
            .outstanding: "Ожидается",
            .itemsSold: "Продано",
            .orders: "Заказы",
            .products: "Товары",
            .platform: "Платформа",
            .clear: "Очистить",
            .export: "Экспорт",
            .print: "Печать",
            .autoSaving: "Автосохранение",
            .addPlatform: "Добавить платформу",
            .platformName: "Название платформы",
            .all: "Все",
            .topSeller: "Бестселлер",
            .stockLeft: "Остаток",
            .totalOrders: "Всего заказов",
            .myProducts: "Мои товары",
            .quickAdd: "Быстро добавить",
            .tapToSell: "Нажмите для продажи",
            .holdToEdit: "Удерживайте для редактирования",
            .tapSellHoldEdit: "Нажать: Продать • Удержать: Редактировать",
            .holdToAddProduct: "Удерживайте для добавления",
            .stock: "Склад",
            .price: "Цена",
            .discount: "Скидка",
            .outOfStock: "Нет в наличии",
            .addProduct: "Добавить товар",
            .editProduct: "Редактировать товар",
            .tiktok: "ТикТок",
            .instagram: "Инстаграм",
            .facebook: "Фейсбук",
            .analytics: "Аналитика",
            .displaySettings: "Дисплей",
            .soundSettings: "Звуки",
            .profileSettings: "Профиль",
            .myStore: "Мой магазин",
            .showOverlay: "Показать оверлей",
            .hideOverlay: "Скрыть оверлей",
            .noOrders: "Нет заказов",
            .customer: "Клиент",
            .quantity: "Количество",
            .total: "Итого",
            .paid: "Оплачено",
            .pending: "Ожидает",
            .fulfilled: "Выполнено",
            .topSelling: "Лидеры продаж",
            .currentMonth: "Этот месяц",
            .previousMonth: "Прошлый месяц",
            .salesAnalytics: "Аналитика продаж",
            .today: "Сегодня",
            .week: "Неделя",
            .month: "Месяц",
            .revenue: "Доход",
            .profile: "Профиль",
            .themes: "Темы",
            .language: "Язык",
            .tutorial: "Обучение",
            .sendFeedback: "Отправить отзыв",
            .privacyPolicy: "Политика конфиденциальности",
            .termsOfService: "Условия использования",
            .signOut: "Выйти",
            .letsGo: "Поехали!",
            .next: "Далее",
            .skip: "Пропустить"
        ],
        .dutch: [
            .appName: "LiveLedger",
            .save: "Opslaan",
            .cancel: "Annuleren",
            .delete: "Verwijderen",
            .edit: "Bewerken",
            .add: "Toevoegen",
            .done: "Klaar",
            .close: "Sluiten",
            .settings: "Instellingen",
            .upgrade: "Upgraden",
            .free: "Gratis",
            .pro: "Pro",
            .totalSales: "Totale Verkoop",
            .outstanding: "Openstaand",
            .itemsSold: "Verkochte Items",
            .orders: "Bestellingen",
            .products: "Producten",
            .platform: "Platform",
            .clear: "Wissen",
            .export: "Exporteren",
            .print: "Afdrukken",
            .autoSaving: "Auto opslaan",
            .addPlatform: "Platform Toevoegen",
            .platformName: "Platformnaam",
            .all: "Alle",
            .topSeller: "Bestseller",
            .stockLeft: "Voorraad Over",
            .totalOrders: "Totaal Bestellingen",
            .myProducts: "Mijn Producten",
            .quickAdd: "Snel Toevoegen",
            .tapToSell: "Tik om te verkopen",
            .holdToEdit: "Vasthouden om te bewerken",
            .tapSellHoldEdit: "Tik: Verkopen • Vasthouden: Bewerken",
            .holdToAddProduct: "Vasthouden om toe te voegen",
            .stock: "Voorraad",
            .price: "Prijs",
            .discount: "Korting",
            .outOfStock: "Uitverkocht",
            .addProduct: "Product Toevoegen",
            .editProduct: "Product Bewerken",
            .tiktok: "TikTok",
            .instagram: "Instagram",
            .facebook: "Facebook",
            .analytics: "Analyses",
            .displaySettings: "Weergave",
            .soundSettings: "Geluiden",
            .profileSettings: "Profiel",
            .myStore: "Mijn Winkel",
            .showOverlay: "Overlay Tonen",
            .hideOverlay: "Overlay Verbergen",
            .noOrders: "Geen bestellingen",
            .customer: "Klant",
            .quantity: "Aantal",
            .total: "Totaal",
            .paid: "Betaald",
            .pending: "In afwachting",
            .fulfilled: "Voltooid",
            .topSelling: "Bestverkocht",
            .currentMonth: "Deze Maand",
            .previousMonth: "Vorige Maand",
            .salesAnalytics: "Verkoopanalyse",
            .today: "Vandaag",
            .week: "Week",
            .month: "Maand",
            .revenue: "Omzet",
            .profile: "Profiel",
            .themes: "Thema's",
            .language: "Taal",
            .tutorial: "Tutorial",
            .sendFeedback: "Feedback Versturen",
            .privacyPolicy: "Privacybeleid",
            .termsOfService: "Servicevoorwaarden",
            .signOut: "Uitloggen",
            .letsGo: "Laten we gaan!",
            .next: "Volgende",
            .skip: "Overslaan"
        ]
    ]
}

// Helper extension for easy localization
extension String {
    func localized(_ manager: LocalizationManager) -> String {
        return self
    }
}

