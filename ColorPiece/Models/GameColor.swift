//
//  GameColor.swift
//  ColorPiece
//
//  Model representing game colors used in matching.
//  Supports progressive difficulty: primary colors first,
//  then secondary colors unlock in later rounds.
//  Follows Montessori Color Box progression.
//
//  Created by Academy on 03/03/26.
//

import SwiftUI

// MARK: - GameColor

/// Represents a color used in the matching game.
///
/// Colors are ordered by developmental learning sequence:
/// - **Primary** (rounds 1-2): red, blue, yellow
/// - **Secondary** (rounds 3+): green, orange, purple
///
/// Conforms to `CaseIterable` for easy enumeration and
/// `Identifiable` for use in SwiftUI `ForEach`.
enum GameColor: String, CaseIterable, Identifiable {
    case red
    case blue
    case yellow
    case green
    case orange
    case purple

    // MARK: - Identifiable

    var id: String { rawValue }

    // MARK: - Computed Properties

    /// The SwiftUI `Color` corresponding to this game color.
    var color: Color {
        switch self {
        case .red:    return .boldRed
        case .blue:   return .boldBlue
        case .yellow: return .boldYellow
        case .green:  return .boldGreen
        case .orange: return .boldOrange
        case .purple: return .boldPurple
        }
    }

    /// A human-readable name for display and accessibility labels.
    var displayName: String {
        switch self {
        case .red:    return "Red"
        case .blue:   return "Blue"
        case .yellow: return "Yellow"
        case .green:  return "Green"
        case .orange: return "Orange"
        case .purple: return "Purple"
        }
    }

    // MARK: - Static Methods

    /// Returns the set of primary colors (always available).
    static var primaryColors: [GameColor] {
        [.red, .blue, .yellow]
    }

    /// Returns the colors available for a given round number.
    ///
    /// Progressive unlock order (Montessori-inspired, 2 rounds per level):
    /// - Rounds 1-2: 3 primary colors (red, blue, yellow)
    /// - Rounds 3-4: + green (4 colors)
    /// - Rounds 5-6: + orange (5 colors)
    /// - Rounds 7-8: + purple (6 colors)
    ///
    /// - Parameter round: The current round number (1-based).
    /// - Returns: Array of available `GameColor` values.
    static func colorsForRound(_ round: Int) -> [GameColor] {
        var colors = primaryColors
        if round >= 3 {
            colors.append(.green)
        }
        if round >= 5 {
            colors.append(.orange)
        }
        if round >= 7 {
            colors.append(.purple)
        }
        return colors
    }
}
