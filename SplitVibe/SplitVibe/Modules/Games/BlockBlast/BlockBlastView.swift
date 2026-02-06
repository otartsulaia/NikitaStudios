import SwiftUI
import SpriteKit

struct BlockBlastView: View {
    @State private var viewModel = BlockBlastViewModel()
    @State private var displayedScore: Int = 0
    @State private var showGameOver = false
    @State private var playAgainPressed = false
    @State private var isNewBest = false
    @State private var particlePhase: CGFloat = 0

    var body: some View {
        ZStack {
            // Game scene
            SpriteView(scene: viewModel.scene, options: [.allowsTransparency])
                .ignoresSafeArea()
                .background(Color(.systemBackground))

            // Score HUD
            VStack {
                HStack(spacing: 12) {
                    // Score pill
                    HStack(spacing: 6) {
                        Image(systemName: "diamond.fill")
                            .font(.caption2)
                            .foregroundStyle(.purple.opacity(0.8))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("SCORE")
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                            Text("\(displayedScore)")
                                .font(.subheadline.bold().monospacedDigit())
                                .foregroundStyle(.primary)
                                .contentTransition(.numericText(value: Double(displayedScore)))
                        }
                    }
                    .floatingBar()

                    Spacer()

                    // Best pill
                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange.opacity(0.8))
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("BEST")
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                            Text("\(viewModel.highScore)")
                                .font(.subheadline.bold().monospacedDigit())
                                .foregroundStyle(.purple)
                                .contentTransition(.numericText(value: Double(viewModel.highScore)))
                        }
                    }
                    .floatingBar()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()
            }

            // Game over overlay
            if showGameOver {
                gameOverOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .onChange(of: viewModel.score) { oldValue, newValue in
            withAnimation(.snappy(duration: 0.3)) {
                displayedScore = newValue
            }
            if newValue > oldValue {
                Haptics.tap()
            }
        }
        .onChange(of: viewModel.isGameOver) { _, isOver in
            if isOver {
                isNewBest = viewModel.score > viewModel.highScore
                Haptics.error()
                withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                    showGameOver = true
                }
            } else {
                showGameOver = false
            }
        }
    }

    // MARK: - Game Over Overlay

    private var gameOverOverlay: some View {
        ZStack {
            // Dark blurred scrim
            Rectangle()
                .fill(.black.opacity(0.55))
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

            // Sparkle particles for new best
            if isNewBest {
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let time = timeline.date.timeIntervalSinceReferenceDate
                        for i in 0..<18 {
                            let seed = Double(i)
                            let x = size.width * (0.15 + 0.7 * fract(sin(seed * 127.1) * 311.7))
                            let baseY = size.height * (0.15 + 0.7 * fract(sin(seed * 269.5) * 183.3))
                            let y = baseY + sin(time * 1.8 + seed) * 12
                            let opacity = 0.3 + 0.5 * fract(sin(seed * 419.2 + time * 0.5) * 753.1)
                            let radius: CGFloat = 1.8 + 1.5 * CGFloat(fract(sin(seed * 213.1) * 531.7))
                            let hue = fract(sin(seed * 317.0) * 431.1)
                            let color = Color(hue: 0.7 + hue * 0.2, saturation: 0.6, brightness: 1.0)
                            context.opacity = opacity
                            context.fill(
                                Circle().path(in: CGRect(x: x - radius, y: y - radius,
                                                         width: radius * 2, height: radius * 2)),
                                with: .color(color)
                            )
                        }
                    }
                }
                .allowsHitTesting(false)
                .ignoresSafeArea()
            }

            // Card
            VStack(spacing: 24) {
                // Title
                VStack(spacing: 6) {
                    Text("Game Over")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    if isNewBest {
                        Text("New Best!")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.yellow)
                            .shadow(color: .yellow.opacity(0.4), radius: 8, x: 0, y: 0)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                // Stat cards
                HStack(spacing: 12) {
                    statCard(title: "SCORE", value: "\(viewModel.score)",
                             icon: "diamond.fill", accent: .purple)
                    statCard(title: "BEST", value: "\(viewModel.highScore)",
                             icon: "trophy.fill", accent: .orange)
                }

                // Play Again button
                Button {
                    playAgainPressed = true
                    Haptics.impact(.medium)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        playAgainPressed = false
                        withAnimation(.spring(duration: 0.3)) {
                            showGameOver = false
                        }
                        viewModel.restart()
                    }
                } label: {
                    Text("Play Again")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [Color.purple, Color.purple.opacity(0.7)],
                                           startPoint: .leading, endPoint: .trailing),
                            in: Capsule()
                        )
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.15), lineWidth: 0.5)
                        )
                }
                .scaleEffect(playAgainPressed ? 0.93 : 1.0)
                .animation(.spring(duration: 0.2), value: playAgainPressed)
            }
            .padding(28)
            .frame(maxWidth: 300)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.1), lineWidth: 0.5)
                    )
            }
        }
    }

    // MARK: - Stat Card

    private func statCard(title: String, value: String, icon: String, accent: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(accent)

            Text(value)
                .font(.title2.bold().monospacedDigit())
                .foregroundStyle(.primary)

            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 0.5)
                )
        )
    }

    // MARK: - Helpers

    private func fract(_ x: Double) -> Double {
        x - floor(x)
    }
}
