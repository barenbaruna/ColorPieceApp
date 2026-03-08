//
//  MixChallengeView.swift
//  ColorPiece
//
//  Color mixing challenge screen where children learn
//  what happens when two primary colors are combined.
//  Uses tap interaction (more accessible than drag for ages 3-4).
//  Limited to 9 challenges with per-correct celebration.
//
//  Created by Academy on 04/03/26.
//

import SwiftUI

// MARK: - MixChallengeView

/// A screen where children select the result of mixing two colors.
///
/// Layout:
/// - Top: Score bar with challenge count
/// - Center: Two color circles with "+" and "= ?"
/// - Bottom: Three large tappable answer circles
/// - Overlays: Per-correct celebration + final celebration after 9 rounds
struct MixChallengeView: View {

    // MARK: - Properties

    @StateObject private var viewModel = MixViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var showStarBurst = false
    @State private var showCorrectCelebration = false
    @State private var showTutorial = false

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    .boldYellow.opacity(0.10),
                    .boldBlue.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                scoreBar

                Spacer()

                challengePrompt

                Spacer()

                answerButtons

                Spacer()
                    .frame(height: 40)
            }

            // Star burst on correct
            if showStarBurst {
                StarBurstView(color: viewModel.currentChallenge.resultColor)
                    .allowsHitTesting(false)
            }

            // Per-correct celebration overlay
            if showCorrectCelebration && !viewModel.isSessionFinished {
                correctCelebrationOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }

            // Final celebration after 9 challenges
            if viewModel.isSessionFinished {
                FinalCelebrationView(
                    score: viewModel.score,
                    modeName: "Mix"
                ) {
                    dismiss()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }

            // Tutorial overlay (first time only)
            if showTutorial {
                TutorialOverlayView(mode: .mix) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showTutorial = false
                    }
                }
                .transition(.opacity)
            }
        }
        .navigationTitle("Mix Colors")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showCorrectCelebration)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.isSessionFinished)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showTutorial = true
            }
        }
    }

    // MARK: - Views

    /// Score and challenge counter.
    private var scoreBar: some View {
        HStack {
            Text("Challenge \(viewModel.challengeNumber)/\(MixViewModel.maxChallenges)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.boldYellow)
                Text("\(viewModel.score)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .accessibilityLabel("Score: \(viewModel.score)")
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    /// The mixing challenge visual: two color circles with + and = ?
    private var challengePrompt: some View {
        HStack(spacing: 16) {
            // First color
            Circle()
                .fill(viewModel.currentChallenge.color1.color)
                .frame(width: 80, height: 80)
                .shadow(
                    color: viewModel.currentChallenge.color1.color.opacity(0.4),
                    radius: 6,
                    y: 4
                )
                .accessibilityLabel(viewModel.currentChallenge.color1.displayName)

            Text("+")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)

            // Second color
            Circle()
                .fill(viewModel.currentChallenge.color2.color)
                .frame(width: 80, height: 80)
                .shadow(
                    color: viewModel.currentChallenge.color2.color.opacity(0.4),
                    radius: 6,
                    y: 4
                )
                .accessibilityLabel(viewModel.currentChallenge.color2.displayName)

            Text("= ?")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    /// Three large tappable answer circles.
    private var answerButtons: some View {
        HStack(spacing: 24) {
            ForEach(viewModel.answerOptions) { option in
                answerCircle(for: option)
            }
        }
        .padding(.horizontal, 24)
    }

    /// A single answer option circle button.
    ///
    /// - Parameter option: The answer option to display.
    /// - Returns: A tappable circle with feedback state.
    private func answerCircle(for option: MixViewModel.AnswerOption) -> some View {
        Button {
            viewModel.selectAnswer(option)
            if option.isCorrect {
                showStarBurst = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showStarBurst = false
                    showCorrectCelebration = true
                }
            }
        } label: {
            VStack(spacing: 8) {
                Circle()
                    .fill(option.color)
                    .frame(width: 90, height: 90)
                    .overlay(feedbackOverlay(for: option))
                    .shadow(color: option.color.opacity(0.4), radius: 6, y: 4)
                    .scaleEffect(scaleForOption(option))
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: viewModel.selectionResult)

                Text(option.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(option.color)
            }
        }
        .disabled(viewModel.isCorrect)
        .accessibilityLabel("\(option.name) color")
        .accessibilityHint("Select if you think this is the mixed color")
    }

    /// Overlay showing correct feedback on an answer circle.
    @ViewBuilder
    private func feedbackOverlay(for option: MixViewModel.AnswerOption) -> some View {
        if viewModel.isCorrect && option.isCorrect {
            Image(systemName: "checkmark")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    /// Scale effect based on selection state.
    private func scaleForOption(_ option: MixViewModel.AnswerOption) -> CGFloat {
        if viewModel.isCorrect && option.isCorrect {
            return 1.15
        }
        return 1.0
    }

    /// Celebration overlay shown after each correct answer.
    private var correctCelebrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                    .accessibilityLabel("Correct")

                Text("Correct! 🎉")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("\(viewModel.currentChallenge.color1.displayName) + \(viewModel.currentChallenge.color2.displayName) = \(viewModel.currentChallenge.resultName)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                Button {
                    showCorrectCelebration = false
                    viewModel.advanceToNext()
                } label: {
                    HStack(spacing: 8) {
                        Text(viewModel.isLastChallenge ? "See Results" : "Next")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.title3)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.boldRed, .boldBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .boldBlue.opacity(0.4), radius: 8, y: 4)
                }
                .accessibilityIdentifier("nextChallengeButton")
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            )
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MixChallengeView()
    }
}
