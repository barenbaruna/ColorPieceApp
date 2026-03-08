//
//  LearnView.swift
//  ColorPiece
//
//  Interactive color flashcard learning screen.
//  Children swipe through all 6 game colors with rich animations.
//  Each card shows a large animated circle, the color name,
//  and a gentle pulsing background. Follows Montessori
//  "introduce before challenge" principle.
//
//  Created by Academy on 04/03/26.
//

import SwiftUI

// MARK: - LearnView

/// A swipe-based flashcard view for learning color names.
///
/// Features:
/// - Full-screen color cards with animated circle and name
/// - Smooth page-style swiping between colors
/// - Pulsing circle animation for visual engagement
/// - Floating particles for a lively feel
/// - Final "Start Playing!" card to return to MainView
struct LearnView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    /// All colors to learn, in developmental order.
    private let colors: [GameColor] = [
        .red, .blue, .yellow, .green, .orange, .purple
    ]

    // MARK: - Body

    var body: some View {
        ZStack {
            // Dynamic background based on current page
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPage)

            TabView(selection: $currentPage) {
                // Color cards
                ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                    ColorCardView(gameColor: color, cardIndex: index)
                        .tag(index)
                }

                // Final card
                finalCard
                    .tag(colors.count)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .navigationTitle("Learn Colors")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Views

    /// Dynamic gradient that changes tint based on current card.
    private var backgroundGradient: some View {
        let currentColor: Color = currentPage < colors.count
            ? colors[currentPage].color
            : .boldYellow

        return LinearGradient(
            colors: [
                currentColor.opacity(0.15),
                currentColor.opacity(0.05),
                Color(.systemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// The final encouragement card.
    private var finalCard: some View {
        VStack(spacing: 28) {
            Spacer()

            // Animated stars
            ZStack {
                ForEach(0..<5, id: \.self) { index in
                    FloatingStarView(index: index)
                }
            }
            .frame(height: 120)

            Text("You Learned\nAll Colors! 🌈")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Text("Now let's play!")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)

            Button(action: { dismiss() }) {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.title3)
                    Text("Start Playing!")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.boldRed, .boldBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .boldBlue.opacity(0.4), radius: 10, y: 6)
            }
            .accessibilityIdentifier("startPlayingButton")

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - ColorCardView

/// A single color flashcard with rich animations.
struct ColorCardView: View {

    let gameColor: GameColor
    let cardIndex: Int

    @State private var isPulsing = false
    @State private var showName = false
    @State private var particlesVisible = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Floating particles around the circle
            ZStack {
                // Subtle particle ring
                ForEach(0..<8, id: \.self) { index in
                    ParticleDotView(
                        color: gameColor.color,
                        index: index,
                        isVisible: particlesVisible
                    )
                }

                // Outer glow ring
                Circle()
                    .fill(gameColor.color.opacity(0.15))
                    .frame(width: 220, height: 220)
                    .scaleEffect(isPulsing ? 1.1 : 0.9)
                    .animation(
                        .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isPulsing
                    )

                // Main color circle
                Circle()
                    .fill(gameColor.color)
                    .frame(width: 180, height: 180)
                    .shadow(color: gameColor.color.opacity(0.5), radius: 20, y: 8)
                    .scaleEffect(isPulsing ? 1.05 : 0.95)
                    .animation(
                        .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                        value: isPulsing
                    )
            }
            .accessibilityLabel("\(gameColor.displayName) color")

            Spacer()
                .frame(height: 40)

            // Color name with entrance animation
            Text(gameColor.displayName)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(gameColor.color)
                .scaleEffect(showName ? 1.0 : 0.5)
                .opacity(showName ? 1.0 : 0.0)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.6)
                        .delay(0.3),
                    value: showName
                )

            Spacer()
                .frame(height: 16)

            // Swipe hint
            HStack(spacing: 8) {
                Text("Swipe to see more")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .opacity(0.6)

            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPulsing = true
                showName = true
                particlesVisible = true
            }
        }
    }
}

// MARK: - ParticleDotView

/// A small floating dot that orbits around the color circle.
struct ParticleDotView: View {

    let color: Color
    let index: Int
    let isVisible: Bool

    @State private var isAnimating = false

    private var angle: Double {
        Double(index) * (360.0 / 8.0)
    }

    private var radius: CGFloat { 130 }

    var body: some View {
        let radians = (angle + (isAnimating ? 30 : 0)) * .pi / 180

        Circle()
            .fill(color.opacity(0.4))
            .frame(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 6...12))
            .offset(
                x: radius * CGFloat(cos(radians)),
                y: radius * CGFloat(sin(radians))
            )
            .opacity(isVisible ? 0.7 : 0)
            .animation(
                .easeInOut(duration: Double.random(in: 2.0...3.5))
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.15),
                value: isAnimating
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - FloatingStarView

/// An animated star for the final celebration card.
struct FloatingStarView: View {

    let index: Int
    @State private var isFloating = false

    private let starColors: [Color] = [
        .boldRed, .boldBlue, .boldYellow, .boldGreen, .boldOrange
    ]

    var body: some View {
        Image(systemName: "star.fill")
            .font(.system(size: CGFloat(20 + index * 4)))
            .foregroundStyle(starColors[index % starColors.count])
            .offset(
                x: CGFloat(index * 30 - 60),
                y: isFloating ? -20 : 20
            )
            .rotationEffect(.degrees(isFloating ? Double(index * 15) : 0))
            .animation(
                .easeInOut(duration: Double(index) * 0.3 + 1.0)
                    .repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFloating = true
                }
            }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LearnView()
    }
}
