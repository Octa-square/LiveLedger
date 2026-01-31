//
//  AppReviewHelper.swift
//  LiveLedger
//
//  Requests App Store review at strategic moments (once per version).
//

import StoreKit
import SwiftUI

#if os(iOS)
import UIKit

enum AppReviewHelper {
    private static let hasRequestedReviewKey = "liveledger_has_requested_review"
    private static let hasExportedOnceKey = "liveledger_has_exported_once"
    
    /// Call after first successful export. Marks export done and may request review.
    static func notifyExportCompleted() {
        UserDefaults.standard.set(true, forKey: hasExportedOnceKey)
        tryRequestReview(hasExported: true, orderCount: nil)
    }
    
    /// Call after adding an order; pass current total order count. May request review when count >= 5.
    static func notifyOrderCountReached(_ count: Int) {
        tryRequestReview(hasExported: nil, orderCount: count)
    }
    
    /// Requests review at most once per app install when user has exported or has 5+ orders.
    private static func tryRequestReview(hasExported: Bool?, orderCount: Int?) {
        guard !UserDefaults.standard.bool(forKey: hasRequestedReviewKey) else { return }
        let didExport = hasExported ?? UserDefaults.standard.bool(forKey: hasExportedOnceKey)
        let eligible = didExport || (orderCount ?? 0) >= 5
        guard eligible else { return }
        
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }
        
        if #available(iOS 18.0, *) {
            AppStore.requestReview(in: scene)
        } else {
            SKStoreReviewController.requestReview(in: scene)
        }
        UserDefaults.standard.set(true, forKey: hasRequestedReviewKey)
    }
}
#endif
