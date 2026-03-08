//
//  Color+Palette.swift
//  ColorPiece
//
//  Bold color palette derived from the ColorPiece logo.
//  Colors are high-contrast and kid-friendly, following
//  research recommendations for ages 3-6.
//
//  Created by Academy on 03/03/26.
//

import SwiftUI

// MARK: - Bold Color Palette

extension Color {

    /// Bold red from the logo puzzle piece.
    static let boldRed = Color(red: 1.00, green: 0.12, blue: 0.34)

    /// Bold blue from the logo puzzle piece.
    static let boldBlue = Color(red: 0.19, green: 0.67, blue: 1.00)

    /// Bold yellow from the logo puzzle piece.
    static let boldYellow = Color(red: 1.00, green: 0.84, blue: 0.00)

    /// Bold green — secondary color (unlocked at Round 3).
    static let boldGreen = Color(red: 0.20, green: 0.78, blue: 0.35)

    /// Bold orange — secondary color (unlocked at Round 5).
    static let boldOrange = Color(red: 1.00, green: 0.58, blue: 0.00)

    /// Bold purple — secondary color (unlocked at Round 7).
    static let boldPurple = Color(red: 0.60, green: 0.25, blue: 0.85)
}
