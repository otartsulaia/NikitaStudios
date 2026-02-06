import SwiftUI

struct PuzzleView: View {
    @State private var viewModel = PuzzleViewModel()
    @State private var showGameOver = false
    @State private var newGamePressed = false

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack(spacing: 12) {
                Text("2048")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Spacer()

                // Score pill
                HStack(spacing: 6) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange.opacity(0.8))
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("SCORE")
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text("\(viewModel.score)")
                            .font(.subheadline.bold().monospacedDigit())
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText(value: Double(viewModel.score)))
                    }
                }
                .floatingBar()

                // Best pill
                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow.opacity(0.8))
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("BEST")
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text("\(viewModel.highScore)")
                            .font(.subheadline.bold().monospacedDigit())
                            .foregroundStyle(.orange)
                            .contentTransition(.numericText(value: Double(viewModel.highScore)))
                    }
                }
                .floatingBar()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Grid
            GeometryReader { geo in
                let gridSize = min(geo.size.width - 24, geo.size.height - 12)
                let spacing: CGFloat = 4
                let tileSize = (gridSize - spacing * 5) / 4

                VStack(spacing: spacing) {
                    ForEach(0..<4, id: \.self) { row in
                        HStack(spacing: spacing) {
                            ForEach(0..<4, id: \.self) { col in
                                let value = viewModel.grid[row][col]
                                tileView(value: value, size: tileSize)
                                    .animation(.spring(duration: 0.2, bounce: 0.15),
                                               value: value)
                            }
                        }
                    }
                }
                .padding(spacing)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(.white.opacity(0.06), lineWidth: 0.5)
                        )
                )
                .frame(width: gridSize, height: gridSize)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            let h = value.translation.width
                            let v = value.translation.height
                            if abs(h) > abs(v) {
                                viewModel.swipe(h > 0 ? .right : .left)
                            } else {
                                viewModel.swipe(v > 0 ? .down : .up)
                            }
                            Haptics.tap()
                        }
                )
            }

            // Bottom: New Game or Game Over
            if viewModel.isGameOver {
                Button {
                    newGamePressed = true
                    Haptics.impact(.medium)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        newGamePressed = false
                        viewModel.restart()
                    }
                } label: {
                    Text("New Game")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(colors: [.orange, .orange.opacity(0.7)],
                                           startPoint: .leading, endPoint: .trailing),
                            in: Capsule()
                        )
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.15), lineWidth: 0.5)
                        )
                }
                .scaleEffect(newGamePressed ? 0.93 : 1.0)
                .animation(.spring(duration: 0.2), value: newGamePressed)
                .padding(.bottom, 8)
            }
        }
        .background(Color(.systemBackground))
        .overlay {
            if showGameOver {
                gameOverOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
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

    // MARK: - Tile View

    private func tileView(value: Int, size: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(colorForTile(value))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.black.opacity(value == 0 ? 0 : 0.15), lineWidth: 0.5)
                )
                // Subtle inner shadow via inset overlay
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(value == 0 ? 0 : 0.1), lineWidth: 0.5)
                        .padding(0.5)
                )

            if value > 0 {
                Text("\(value)")
                    .font(fontForTile(value))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
                    .shadow(color: .black.opacity(0.25), radius: 1, x: 0, y: 1)
            }
        }
        .frame(width: size, height: size)
    }

    private func fontForTile(_ value: Int) -> Font {
        if value >= 1000 {
            .system(size: 14, weight: .bold, design: .rounded)
        } else if value >= 100 {
            .system(size: 17, weight: .bold, design: .rounded)
        } else {
            .system(size: 20, weight: .bold, design: .rounded)
        }
    }

    // MARK: - Premium Dark-Mode Tile Colors

    private func colorForTile(_ value: Int) -> Color {
        switch value {
        case 0:
            Color(.systemGray6).opacity(0.5)
        case 2:
            // Soft warm tone
            Color(red: 0.55, green: 0.45, blue: 0.35)
        case 4:
            // Slightly warmer
            Color(red: 0.62, green: 0.48, blue: 0.33)
        case 8:
            // Amber
            Color(red: 0.78, green: 0.55, blue: 0.22)
        case 16:
            // Deep amber / burnt orange
            Color(red: 0.82, green: 0.45, blue: 0.18)
        case 32:
            // Coral
            Color(red: 0.85, green: 0.35, blue: 0.28)
        case 64:
            // Ruby
            Color(red: 0.78, green: 0.22, blue: 0.25)
        case 128:
            // Gold
            Color(red: 0.80, green: 0.68, blue: 0.22)
        case 256:
            // Rich gold
            Color(red: 0.82, green: 0.65, blue: 0.15)
        case 512:
            // Warm gold
            Color(red: 0.75, green: 0.58, blue: 0.12)
        case 1024:
            // Deep gold
            Color(red: 0.70, green: 0.52, blue: 0.10)
        case 2048:
            // Emerald
            Color(red: 0.18, green: 0.68, blue: 0.45)
        default:
            // Ultra-high: deep jewel violet
            Color(red: 0.38, green: 0.18, blue: 0.58)
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

            VStack(spacing: 24) {
                Text("Game Over")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                // Stat cards
                HStack(spacing: 12) {
                    VStack(spacing: 8) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.title3)
                            .foregroundStyle(.orange)
                        Text("\(viewModel.score)")
                            .font(.title2.bold().monospacedDigit())
                            .foregroundStyle(.primary)
                        Text("SCORE")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
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

                    VStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(.title3)
                            .foregroundStyle(.yellow)
                        Text("\(viewModel.highScore)")
                            .font(.title2.bold().monospacedDigit())
                            .foregroundStyle(.primary)
                        Text("BEST")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
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

                // Play Again
                Button {
                    newGamePressed = true
                    Haptics.impact(.medium)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        newGamePressed = false
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
                            LinearGradient(colors: [.orange, .orange.opacity(0.7)],
                                           startPoint: .leading, endPoint: .trailing),
                            in: Capsule()
                        )
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.15), lineWidth: 0.5)
                        )
                }
                .scaleEffect(newGamePressed ? 0.93 : 1.0)
                .animation(.spring(duration: 0.2), value: newGamePressed)
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
}
