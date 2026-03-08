//
//  colorooTests.swift
//  ColorPiece
//
//  Unit tests for GameViewModel, MixViewModel, GameColor, and MixColor.
//  Covers game logic, progressive difficulty, score tracking,
//  finite rounds, and color mixing validation.
//
//  Created by Academy on 03/03/26.
//

import Testing
@testable import ColorPiece

// MARK: - GameViewModel Tests

@Suite("GameViewModel Tests")
struct GameViewModelTests {

    // MARK: - Initialization

    @Test("Setup initializes all primary colors")
    @MainActor
    func setupRound_initializesAllPrimaryColors() {
        let vm = GameViewModel()
        #expect(vm.draggableColors.count == 3)
        #expect(vm.targetColors.count == 3)
        #expect(vm.roundNumber == 1)
        #expect(vm.score == 0)
        #expect(vm.isGameFinished == false)
    }

    // MARK: - Progressive Difficulty

    @Test("Round 1-2 has 3 colors")
    @MainActor
    func round1_has3Colors() {
        let vm = GameViewModel()
        #expect(vm.currentColorCount == 3)
    }

    @Test("Round 3 unlocks green (4 colors)")
    @MainActor
    func round3_has4Colors() {
        let vm = GameViewModel()
        completeCurrentRound(vm)
        vm.nextRound()
        completeCurrentRound(vm)
        vm.nextRound()
        #expect(vm.roundNumber == 3)
        #expect(vm.currentColorCount == 4)
    }

    @Test("Round 5 unlocks orange (5 colors)")
    @MainActor
    func round5_has5Colors() {
        let vm = GameViewModel()
        for _ in 1..<5 {
            completeCurrentRound(vm)
            vm.nextRound()
        }
        #expect(vm.roundNumber == 5)
        #expect(vm.currentColorCount == 5)
    }

    @Test("Round 7 unlocks purple (6 colors)")
    @MainActor
    func round7_has6Colors() {
        let vm = GameViewModel()
        for _ in 1..<7 {
            completeCurrentRound(vm)
            vm.nextRound()
        }
        #expect(vm.roundNumber == 7)
        #expect(vm.currentColorCount == 6)
    }

    // MARK: - Finite Game (8 Rounds)

    @Test("Game finishes after 8 rounds")
    @MainActor
    func gameFinishesAfter8Rounds() {
        let vm = GameViewModel()
        // Play all 8 rounds
        for round in 1...8 {
            completeCurrentRound(vm)
            vm.nextRound()
            if round < 8 {
                #expect(vm.isGameFinished == false)
            }
        }
        #expect(vm.isGameFinished == true)
    }

    @Test("isLastRound is true at round 8")
    @MainActor
    func isLastRound_trueAtRound8() {
        let vm = GameViewModel()
        for _ in 1..<8 {
            completeCurrentRound(vm)
            vm.nextRound()
        }
        #expect(vm.roundNumber == 8)
        #expect(vm.isLastRound == true)
    }

    @Test("Max rounds constant is 8")
    func maxRounds_is8() {
        #expect(GameViewModel.maxRounds == 8)
    }

    // MARK: - Match Logic

    @Test("Correct match returns true and increments score")
    @MainActor
    func handleDrop_correctMatch_returnsTrue() {
        let vm = GameViewModel()
        let color = vm.draggableColors[0]
        let result = vm.handleDrop(dragged: color, onTarget: color)
        #expect(result == true)
        #expect(vm.isMatched(color) == true)
        #expect(vm.score == 1)
    }

    @Test("Wrong match returns false")
    @MainActor
    func handleDrop_wrongMatch_returnsFalse() {
        let vm = GameViewModel()
        let dragged = GameColor.red
        let target = GameColor.blue
        let result = vm.handleDrop(dragged: dragged, onTarget: target)
        #expect(result == false)
        #expect(vm.score == 0)
    }

    @Test("Round completion detected when all matched")
    @MainActor
    func isRoundComplete_allMatched_isTrue() {
        let vm = GameViewModel()
        completeCurrentRound(vm)
        #expect(vm.isRoundComplete == true)
    }

    // MARK: - Score Persistence

    @Test("Score persists across rounds")
    @MainActor
    func score_persistsAcrossRounds() {
        let vm = GameViewModel()
        completeCurrentRound(vm)
        let scoreAfterRound1 = vm.score
        vm.nextRound()
        #expect(vm.score == scoreAfterRound1)
    }

