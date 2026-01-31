//
//  DataManager.swift
//  LiveLedger
//
//  Backup, restore, and delete-all data operations.
//

import Foundation
@preconcurrency import SwiftUI
import UniformTypeIdentifiers

// MARK: - Backup File Document (for fileExporter)
struct BackupFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var backup: BackupData
    
    init(backup: BackupData) {
        self.backup = backup
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw CocoaError(.fileReadUnknown) }
        backup = try MainActor.assumeIsolated {
            try JSONDecoder().decode(BackupData.self, from: data)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try MainActor.assumeIsolated {
            try JSONEncoder().encode(backup)
        }
        return FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - Backup Data (JSON)
struct BackupData: Codable {
    let orders: [Order]
    let catalogs: [ProductCatalog]
    let platforms: [Platform]
    let exportDate: Date
    let appVersion: String?
    
    init(orders: [Order], catalogs: [ProductCatalog], platforms: [Platform], exportDate: Date = Date(), appVersion: String? = nil) {
        self.orders = orders
        self.catalogs = catalogs
        self.platforms = platforms
        self.exportDate = exportDate
        self.appVersion = appVersion ?? Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

// MARK: - Data Manager
enum DataManager {
    
    /// Build backup from current view model state.
    static func buildBackup(from viewModel: SalesViewModel) -> BackupData {
        BackupData(
            orders: viewModel.orders,
            catalogs: viewModel.catalogs,
            platforms: viewModel.platforms,
            exportDate: Date()
        )
    }
    
    /// Encode backup to JSON data.
    static func exportToJSON(_ backup: BackupData) -> Data? {
        try? JSONEncoder().encode(backup)
    }
    
    /// Decode backup from JSON data.
    static func restoreFromJSON(_ data: Data) -> BackupData? {
        try? JSONDecoder().decode(BackupData.self, from: data)
    }
    
    /// Default backup filename with date.
    static func defaultBackupFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return "LiveLedger_Backup_\(formatter.string(from: Date())).json"
    }
    
    /// UserDefaults keys used by the app (for delete-all).
    private static let userDefaultsKeysToRemove: [String] = [
        "livesales_catalogs",
        "livesales_selected_catalog",
        "livesales_orders",
        "livesales_platforms",
        "livesales_products",
        "liveledger_user",
        "liveledger_accounts",
        "hasCompletedOnboarding",
        "hasSelectedPlan",
        "isLoggedIn",
        "demo_data_seeded",
        "livesales_timer_elapsed",
        "livesales_timer_active",
        "livesales_timer_running",
        "livesales_timer_manually_paused",
        "livesales_timer_session_ended",
        "livesales_timer_last_update",
        "liveledger_has_exported_once",
        "liveledger_has_requested_review",
        "was_pro_subscriber",
        "liveledger_orders_used",
        "liveledger_exports_used"
    ]
    
    /// Remove all app data from UserDefaults. Call before signing out for "Delete My Data".
    static func deleteAllUserData() {
        let defaults = UserDefaults.standard
        for key in userDefaultsKeysToRemove {
            defaults.removeObject(forKey: key)
        }
        // Remove any other liveledger/livesales prefixed keys
        let dict = defaults.dictionaryRepresentation()
        for key in dict.keys {
            if key.hasPrefix("liveledger_") || key.hasPrefix("livesales_") {
                defaults.removeObject(forKey: key)
            }
        }
    }
}
