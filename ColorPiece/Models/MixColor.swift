//
//  MixColor.swift
//  ColorPiece
//
//  Model for color mixing challenges.
//  Defines the three primary color combinations and their
//  expected results following subtractive color mixing rules.
//
//  Created by Academy on 04/03/26.
//

import SwiftUI

// MARK: - MixColor

/// Represents a color mixing challenge.
///
/// Each challenge shows two primary colors and asks
/// the user to select the resulting secondary color.
/// Follows subtractive color mixing (paint mixing) rules:
/// - Red + Yellow = Orange
/// - Red + Blue = Purple
/// - Blue + Yellow = Green
struct MixColor: Identifiable, Equatable {

    // MARK: - Properties

    let id = UUID()

    /// The first primary color ingredient.
    let color1: GameColor

    /// The second primary color ingredient.
    let color2: GameColor

    /// The correct resulting color name.
    let resultName: String

    /// The correct resulting SwiftUI color.
    let resultColor: Color

    // MARK: - Equatable

    static func == (lhs: MixColor, rhs: MixColor) -> Bool {
        lhs.color1 == rhs.color1 && lhs.color2 == rhs.color2
    }

    // MARK: - Static Challenges

    /// All available mixing challenges.
    static let allChallenges: [MixColor] = [
        MixColor(
            color1: .red,
            color2: .yellow,
            resultName: "Orange",
            resultColor: .boldOrange
        ),
        MixColor(
            color1: .red,
            color2: .blue,
            resultName: "Purple",
            resultColor: .boldPurple
        ),
        MixColor(
            color1: .blue,
            color2: .yellow,
            resultName: "Green",
            resultColor: .boldGreen
        )
    ]
}
