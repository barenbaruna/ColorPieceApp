//
//  GameViewModel.swift
//  ColorPiece
//
//  ViewModel for the color matching game.
//  Owns all game state: progressive difficulty, shuffled
//  color arrays, match tracking, score, and round management.
//  Game ends after 8 rounds (2 rounds per difficulty level).
//
//  Created by Academy on 03/03/26.
//

import Foundation
import SwiftUI

// MARK: - GameViewModel

/// Manages the state and logic for the color matching game.
///
/// Responsibilities:
/// - Progressive difficulty: unlocks new colors every 2 rounds
/// - Independently randomizes draggable and target color orders
/// - Validates matches and triggers haptic feedback
/// - Tracks score, round, and completion state
/// - Ends the game after 8 rounds with a final celebration
@MainActor
final class GameViewModel: ObservableObject {

    // MARK: - Constants

    /// Maximum number of rounds before the game ends.
    static let maxRounds = 8

    // MARK: - Published Properties

    /// The shuffled order of draggable colored circles (left column).
    @Published private(set) var draggableColors: [GameColor] = []

    /// The shuffled order of target drop zones (right column).
    @Published private(set) var targetColors: [GameColor] = []

    /// Tracks which colors have been correctly matched.
    @Published private(set) var matches: [GameColor: Bool] = [:]

    /// Whether all colors in the current round have been matched.
    @Published private(set) var isRoundComplete: Bool = false

    /// The cumulative score across all rounds.
    @Published private(set) var score: Int = 0

    /// The current round number (1-based).
    @Published private(set) var roundNumber: Int = 1

    /// Whether the entire game (all 8 rounds) has been completed.
    @Published private(set) var isGameFinished: Bool = false

    /// Tracks the most recently matched color for burst animation.
    @Published var lastMatchedColor: GameColor?

    // MARK: - Init

    init() {
        setupRound()
    }

    // MARK: - Public Methods

    /// Sets up the current round with colors based on progressive difficulty.
    /// Shuffles both columns independently.
    func setupRound() {
        let available = GameColor.colorsForRound(roundNumber)
        draggableColors = available.shuffled()
        targetColors = available.shuffled()
        matches = Dictionary(
            uniqueKeysWithValues: available.map { ($0, false) }
        )
        isRoundComplete = false
        lastMatchedColor = nil
    }

    /// Advances to the next round and sets up the board.
    /// If this was the last round, marks the game as finished.
    func nextRound() {
        if roundNumber >= Self.maxRounds {
            isGameFinished = true
            return
        }
        roundNumber += 1
        setupRound()
    }

    /// Resets all state to start from Round 1.
    func resetGame() {
        score = 0
        roundNumber = 1
        isGameFinished = false
        setupRound()
    }

    /// Validates whether a dragged color matches the target zone.
    ///
    /// - Parameters:
    ///   - dragged: The `GameColor` being dragged.
    ///   - target: The `GameColor` of the drop zone.
    /// - Returns: `true` if the match is correct, `false` otherwise.
    func handleDrop(dragged: GameColor, onTarget target: GameColor) -> Bool {
        guard dragged == target else {
            HapticManager.shared.playError()
            return false
        }

        // Mark as matched and increment score
        matches[dragged] = true
        score += 1
        lastMatchedColor = dragged
        HapticManager.shared.playSuccess()

        // Check for round completion
        checkRoundCompletion()
        return true
    }

    /// Returns whether a specific color has been matched.
    ///
    /// - Parameter color: The `GameColor` to check.
    /// - Returns: `true` if already matched.
    func isMatched(_ color: GameColor) -> Bool {
        matches[color] ?? false
    }

    /// The number of colors in the current round.
    var currentColorCount: Int {
        GameColor.colorsForRound(roundNumber).count
    }

    /// Whether this is the last round of the game.
    var isLastRound: Bool {
        roundNumber >= Self.maxRounds
    }

    // MARK: - Private Methods

    /// Updates `isRoundComplete` based on whether all matches are `true`.
    private func checkRoundCompletion() {
        isRoundComplete = matches.values.allSatisfy { $0 }
    }
}
