//
//  DropZoneView.swift
//  ColorPiece
//
//  A drop target zone rendered as a dashed circle outline.
//  Fills with the matched color and plays a pop animation on match.
//  Size is passed in for adaptive scaling.
//
//  Created by Academy on 03/03/26.
//

import SwiftUI

// MARK: - DropZoneView

/// A target drop zone for the color matching game.
///
/// Displays as a dashed circle outline with a color name label.
/// When matched, transitions to a filled circle with a pop animation.
struct DropZoneView: View {

    // MARK: - Properties

    /// The target game color for this drop zone.
    let gameColor: GameColor

    /// Whether this zone has been correctly matched.
    let isMatched: Bool

    /// The rendered zone diameter. Adaptive based on color count.
    var zoneSize: CGFloat = 100

    /// Tracks the matched pop animation state.
    @State private var hasPopped = false

    // MARK: - Computed

    /// Font size scales with circle size.
    private var labelFontSize: CGFloat {
        max(12, zoneSize * 0.16)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            if isMatched {
                matchedCircle
            } else {
                unmatchedZone
            }
        }
        // Accessibility
        .accessibilityLabel("\(gameColor.displayName) drop zone")
        .accessibilityHint(isMatched ? "Matched" : "Drop the matching color here")
        // Reset pop state when match status changes
        .onChange(of: isMatched) { matched in
            if !matched {
                hasPopped = false
            }
        }
    }

    // MARK: - Views

    /// Filled circle shown when the color has been correctly matched.
    private var matchedCircle: some View {
        Circle()
            .fill(gameColor.color)
            .frame(width: zoneSize, height: zoneSize)
            .shadow(color: gameColor.color.opacity(0.4), radius: 8, y: 4)
            .scaleEffect(hasPopped ? 1.0 : 1.3)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    hasPopped = true
                }
            }
    }

    /// Dashed circle outline with color name label shown when unmatched.
    private var unmatchedZone: some View {
        VStack(spacing: 6) {
            Circle()
                .strokeBorder(
                    gameColor.color,
                    style: StrokeStyle(lineWidth: 3, dash: [8, 6])
                )
                .frame(width: zoneSize, height: zoneSize)

            Text(gameColor.displayName)
                .font(.system(size: labelFontSize, weight: .bold, design: .rounded))
                .foregroundStyle(gameColor.color)
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 30) {
        DropZoneView(gameColor: .red, isMatched: false, zoneSize: 100)
        DropZoneView(gameColor: .blue, isMatched: true, zoneSize: 100)
        DropZoneView(gameColor: .green, isMatched: false, zoneSize: 68)
    }
    .padding()
}
