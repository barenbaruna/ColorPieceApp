//
//  DraggableCircleView.swift
//  ColorPiece
//
//  A filled colored circle that can be dragged by the user.
//  Handles visual states: normal, dragging, matched, error shake,
//  and error flash. Size is passed in for adaptive scaling.
//
//  Created by Academy on 03/03/26.
//

import SwiftUI

// MARK: - DraggableCircleView

/// A draggable colored circle representing a `GameColor`.
///
/// Visual states:
/// - **Normal**: Full opacity, resting position
/// - **Dragging**: Follows finger with slight scale-up and larger shadow
/// - **Matched**: Fades out (opacity 0) with spring animation
/// - **Error**: Shakes horizontally + brief red border flash, then snaps back
struct DraggableCircleView: View {

    // MARK: - Properties

    /// The game color this circle represents.
    let gameColor: GameColor

    /// Whether this color has been matched.
    let isMatched: Bool

    /// Current drag offset applied to this circle.
    let dragOffset: CGSize

    /// Whether the circle is currently being dragged.
    let isDragging: Bool

    /// Triggers a shake animation on incorrect drop.
    let isShaking: Bool

    /// Whether the error flash border is visible.
    let isFlashing: Bool

    /// The rendered circle diameter. Adaptive based on color count.
    var circleSize: CGFloat = 90

    // MARK: - Body

    var body: some View {
        Circle()
            .fill(gameColor.color)
            .frame(width: circleSize, height: circleSize)
            // Error flash border — red = wrong (visual consistency)
            .overlay(
                Circle()
                    .strokeBorder(Color.boldRed, lineWidth: isFlashing ? 4 : 0)
                    .frame(width: circleSize, height: circleSize)
            )
            // Layout modifiers
            .shadow(
                color: gameColor.color.opacity(0.5),
                radius: isDragging ? 14 : 6,
                y: isDragging ? 10 : 4
            )
            // Effects
            .scaleEffect(isDragging ? 1.15 : 1.0)
            .opacity(isMatched ? 0 : 1.0)
            .offset(dragOffset)
            .offset(x: isShaking ? -12 : 0)
            // Accessibility
            .accessibilityLabel("\(gameColor.displayName) circle")
            .accessibilityHint(isMatched ? "Already matched" : "Drag to the matching outline")
            .accessibilityAddTraits(.isButton)
            // Animations
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isMatched)
            .animation(
                isShaking
                    ? .interpolatingSpring(stiffness: 600, damping: 8)
                    : .interpolatingSpring(stiffness: 300, damping: 15),
                value: isShaking
            )
            .animation(.easeOut(duration: 0.15), value: isFlashing)
            .animation(.easeOut(duration: 0.2), value: isDragging)
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 30) {
        DraggableCircleView(
            gameColor: .red,
            isMatched: false,
            dragOffset: .zero,
            isDragging: false,
            isShaking: false,
            isFlashing: false,
            circleSize: 90
        )

        DraggableCircleView(
            gameColor: .blue,
            isMatched: false,
            dragOffset: .zero,
            isDragging: false,
            isShaking: false,
            isFlashing: false,
            circleSize: 68
        )
    }
    .padding()
}
