//
//  SuccessOverlayView.swift
//  ColorPiece
//
//  Overlay displayed when all colors in a round are matched.
//  Shows confetti, score, and either "Next Round" or triggers
//  the final celebration for the last round.
//
//  Created by Academy on 03/03/26.
//

import SwiftUI

// MARK: - SuccessOverlayView

/// A celebration overlay shown when a round is completed.
///
/// Features:
/// - Animated confetti particles
/// - Congratulatory message with emoji
/// - Score display
/// - "Next Round" button to advance
struct SuccessOverlayView: View {

    // MARK: - Properties

    /// The player's current score.
    let score: Int

    /// The round that was just completed.
    let roundNumber: Int

    /// Whether this is the last round (changes button behavior).
    let isLastRound: Bool

    /// Action triggered when the user taps "Next Round".
    let onNextRound: () -> Void

    @State private var isAnimating = false

    // MARK: - Body

    var body: some View {
        ZStack {
            // Dimmed backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            // Confetti particles
            confettiLayer

            // Content card
            contentCard
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimating = true
            }
        }
    }

    // MARK: - Views

    /// Falling confetti particles across the screen.
    private var confettiLayer: some View {
        GeometryReader { geometry in
            ForEach(0..<12, id: \.self) { index in
                confettiParticle(
                    index: index,
                    screenWidth: geometry.size.width,
                    screenHeight: geometry.size.height
                )
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    /// A single confetti particle that falls from top.
    private func confettiParticle(
        index: Int,
        screenWidth: CGFloat,
        screenHeight: CGFloat
    ) -> some View {
        let colors: [Color] = [
            .boldRed, .boldBlue, .boldYellow,
            .boldGreen, .boldOrange, .boldPurple
        ]
        let color = colors[index % colors.count]
        let xPos = CGFloat(index) * (screenWidth / 12) + 10
        let delay = Double(index) * 0.08
        let targetY = isAnimating ? screenHeight + 20 : -20

        return Image(systemName: "star.fill")
            .font(.system(size: CGFloat.random(in: 10...18)))
            .foregroundStyle(color)
            .position(x: xPos, y: targetY)
            .rotationEffect(.degrees(isAnimating ? Double(index * 45) : 0))
            .animation(
                .easeIn(duration: 2.0)
                    .delay(delay)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
    }

    /// The main success card with message and button.
    private var contentCard: some View {
        VStack(spacing: 20) {
            // Star icon
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .animation(
                    .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .accessibilityLabel("Star icon")

            // Congratulations text
            Text("Great Job! 🎉")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            // Score display
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.boldYellow)
                Text("\(score) matches")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            // Round info
            Text("Round \(roundNumber) complete!")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)

            // Next Round button
            Button(action: onNextRound) {
                HStack(spacing: 10) {
                    Text("Next Round")
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
            .accessibilityIdentifier("nextRoundButton")
            .accessibilityHint("Advances to the next round with more colors")
        }
        .padding(36)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        )
        .padding(.horizontal, 32)
    }
}

// MARK: - Preview

#Preview {
    SuccessOverlayView(
        score: 6,
        roundNumber: 2,
        isLastRound: false,
        onNextRound: {}
    )
}
