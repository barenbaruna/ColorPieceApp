//
//  HapticManager.swift
//  Coloroo
//
//  Centralized haptic feedback utility.
//  Wraps UINotificationFeedbackGenerator for consistent
//  success/error feedback throughout the app.
//
//  Created by Academy on 03/03/26.
//

import UIKit

// MARK: - HapticManager

/// Provides haptic feedback for game interactions.
/// Uses `UINotificationFeedbackGenerator` for clear tactile responses.
@MainActor
final class HapticManager {

    // MARK: - Singleton

    /// Shared instance for app-wide haptic access.
    static let shared = HapticManager()

    // MARK: - Properties

    private let generator = UINotificationFeedbackGenerator()

    // MARK: - Init

    private init() {}

    // MARK: - Actions

    /// Triggers a success haptic (correct match).
    func playSuccess() {
        generator.notificationOccurred(.success)
    }

    /// Triggers an error haptic (wrong match).
    func playError() {
        generator.notificationOccurred(.error)
    }
}
