//
//  StarBurstView.swift
//  ColorPiece
//
//  Animated star burst effect shown on correct color match.
//  Replaces audio "Good job!" with visual celebration,
//  following research recommendation for silent feedback.
//
//  Created by Academy on 04/03/26.
//

import SwiftUI

// MARK: - StarBurstView

/// A burst of animated stars that appears when a color is matched.
///
/// Research basis: *"bintang muncul sebagai pengganti suara 'Good job'"* [ref 14].
/// Stars fly outward from center and fade, lasting ~1 second.
struct StarBurstView: View {

    // MARK: - Properties

    /// The color of the matched item (stars inherit this color).
    let color: Color

    /// Number of stars in the burst.
    private let starCount = 6

    @State private var isAnimating = false

    // MARK: - Body

    var body: some View {
        ZStack {
            ForEach(0..<starCount, id: \.self) { index in
                starParticle(index: index)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Views

    /// A single star particle with computed trajectory.
    ///
    /// - Parameter index: Particle index for angle calculation.
    /// - Returns: An animated star image.
    private func starParticle(index: Int) -> some View {
        let angle = Double(index) * (360.0 / Double(starCount))
        let radians = angle * .pi / 180
        let distance: CGFloat = isAnimating ? 60 : 0

        return Image(systemName: "star.fill")
            .font(.system(size: isAnimating ? 12 : 18))
            .foregroundStyle(color)
            .offset(
                x: distance * CGFloat(cos(radians)),
                y: distance * CGFloat(sin(radians))
            )
            .opacity(isAnimating ? 0 : 1)
            .scaleEffect(isAnimating ? 0.3 : 1.2)
            .accessibilityHidden(true)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        StarBurstView(color: .boldRed)
        StarBurstView(color: .boldBlue)
        StarBurstView(color: .boldYellow)
    }
}