    @Test("Reset clears everything")
    @MainActor
    func resetGame_clearsAll() {
        let vm = GameViewModel()
        completeCurrentRound(vm)
        vm.nextRound()
        vm.resetGame()
        #expect(vm.score == 0)
        #expect(vm.roundNumber == 1)
        #expect(vm.isGameFinished == false)
    }

    // MARK: - Randomization

    @Test("Draggable and target arrays are independently shuffled")
    @MainActor
    func setupRound_randomizesIndependently() {
        var differentCount = 0
        for _ in 0..<20 {
            let vm = GameViewModel()
            if vm.draggableColors != vm.targetColors {
                differentCount += 1
            }
        }
        #expect(differentCount > 0)
    }

    // MARK: - Helpers

    @MainActor
    private func completeCurrentRound(_ vm: GameViewModel) {
        for color in vm.draggableColors {
            _ = vm.handleDrop(dragged: color, onTarget: color)
        }
    }
}

// MARK: - GameColor Tests

@Suite("GameColor Tests")
struct GameColorTests {

    @Test("Primary colors returns 3")
    func primaryColors_returns3() {
        let primaries = GameColor.primaryColors
        #expect(primaries.count == 3)
    }

    @Test("Colors for round 3 includes green")
    func colorsForRound3_includesGreen() {
        let colors = GameColor.colorsForRound(3)
        #expect(colors.count == 4)
        #expect(colors.contains(.green))
    }

    @Test("Colors for round 5 includes orange")
    func colorsForRound5_includesOrange() {
        let colors = GameColor.colorsForRound(5)
        #expect(colors.count == 5)
        #expect(colors.contains(.orange))
    }

    @Test("Colors for round 7 includes purple")
    func colorsForRound7_includesPurple() {
        let colors = GameColor.colorsForRound(7)
        #expect(colors.count == 6)
        #expect(colors.contains(.purple))
    }
}

// MARK: - MixColor Tests

@Suite("MixColor Tests")
struct MixColorTests {

    @Test("All 3 challenges defined")
    func allChallenges_has3() {
        #expect(MixColor.allChallenges.count == 3)
    }

    @Test("Red + Yellow = Orange")
    func redPlusYellow_isOrange() {
        let challenge = MixColor.allChallenges.first {
            $0.color1 == .red && $0.color2 == .yellow
        }
        #expect(challenge?.resultName == "Orange")
    }

    @Test("Red + Blue = Purple")
    func redPlusBlue_isPurple() {
        let challenge = MixColor.allChallenges.first {
            $0.color1 == .red && $0.color2 == .blue
        }
        #expect(challenge?.resultName == "Purple")
    }

    @Test("Blue + Yellow = Green")
    func bluePlusYellow_isGreen() {
        let challenge = MixColor.allChallenges.first {
            $0.color1 == .blue && $0.color2 == .yellow
        }
        #expect(challenge?.resultName == "Green")
    }
}

// MARK: - MixViewModel Tests

@Suite("MixViewModel Tests")
struct MixViewModelTests {

    @Test("Max challenges is 9")
    func maxChallenges_is9() {
        #expect(MixViewModel.maxChallenges == 9)
    }

    @Test("Session setup initializes correctly")
    @MainActor
    func setupSession_initializesCorrectly() {
        let vm = MixViewModel()
        #expect(vm.challengeNumber == 1)
        #expect(vm.score == 0)
        #expect(vm.isSessionFinished == false)
        #expect(vm.answerOptions.count == 3)
    }

    @Test("Correct answer increments score")
    @MainActor
    func selectCorrectAnswer_incrementsScore() {
        let vm = MixViewModel()
        let correct = vm.answerOptions.first { $0.isCorrect }
        if let correct = correct {
            vm.selectAnswer(correct)
            #expect(vm.score == 1)
            #expect(vm.isCorrect == true)
        }
    }

    @Test("Session finishes after 9 challenges")
    @MainActor
    func sessionFinishesAfter9() {
        let vm = MixViewModel()
        for i in 1...9 {
            let correct = vm.answerOptions.first { $0.isCorrect }
            if let correct = correct {
                vm.selectAnswer(correct)
            }
            vm.advanceToNext()
            if i < 9 {
                #expect(vm.isSessionFinished == false)
            }
        }
        #expect(vm.isSessionFinished == true)
    }
}
