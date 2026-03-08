//
//  MixViewModel.swift
//  ColorPiece
//
//  ViewModel for the color mixing challenge mode.
//  Presents mixing puzzles where children select the
//  result of combining two primary colors.
//  Limited to 9 challenges (3 combos × 3 reps).
//
//  Created by Academy on 04/03/26.
//

import Foundation
import SwiftUI

// MARK: - MixViewModel

/// Manages the state and logic for the color mixing challenge.
///
/// Responsibilities:
/// - Presents random mixing challenges from a pool of 3
/// - Generates answer options (1 correct + 2 distractors)
/// - Validates selection and provides feedback
/// - Tracks score and limits to 9 challenges total
@MainActor
final class MixViewModel: ObservableObject {

    // MARK: - Constants

    /// Maximum number of challenges per session.
    static let maxChallenges = 9

    // MARK: - Published Properties

    /// The current mixing challenge.
    @Published private(set) var currentChallenge: MixColor

    /// The answer options for the current challenge (shuffled).
    @Published private(set) var answerOptions: [AnswerOption] = []

    /// The cumulative score for this session.
    @Published private(set) var score: Int = 0

    /// The current challenge number (1-based).
    @Published private(set) var challengeNumber: Int = 1

    /// The result of the last selection attempt.
    @Published var selectionResult: SelectionResult?

    /// Whether the current challenge has been answered correctly.
    @Published private(set) var isCorrect: Bool = false

    /// Whether the entire session (all 9 challenges) is complete.
    @Published private(set) var isSessionFinished: Bool = false

    // MARK: - Types

    /// Represents an answer option displayed to the user.
    struct AnswerOption: Identifiable {
        let id = UUID()
        let name: String
        let color: Color
        let isCorrect: Bool
    }

    /// The result of a selection attempt.
    enum SelectionResult: Equatable {
        case correct
        case wrong
    }

    // MARK: - Private Properties

    private var challengePool: [MixColor] = []

    // MARK: - Init

    init() {
        currentChallenge = MixColor.allChallenges[0]
        setupSession()
    }

    // MARK: - Public Methods

    /// Sets up a new session with 9 challenges (3 combos × 3 reps).
    func setupSession() {
        // Create pool: each challenge repeated 3 times
        challengePool = []
        for _ in 0..<3 {
            challengePool.append(contentsOf: MixColor.allChallenges)
        }
        challengePool.shuffle()

        score = 0
        challengeNumber = 1
        isCorrect = false
        isSessionFinished = false
        selectionResult = nil
        loadNextChallenge()
    }

    /// Handles the user selecting an answer.
    ///
    /// - Parameter option: The selected `AnswerOption`.
    func selectAnswer(_ option: AnswerOption) {
        guard selectionResult == nil else { return }

        if option.isCorrect {
            selectionResult = .correct
            isCorrect = true
            score += 1
            HapticManager.shared.playSuccess()
        } else {
            selectionResult = .wrong
            HapticManager.shared.playError()

            // Auto-clear wrong result after delay so user can try again
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.selectionResult = nil
            }
        }
    }

    /// Advances to the next challenge or finishes the session.
    func advanceToNext() {
        if challengeNumber >= Self.maxChallenges {
            isSessionFinished = true
            return
        }

        isCorrect = false
        selectionResult = nil
        challengeNumber += 1
        loadNextChallenge()
    }

    /// Whether this is the last challenge in the session.
    var isLastChallenge: Bool {
        challengeNumber >= Self.maxChallenges
    }

    /// Resets the session to start over.
    func resetSession() {
        setupSession()
    }

    // MARK: - Private Methods

    /// Loads the next challenge from the pool.
    private func loadNextChallenge() {
        if challengePool.isEmpty {
            // Replenish if somehow empty
            for _ in 0..<3 {
                challengePool.append(contentsOf: MixColor.allChallenges)
            }
            challengePool.shuffle()
        }

        currentChallenge = challengePool.removeFirst()
        generateAnswerOptions()
    }

    /// Generates 3 answer options: 1 correct + 2 distractors.
    private func generateAnswerOptions() {
        let allResults: [(String, Color)] = [
            ("Orange", .boldOrange),
            ("Purple", .boldPurple),
            ("Green", .boldGreen)
        ]

        let correct = AnswerOption(
            name: currentChallenge.resultName,
            color: currentChallenge.resultColor,
            isCorrect: true
        )

        let distractors = allResults
            .filter { $0.0 != currentChallenge.resultName }
            .map { AnswerOption(name: $0.0, color: $0.1, isCorrect: false) }

        answerOptions = ([correct] + distractors).shuffled()
    }
}
