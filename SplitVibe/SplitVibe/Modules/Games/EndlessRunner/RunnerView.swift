import SwiftUI
import SpriteKit

struct RunnerView: View {
    @State private var viewModel = RunnerViewModel()
    @State private var showGameOver = false
    @State private var runAgainPressed = false
    @State private var previousCoins: Int = 0

    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.scene, options: [.allowsTransparency])
                .ignoresSafeArea()
                .background(Color(.systemBackground))

            // HUD
            VStack {
                HStack(spacing: 10) {
                    // Distance pill
                    HStack(spacing: 5) {
                        Image(systemName: "figure.run")
                            .font(.caption2)
                            .foregroundStyle(.green.opacity(0.9))
                        Text("\(viewModel.score)")
                            .font(.subheadline.bold().monospacedDigit())
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText(value: Double(viewModel.score)))
                    }
                    .floatingBar()

                    // Coins pill
                    HStack(spacing: 5) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow.opacity(0.9))
                        Text("\(viewModel.coins)")
                            .font(.subheadline.bold().monospacedDigit())
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText(value: Double(viewModel.coins)))
                    }
                    .floatingBar()

                    Spacer()

                    // Best pill
                    HStack(spacing: 5) {
                        Image(systemName: "trophy.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange.opacity(0.8))
                        Text("\(viewModel.highScore)")
                            .font(.caption.bold().monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    .floatingBar()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()
            }

            // Game over
            if showGameOver {
                gameOverOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .onChange(of: viewModel.coins) { oldValue, newValue in
            if newValue > oldValue {
                Haptics.tap()
            }
        }
        .onChange(of: viewModel.isGameOver) { _, isOver in
            if isOver {
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

            VStack(spacing: 0) {
                // Gradient accent top line
                LinearGradient(
                    colors: [.red, .orange, .yellow],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 3)
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 24, topTrailingRadius: 24))

                VStack(spacing: 24) {
                    // Title
                    Text("Crashed!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.red)

                    // Stat boxes
                    HStack(spacing: 12) {
                        // Distance
                        VStack(spacing: 8) {
                            Image(systemName: "road.lanes")
                                .font(.title3)
                                .foregroundStyle(.green)
                            Text("\(viewModel.score)")
                                .font(.title2.bold().monospacedDigit())
                                .foregroundStyle(.primary)
                            Text("DISTANCE")
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

                        // Coins
                        VStack(spacing: 8) {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.yellow)
                            Text("\(viewModel.coins)")
                                .font(.title2.bold().monospacedDigit())
                                .foregroundStyle(.primary)
                            Text("COINS")
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

                    // Run Again button
                    Button {
                        runAgainPressed = true
                        Haptics.impact(.medium)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            runAgainPressed = false
                            withAnimation(.spring(duration: 0.3)) {
                                showGameOver = false
                            }
                            viewModel.restart()
                        }
                    } label: {
                        Text("Run Again")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(colors: [.green, .green.opacity(0.7)],
                                               startPoint: .leading, endPoint: .trailing),
                                in: Capsule()
                            )
                            .overlay(
                                Capsule()
                                    .stroke(.white.opacity(0.15), lineWidth: 0.5)
                            )
                    }
                    .scaleEffect(runAgainPressed ? 0.93 : 1.0)
                    .animation(.spring(duration: 0.2), value: runAgainPressed)
                }
                .padding(28)
            }
            .frame(maxWidth: 300)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.1), lineWidth: 0.5)
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }
}
