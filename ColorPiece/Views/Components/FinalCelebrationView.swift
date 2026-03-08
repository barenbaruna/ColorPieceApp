//
//  FinalCelebrationView.swift
//  ColorPiece
//
//  Shared final celebration overlay shown when all rounds
//  of a game mode are completed. Features confetti animation,
//  affirmation message, score display, and Finish button.
//  Used by both Match and Mix game modes.
//
//  Created by Academy on 04/03/26.
//

import SwiftUI

// MARK: - FinalCelebrationView

/// A full-screen celebration shown when a game mode is fully completed.
///
/// Features:
/// - Confetti rain with all game colors
/// - Trophy animation
/// - Warm affirmation text for encouragement
/// - Score summary
/// - "Finish" button to return to the home screen
struct FinalCelebrationView: View {

    // MARK: - Properties

    /// The player's final score.
    let score: Int

    /// The game mode name (e.g., "Match" or "Mix").
    let modeName: String

    /// Action triggered when the user taps "Finish".
    let onFinish: () -> Void

    @State private var isAnimating = false

    /// Affirmation messages for positive reinforcement.
    private let affirmations = [
        "You're a Color Champion! 🌟",
        "Amazing Work! 🏆",
        "Super Star! ⭐",
        "You Did It! 🎉"
    ]

    // MARK: - Body

    var body: some View {
        ZStack {
            // Dimmed backdrop
            Color.black.opacity(0.5)
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
            ForEach(0..<20, id: \.self) { index in
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

    /// A single confetti particle.
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
        let xPos = CGFloat(index) * (screenWidth / 20) + 10
        let delay = Double(index) * 0.06
        let targetY = isAnimating ? screenHeight + 20 : -20
        let symbols = ["star.fill", "heart.fill", "sparkle"]
        let symbol = symbols[index % symbols.count]

        return Image(systemName: symbol)
            .font(.system(size: CGFloat.random(in: 10...20)))
            .foregroundStyle(color)
            .position(x: xPos, y: targetY)
            .rotationEffect(.degrees(isAnimating ? Double(index * 60) : 0))
            .animation(
                .easeIn(duration: 2.5)
                    .delay(delay)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
    }

    /// The main celebration card.
    private var contentCard: some View {
        VStack(spacing: 20) {
            // Trophy icon
            Image(systemName: "trophy.fill")
                .font(.system(size: 70))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.boldYellow, .boldOrange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(isAnimating ? 1.1 : 0.8)
                .animation(
                    .easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .accessibilityLabel("Trophy icon")

            // Affirmation text
            Text(affirmations.randomElement() ?? "Great Job! 🎉")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            // Score display
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.boldYellow)
                Text("\(score) matches!")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            // Finish button
            Button(action: onFinish) {
                HStack(spacing: 10) {
                    Image(systemName: "house.fill")
                        .font(.title3)

                    Text("Finish")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.boldGreen, .boldBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .boldGreen.opacity(0.4), radius: 10, y: 6)
            }
            .accessibilityIdentifier("finishButton")
            .accessibilityHint("Returns to the home screen")
            .padding(.top, 8)
        }
        .padding(36)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.25), radius: 24, y: 12)
        )
        .padding(.horizontal, 28)
    }
}

// MARK: - Preview

#Preview {
    FinalCelebrationView(score: 27, modeName: "Match", onFinish: {})
}
