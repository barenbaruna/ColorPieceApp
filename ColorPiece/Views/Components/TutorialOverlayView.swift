//
//  TutorialOverlayView.swift
//  ColorPiece
//
//  Animated tutorial overlay that demonstrates how to play.
//  Supports two modes: Match (drag demo) and Mix (tap demo).
//  Only shown once per mode using @AppStorage persistence.
//  Full-effort animations with hand gesture demonstrations.
//
//  Created by Academy on 04/03/26.
//

import SwiftUI

// MARK: - TutorialMode

/// The type of tutorial to display.
enum TutorialMode {
    case match
    case mix
}

// MARK: - TutorialOverlayView

/// An animated tutorial overlay that teaches game mechanics.
///
/// - **Match mode**: Animated hand drags a circle to a drop zone
/// - **Mix mode**: Animated hand taps an answer circle
///
/// Uses `@AppStorage` to ensure each tutorial only shows once.
struct TutorialOverlayView: View {

    // MARK: - Properties

    /// The tutorial mode to display.
    let mode: TutorialMode

    /// Callback when the user dismisses the tutorial.
    let onDismiss: () -> Void

    @State private var isAnimating = false
    @State private var handOffset: CGFloat = 0
    @State private var handScale: CGFloat = 1.0
    @State private var handOpacity: Double = 1.0
    @State private var showContent = false
    @State private var pulseTarget = false

    // MARK: - Body

    var body: some View {
        ZStack {
            // Dimmed backdrop
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            // Tutorial card
            VStack(spacing: 24) {
                // Title
                Text(titleText)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)

                // Animation demo area
                demoArea
                    .frame(height: 160)

                // Instruction text
                Text(instructionText)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)

                // Dismiss button
                Button(action: onDismiss) {
                    HStack(spacing: 8) {
                        Text("Got it!")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        Image(systemName: "checkmark")
                            .font(.title3)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: buttonColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: buttonColors[0].opacity(0.4), radius: 8, y: 4)
                }
                .accessibilityIdentifier("tutorialDismissButton")
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.25), radius: 24, y: 12)
            )
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
            startAnimation()
        }
    }

    // MARK: - Demo Areas

    /// The animated demonstration area based on mode.
    @ViewBuilder
    private var demoArea: some View {
        switch mode {
        case .match:
            matchDemoArea
        case .mix:
            mixDemoArea
        }
    }

    /// Match mode: animated hand dragging a circle to a drop zone.
    private var matchDemoArea: some View {
        ZStack {
            HStack(spacing: 60) {
                // Source circle (draggable demo)
                Circle()
                    .fill(Color.boldRed)
                    .frame(width: 60, height: 60)
                    .shadow(color: .boldRed.opacity(0.4), radius: 8, y: 4)
                    .opacity(isAnimating ? 0.3 : 1.0)

                // Target drop zone
                Circle()
                    .strokeBorder(
                        Color.boldRed,
                        style: StrokeStyle(lineWidth: 3, dash: [6, 5])
                    )
                    .frame(width: 66, height: 66)
                    .scaleEffect(pulseTarget ? 1.08 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                        value: pulseTarget
                    )
            }

            // Animated dragging circle (follows hand)
            Circle()
                .fill(Color.boldRed)
                .frame(width: 60, height: 60)
                .shadow(color: .boldRed.opacity(0.5), radius: 12, y: 6)
                .scaleEffect(1.1)
                .offset(x: handOffset - 60)
                .opacity(isAnimating ? 1.0 : 0.0)

            // Animated hand
            Image(systemName: "hand.point.up.fill")
                .font(.system(size: 36))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                .offset(x: handOffset - 60, y: 40)
                .opacity(handOpacity)
        }
    }

    /// Mix mode: animated hand tapping an answer circle.
    private var mixDemoArea: some View {
        ZStack {
            // Question prompt
            VStack(spacing: 16) {
                // Color equation
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color.boldRed)
                        .frame(width: 36, height: 36)
                    Text("+")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    Circle()
                        .fill(Color.boldBlue)
                        .frame(width: 36, height: 36)
                    Text("= ?")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                // Answer options
                HStack(spacing: 20) {
                    // Wrong
                    Circle()
                        .fill(Color.boldGreen)
                        .frame(width: 44, height: 44)
                        .opacity(0.5)

                    // Correct (target for hand)
                    Circle()
                        .fill(Color.boldPurple)
                        .frame(width: 44, height: 44)
                        .scaleEffect(handScale)
                        .shadow(
                            color: .boldPurple.opacity(pulseTarget ? 0.6 : 0.2),
                            radius: pulseTarget ? 12 : 4,
                            y: 4
                        )

                    // Wrong
                    Circle()
                        .fill(Color.boldOrange)
                        .frame(width: 44, height: 44)
                        .opacity(0.5)
                }

                // Hand pointing at the correct answer
                Image(systemName: "hand.point.up.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                    .scaleEffect(handScale)
                    .opacity(handOpacity)
            }
        }
    }

    // MARK: - Computed Properties

    private var titleText: String {
        switch mode {
        case .match: return "How to Play 🧩"
        case .mix: return "How to Mix 🎨"
        }
    }

    private var instructionText: String {
        switch mode {
        case .match: return "Drag each color circle\nto the matching outline!"
        case .mix: return "Tap the color you think\nis the correct answer!"
        }
    }

    private var buttonColors: [Color] {
        switch mode {
        case .match: return [.boldRed, .boldBlue]
        case .mix: return [.boldBlue, .boldGreen]
        }
    }

    // MARK: - Animation

    /// Starts the looping tutorial animation.
    private func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            pulseTarget = true
        }

        switch mode {
        case .match:
            startMatchAnimation()
        case .mix:
            startMixAnimation()
        }
    }

    /// Match: hand drags circle from left to right, loops.
    private func startMatchAnimation() {
        func runCycle() {
            // Reset
            handOffset = 0
            isAnimating = false
            handOpacity = 1.0

            // Phase 1: Pause at start
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = true
                // Phase 2: Drag to target
                withAnimation(.easeInOut(duration: 1.2)) {
                    handOffset = 120
                }
            }

            // Phase 3: Fade out at target
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeOut(duration: 0.3)) {
                    handOpacity = 0
                    isAnimating = false
                }
            }

            // Phase 4: Loop
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                runCycle()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            runCycle()
        }
    }

    /// Mix: hand taps (scales down+up) on the correct answer, loops.
    private func startMixAnimation() {
        func runCycle() {
            // Reset
            handScale = 1.0
            handOpacity = 1.0

            // Phase 1: Hand appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Phase 2: Tap down
                withAnimation(.easeIn(duration: 0.15)) {
                    handScale = 0.85
                }
            }

            // Phase 3: Tap up (spring bounce)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                    handScale = 1.15
                }
            }

            // Phase 4: Settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeOut(duration: 0.2)) {
                    handScale = 1.0
                }
            }

            // Phase 5: Fade + loop
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    handOpacity = 0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                runCycle()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            runCycle()
        }
    }
}

// MARK: - Preview

#Preview("Match Tutorial") {
    TutorialOverlayView(mode: .match, onDismiss: {})
}

#Preview("Mix Tutorial") {
    TutorialOverlayView(mode: .mix, onDismiss: {})
}
