//
//  SplashView.swift
//  ColorPiece
//
//  Splash screen with animated logo and app title.
//  Auto-navigates to MainView after a 2-second delay.
//
//  Created by Academy on 03/03/26.
//

import SwiftUI

// MARK: - SplashView

/// The initial launch screen with a scaling animation.
/// Automatically transitions to `MainView` after 2 seconds.
struct SplashView: View {

    // MARK: - Properties

    @State private var isActive = false
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.0

    // MARK: - Body

    var body: some View {
        if isActive {
            MainView()
        } else {
            splashContent
                .onAppear {
                    startAnimations()
                    scheduleTransition()
                }
        }
    }

    // MARK: - Views

    private var splashContent: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.boldBlue.opacity(0.2), .boldYellow.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // App logo
                Image("Colorpiece")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .accessibilityLabel("ColorPiece logo")

                // App title
                Text("ColorPiece")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
    }

    // MARK: - Private Methods

    /// Starts the scaling and fade-in animations.
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8)) {
            scale = 1.0
            opacity = 1.0
        }
    }

    /// Schedules the transition to MainView after 2 seconds.
    private func scheduleTransition() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isActive = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SplashView()
}
