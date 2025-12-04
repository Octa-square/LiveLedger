//
//  LocalizationManager.swift
//  LiveLedger
//
//  LiveLedger - Multi-language Support
//

import SwiftUI
import Combine

// MARK: - Supported Languages (20+)
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
    case polish = "pl"
    case turkish = "tr"
    case vietnamese = "vi"
    case thai = "th"
    case indonesian = "id"
    case malay = "ms"
    case swedish = "sv"
    case danish = "da"
    case greek = "el"
    case hebrew = "he"
    case czech = "cs"
    
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
        case .polish: return "Polski"
        case .turkish: return "Türkçe"
        case .vietnamese: return "Tiếng Việt"
        case .thai: return "ภาษาไทย"
        case .indonesian: return "Bahasa Indonesia"
        case .malay: return "Bahasa Melayu"
        case .swedish: return "Svenska"
        case .danish: return "Dansk"
        case .greek: return "Ελληνικά"
        case .hebrew: return "עברית"
        case .czech: return "Čeština"
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
        case .polish: return "🇵🇱"
        case .turkish: return "🇹🇷"
        case .vietnamese: return "🇻🇳"
        case .thai: return "🇹🇭"
        case .indonesian: return "🇮🇩"
        case .malay: return "🇲🇾"
        case .swedish: return "🇸🇪"
        case .danish: return "🇩🇰"
        case .greek: return "🇬🇷"
        case .hebrew: return "🇮🇱"
        case .czech: return "🇨🇿"
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
    
    // Products
    case tapToSell = "tap_to_sell"
    case holdToEdit = "hold_to_edit"
    case stock = "stock"
    case price = "price"
    case discount = "discount"
    case outOfStock = "out_of_stock"
    
    // Orders
    case noOrders = "no_orders"
    case customer = "customer"
    case quantity = "quantity"
    case total = "total"
    case paid = "paid"
    case pending = "pending"
    case unset = "unset"
    case fulfilled = "fulfilled"
    case printReceipt = "print_receipt"
    
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
    
    // Additional UI strings
    case account = "account"
    case myProducts = "my_products"
    case totalOrders = "total_orders"
    case topSeller = "top_seller"
    case stockLeft = "stock_left"
    case analytics = "analytics"
    case menu = "menu"
    case buyerName = "buyer_name"
    case selectPlatform = "select_platform"
    case allPlatforms = "all_platforms"
    case filterByPlatform = "filter_by_platform"
    case timePeriod = "time_period"
    case custom = "custom"
    case grandTotal = "grand_total"
    case receipt = "receipt"
    case thankYou = "thank_you"
    case phone = "phone"
    case address = "address"
    case status = "status"
    case items = "items"
    case salesReport = "sales_report"
    case individualReceipts = "individual_receipts"
    case allOrders = "all_orders"
    case printType = "print_type"
    case exportOrders = "export_orders"
    case clearData = "clear_data"
    case selectToClear = "select_to_clear"
    case clearSelected = "clear_selected"
    case customPlatforms = "custom_platforms"
    case manageSubscription = "manage_subscription"
    case cancelSubscription = "cancel_subscription"
    case confirmPassword = "confirm_password"
    case phoneNumber = "phone_number"
    case holdToAdd = "hold_to_add"
    case namePriceStock = "name_price_stock"
    case tapSell = "tap_sell"
    case holdEdit = "hold_edit"
    case noData = "no_data"
    case change = "change"
    case periodComparison = "period_comparison"
    case period1 = "period_1"
    case period2 = "period_2"
    case avgOrderValue = "avg_order_value"
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
        return translations[currentLanguage]?[key] ?? translations[.english]?[key] ?? key.rawValue
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
            .tapToSell: "Tap to sell",
            .holdToEdit: "Hold to edit",
            .stock: "Stock",
            .price: "Price",
            .discount: "Discount",
            .outOfStock: "Out of stock",
            .noOrders: "No orders yet",
            .customer: "Customer",
            .quantity: "Quantity",
            .total: "Total",
            .paid: "Paid",
            .pending: "Pending",
            .unset: "Unset",
            .fulfilled: "Done",
            .printReceipt: "Print Receipt",
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
            .tutorialOrders: "Track orders with session timer, total sales, top seller, stock levels & order count",
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
            .account: "Account",
            .myProducts: "My Products",
            .totalOrders: "Total Orders",
            .topSeller: "Top Seller",
            .stockLeft: "Stock Left",
            .analytics: "Analytics",
            .menu: "Menu",
            .buyerName: "Buyer Name",
            .selectPlatform: "Select Platform",
            .allPlatforms: "All Platforms",
            .filterByPlatform: "Filter by Platform",
            .timePeriod: "Time Period",
            .custom: "Custom",
            .grandTotal: "Grand Total",
            .receipt: "Receipt",
            .thankYou: "Thank you for your purchase!",
            .phone: "Phone",
            .address: "Address",
            .status: "Status",
            .items: "Items",
            .salesReport: "Sales Report",
            .individualReceipts: "Individual Receipts",
            .allOrders: "All Orders",
            .printType: "Print Type",
            .exportOrders: "Export Orders",
            .clearData: "Clear Data",
            .selectToClear: "Select what to clear",
            .clearSelected: "Clear Selected",
            .customPlatforms: "Custom Platforms",
            .manageSubscription: "Manage Subscription",
            .cancelSubscription: "Cancel Subscription",
            .confirmPassword: "Confirm Password",
            .phoneNumber: "Phone Number",
            .holdToAdd: "Hold to add",
            .namePriceStock: "name, price & stock",
            .tapSell: "Tap sell",
            .holdEdit: "Hold edit",
            .noData: "No data",
            .change: "Change",
            .periodComparison: "Period Comparison",
            .period1: "Period 1",
            .period2: "Period 2",
            .avgOrderValue: "Avg Order"
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
            .tapToSell: "Appuyez pour vendre",
            .holdToEdit: "Maintenez pour modifier",
            .stock: "Stock",
            .price: "Prix",
            .discount: "Réduction",
            .outOfStock: "Rupture de stock",
            .noOrders: "Aucune commande",
            .customer: "Client",
            .quantity: "Quantité",
            .total: "Total",
            .paid: "Payé",
            .pending: "En attente",
            .unset: "Non défini",
            .fulfilled: "Terminé",
            .printReceipt: "Imprimer Reçu",
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
            .account: "Compte",
            .myProducts: "Mes Produits",
            .totalOrders: "Total Commandes",
            .topSeller: "Meilleure Vente",
            .stockLeft: "Stock Restant",
            .analytics: "Analytique",
            .menu: "Menu",
            .buyerName: "Nom de l'Acheteur",
            .selectPlatform: "Sélectionner Plateforme",
            .allPlatforms: "Toutes les Plateformes",
            .filterByPlatform: "Filtrer par Plateforme",
            .timePeriod: "Période",
            .custom: "Personnalisé",
            .grandTotal: "Total Général",
            .receipt: "Reçu",
            .thankYou: "Merci pour votre achat!",
            .phone: "Téléphone",
            .address: "Adresse",
            .status: "Statut",
            .items: "Articles",
            .salesReport: "Rapport de Ventes",
            .individualReceipts: "Reçus Individuels",
            .allOrders: "Toutes les Commandes",
            .printType: "Type d'Impression",
            .exportOrders: "Exporter Commandes",
            .clearData: "Effacer Données",
            .selectToClear: "Sélectionnez quoi effacer",
            .clearSelected: "Effacer Sélection",
            .customPlatforms: "Plateformes Personnalisées",
            .manageSubscription: "Gérer l'Abonnement",
            .cancelSubscription: "Annuler l'Abonnement",
            .confirmPassword: "Confirmer Mot de Passe",
            .phoneNumber: "Numéro de Téléphone",
            .holdToAdd: "Maintenir pour ajouter",
            .namePriceStock: "nom, prix et stock",
            .tapSell: "Appuyer vendre",
            .holdEdit: "Maintenir éditer",
            .noData: "Aucune donnée",
            .change: "Changement",
            .periodComparison: "Comparaison de Périodes",
            .period1: "Période 1",
            .period2: "Période 2",
            .avgOrderValue: "Commande Moy."
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
            .tapToSell: "Toca para vender",
            .holdToEdit: "Mantén para editar",
            .stock: "Stock",
            .price: "Precio",
            .discount: "Descuento",
            .outOfStock: "Agotado",
            .noOrders: "Sin pedidos",
            .customer: "Cliente",
            .quantity: "Cantidad",
            .total: "Total",
            .paid: "Pagado",
            .pending: "Pendiente",
            .unset: "Sin definir",
            .fulfilled: "Hecho",
            .printReceipt: "Imprimir Recibo",
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
            .supportResponseTime: "Normalmente respondemos en 24 horas"
        ],
        .portuguese: [
            .appName: "LiveLedger",
            .totalSales: "Vendas Totais",
            .orders: "Pedidos",
            .products: "Produtos",
            .settings: "Configurações",
            .topSelling: "Mais Vendidos",
            .currentMonth: "Este Mês",
            .previousMonth: "Mês Anterior",
            .tutorial: "Tutorial",
            .letsGo: "Vamos!",
            .next: "Próximo",
            .skip: "Pular"
        ],
        .german: [
            .appName: "LiveLedger",
            .totalSales: "Gesamtumsatz",
            .orders: "Bestellungen",
            .products: "Produkte",
            .settings: "Einstellungen",
            .topSelling: "Bestseller",
            .currentMonth: "Dieser Monat",
            .previousMonth: "Letzter Monat",
            .tutorial: "Tutorial",
            .letsGo: "Los geht's!",
            .next: "Weiter",
            .skip: "Überspringen"
        ],
        .italian: [
            .appName: "LiveLedger",
            .totalSales: "Vendite Totali",
            .orders: "Ordini",
            .products: "Prodotti",
            .settings: "Impostazioni",
            .topSelling: "Più Venduti",
            .currentMonth: "Questo Mese",
            .previousMonth: "Mese Scorso",
            .tutorial: "Tutorial",
            .letsGo: "Andiamo!",
            .next: "Avanti",
            .skip: "Salta"
        ],
        .chinese: [
            .appName: "LiveLedger",
            .totalSales: "总销售额",
            .orders: "订单",
            .products: "产品",
            .settings: "设置",
            .topSelling: "畅销商品",
            .currentMonth: "本月",
            .previousMonth: "上月",
            .tutorial: "教程",
            .letsGo: "开始吧！",
            .next: "下一步",
            .skip: "跳过"
        ],
        .japanese: [
            .appName: "LiveLedger",
            .totalSales: "総売上",
            .orders: "注文",
            .products: "商品",
            .settings: "設定",
            .topSelling: "売れ筋",
            .currentMonth: "今月",
            .previousMonth: "先月",
            .tutorial: "チュートリアル",
            .letsGo: "始めよう！",
            .next: "次へ",
            .skip: "スキップ"
        ],
        .korean: [
            .appName: "LiveLedger",
            .totalSales: "총 매출",
            .orders: "주문",
            .products: "상품",
            .settings: "설정",
            .topSelling: "베스트셀러",
            .currentMonth: "이번 달",
            .previousMonth: "지난 달",
            .tutorial: "튜토리얼",
            .letsGo: "시작하기!",
            .next: "다음",
            .skip: "건너뛰기"
        ],
        .arabic: [
            .appName: "LiveLedger",
            .totalSales: "إجمالي المبيعات",
            .orders: "الطلبات",
            .products: "المنتجات",
            .settings: "الإعدادات",
            .topSelling: "الأكثر مبيعاً",
            .currentMonth: "هذا الشهر",
            .previousMonth: "الشهر الماضي",
            .tutorial: "الدليل",
            .letsGo: "!هيا بنا",
            .next: "التالي",
            .skip: "تخطي"
        ],
        .hindi: [
            .appName: "LiveLedger",
            .totalSales: "कुल बिक्री",
            .orders: "ऑर्डर",
            .products: "उत्पाद",
            .settings: "सेटिंग्स",
            .topSelling: "सबसे ज़्यादा बिकने वाले",
            .currentMonth: "इस महीने",
            .previousMonth: "पिछले महीने",
            .tutorial: "ट्यूटोरियल",
            .letsGo: "चलो शुरू करें!",
            .next: "अगला",
            .skip: "छोड़ें"
        ],
        .russian: [
            .appName: "LiveLedger",
            .totalSales: "Общие продажи",
            .orders: "Заказы",
            .products: "Товары",
            .settings: "Настройки",
            .topSelling: "Лидеры продаж",
            .currentMonth: "Этот месяц",
            .previousMonth: "Прошлый месяц",
            .tutorial: "Обучение",
            .letsGo: "Поехали!",
            .next: "Далее",
            .skip: "Пропустить"
        ],
        .dutch: [
            .appName: "LiveLedger",
            .totalSales: "Totale Verkoop",
            .orders: "Bestellingen",
            .products: "Producten",
            .settings: "Instellingen",
            .topSelling: "Bestverkocht",
            .currentMonth: "Deze Maand",
            .previousMonth: "Vorige Maand",
            .tutorial: "Tutorial",
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

