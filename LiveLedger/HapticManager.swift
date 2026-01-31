//
//  HapticManager.swift
//  LiveLedger
//
//  Centralized haptic feedback for consistent UX.
//

import UIKit

enum HapticManager {
    /// Success (e.g. order added, export completed, payment marked paid)
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    /// Error (e.g. export failed, print failed)
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    /// Warning (e.g. order deleted)
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    /// Light impact (button taps)
    static func lightImpact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    /// Selection (toggles, picker changes)
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
