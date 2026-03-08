//
//  MainView.swift
//  ColorPiece
//
//  Playful home screen with app logo, title, and three game mode
//  buttons: Learn (flashcards), Match (drag-and-drop), and
//  Mix (color combining). Ordered by scaffolding progression.
//
//  Created by Academy on 03/03/26.
//

import SwiftUI

// MARK: - MainView

/// The home screen with three game mode buttons.
///
/// Button order follows scaffolding progression:
/// 1. **Learn** — introduce colors first
/// 2. **Match** — practice recognition
/// 3. **Mix** — apply knowledge
struct MainView: View {

    // MARK: - Properties

    @State private var isBouncing = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        .boldYellow.opacity(0.15),
                        .boldBlue.opacity(0.15),
                        .boldRed.opacity(0.15)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer()

                    // App logo
                    Image("Colorpiece")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .accessibilityLabel("ColorPiece logo")

                    // Title
                    Text("ColorPiece")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    // Subtitle
                    Text("Learn colors, have fun!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)

                    Spacer()

                    // Game mode buttons — scaffolding order
                    VStack(spacing: 14) {
                        // Learn mode
                        NavigationLink(destination: LearnView()) {
                            gameModeButton(
                                icon: "book.fill",
                                title: "Learn",
                                colors: [.boldYellow, .boldGreen]
                            )
                        }
                        .accessibilityIdentifier("learnButton")
                        .accessibilityHint("Learn color names with flashcards")

                        // Match mode
                        NavigationLink(destination: GameView()) {
                            gameModeButton(
                                icon: "puzzlepiece.fill",
                                title: "Match",
                                colors: [.boldRed, .boldBlue]
                            )
                        }
                        .accessibilityIdentifier("matchButton")
                        .accessibilityHint("Starts the color matching game")

                        // Mix mode
                        NavigationLink(destination: MixChallengeView()) {
                            gameModeButton(
                                icon: "paintpalette.fill",
                                title: "Mix",
                                colors: [.boldBlue, .boldGreen]
                            )
                        }
                        .accessibilityIdentifier("mixButton")
                        .accessibilityHint("Starts the color mixing challenge")
                    }
                    .offset(y: isBouncing ? -6 : 0)
                    .animation(
                        .easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                        value: isBouncing
                    )

                    Spacer()
                        .frame(height: 50)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isBouncing = true
                }
            }
        }
    }

    // MARK: - Views

    /// A styled game mode button.
    ///
    /// - Parameters:
    ///   - icon: SF Symbol name for the button icon.
    ///   - title: The button title text.
    ///   - colors: Gradient colors for the button background.
    /// - Returns: A styled button label view.
    private func gameModeButton(
        icon: String,
        title: String,
        colors: [Color]
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)

            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .frame(maxWidth: 220)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: colors,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(Capsule())
        .shadow(color: colors[0].opacity(0.4), radius: 10, y: 6)
    }
}

// MARK: - Preview

#Preview {
    MainView()
}
