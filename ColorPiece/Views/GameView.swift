//
//  GameView.swift
//  ColorPiece
//
//  The main color matching game screen with drag-and-drop.
//  Uses DragGesture with GeometryReader for hit-testing
//  drop zones. Supports progressive difficulty (3→6 colors
//  over 8 rounds) with adaptive sizing. iOS 16+.
//
//  Created by Academy on 03/03/26.
//

import SwiftUI

// MARK: - Drop Zone Frame Preference Key

/// Preference key to collect the frames of all drop zone views.
/// Used for hit-testing when a drag gesture ends.
struct DropZoneFrameKey: PreferenceKey {
    static var defaultValue: [GameColor: CGRect] = [:]

    static func reduce(value: inout [GameColor: CGRect], nextValue: () -> [GameColor: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// MARK: - GameView

/// The main game screen where the user matches colors
/// by dragging circles onto corresponding drop zones.
///
/// Architecture:
/// - `GameViewModel` owns all game state and logic
/// - This view handles rendering and gesture coordination
/// - Sub-views are pure display components
/// - Circle/zone sizes adapt dynamically to fit all colors on screen
struct GameView: View {

    // MARK: - Properties

    @StateObject private var viewModel = GameViewModel()
    @Environment(\.dismiss) private var dismiss


    @State private var activeDragColor: GameColor?
    @State private var dragOffsets: [GameColor: CGSize] = [:]
    @State private var shakingColors: Set<GameColor> = []
    @State private var flashingColors: Set<GameColor> = []
    @State private var dropZoneFrames: [GameColor: CGRect] = [:]
    @State private var burstingColor: GameColor?
    @State private var showTutorial = false

    private let coordinateSpaceName = "gameArea"

    // MARK: - Adaptive Sizing

    /// Circle size adapts to how many colors are displayed.
    /// Larger circles for fewer colors → smaller for more.
    private var circleSize: CGFloat {
        switch viewModel.currentColorCount {
        case 3: return 90
        case 4: return 78
        case 5: return 68
        default: return 58  // 6 colors
        }
    }

    /// Drop zone size — slightly larger than circles for easier aiming.
    private var zoneSize: CGFloat {
        circleSize + 10
    }

    /// Spacing between items — tighter with more items.
    private var itemSpacing: CGFloat {
        switch viewModel.currentColorCount {
        case 3: return 40
        case 4: return 28
        case 5: return 18
        default: return 12  // 6 colors
        }
    }

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

            // Game content
            VStack(spacing: 12) {
                scoreBar
                gameContent
            }
            .coordinateSpace(name: coordinateSpaceName)
            .onPreferenceChange(DropZoneFrameKey.self) { frames in
                dropZoneFrames = frames
            }

            // Star burst overlay
            if let color = burstingColor {
                StarBurstView(color: color.color)
                    .allowsHitTesting(false)
            }

            // Round complete overlay (not last round)
            if viewModel.isRoundComplete && !viewModel.isLastRound && !viewModel.isGameFinished {
                SuccessOverlayView(
                    score: viewModel.score,
                    roundNumber: viewModel.roundNumber,
                    isLastRound: false
                ) {
                    viewModel.nextRound()
                    resetDragState()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }

            // Last round complete → advance to final
            if viewModel.isRoundComplete && viewModel.isLastRound && !viewModel.isGameFinished {
                SuccessOverlayView(
                    score: viewModel.score,
                    roundNumber: viewModel.roundNumber,
                    isLastRound: true
                ) {
                    viewModel.nextRound()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }

            // Final celebration
            if viewModel.isGameFinished {
                FinalCelebrationView(
                    score: viewModel.score,
                    modeName: "Match"
                ) {
                    dismiss()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }

            // Tutorial overlay (first time only)
            if showTutorial {
                TutorialOverlayView(mode: .match) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showTutorial = false
                    }
                }
                .transition(.opacity)
            }
        }
        .navigationTitle("Match Colors")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.isRoundComplete)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.isGameFinished)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showTutorial = true
            }
        }
    }

    // MARK: - Views

    /// Score and round indicator.
    private var scoreBar: some View {
        HStack {
            Text("Round \(viewModel.roundNumber)/\(GameViewModel.maxRounds)")
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
        .padding(.top, 4)
    }

    /// The two-column game layout with adaptive spacing.
    private var gameContent: some View {
        HStack(spacing: 0) {
            // Left column: Draggable circles
            VStack(spacing: itemSpacing) {
                ForEach(viewModel.draggableColors) { color in
                    draggableItem(for: color)
                }
            }
            .frame(maxWidth: .infinity)

            // Center divider
            Rectangle()
                .fill(Color.secondary.opacity(0.15))
                .frame(width: 1)
                .padding(.vertical, 10)

            // Right column: Drop zones
            VStack(spacing: itemSpacing) {
                ForEach(viewModel.targetColors) { color in
                    targetItem(for: color)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
    }

    /// A single draggable circle with adaptive size.
    @ViewBuilder
    private func draggableItem(for color: GameColor) -> some View {
        let isMatched = viewModel.isMatched(color)
        let isDragging = activeDragColor == color
        let offset = dragOffsets[color] ?? .zero
        let isShaking = shakingColors.contains(color)
        let isFlashing = flashingColors.contains(color)

        DraggableCircleView(
            gameColor: color,
            isMatched: isMatched,
            dragOffset: offset,
            isDragging: isDragging,
            isShaking: isShaking,
            isFlashing: isFlashing,
            circleSize: circleSize
        )
        .gesture(
            isMatched ? nil : dragGesture(for: color)
        )
    }

    /// A single drop zone target with adaptive size.
    private func targetItem(for color: GameColor) -> some View {
        DropZoneView(
            gameColor: color,
            isMatched: viewModel.isMatched(color),
            zoneSize: zoneSize
        )
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: DropZoneFrameKey.self,
                        value: [color: geometry.frame(in: .named(coordinateSpaceName))]
                    )
            }
        )
    }

    // MARK: - Gestures

    private func dragGesture(for color: GameColor) -> some Gesture {
        DragGesture(coordinateSpace: .named(coordinateSpaceName))
            .onChanged { value in
                activeDragColor = color
                dragOffsets[color] = value.translation
            }
            .onEnded { value in
                handleDragEnd(for: color, at: value.location)
            }
    }

    // MARK: - Private Methods

    private func handleDragEnd(for color: GameColor, at location: CGPoint) {
        activeDragColor = nil

        let matchedTarget = dropZoneFrames.first { _, frame in
            frame.contains(location)
        }

        if let target = matchedTarget {
            let isCorrect = viewModel.handleDrop(dragged: color, onTarget: target.key)
            if isCorrect {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    dragOffsets[color] = .zero
                }
                triggerBurst(for: color)
            } else {
                triggerShakeAndFlash(for: color)
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                dragOffsets[color] = .zero
            }
        }
    }

    private func triggerBurst(for color: GameColor) {
        burstingColor = color
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            burstingColor = nil
        }
    }

    private func triggerShakeAndFlash(for color: GameColor) {
        shakingColors.insert(color)
        flashingColors.insert(color)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            shakingColors.remove(color)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                dragOffsets[color] = .zero
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            flashingColors.remove(color)
        }
    }

    private func resetDragState() {
        dragOffsets = [:]
        shakingColors = []
        flashingColors = []
        activeDragColor = nil
        burstingColor = nil
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GameView()
    }
}
