import SwiftUI

struct AudioVisualizerView: View {
    @State private var levels: [CGFloat] = Array(repeating: 0.1, count: 32)
    @State private var timer: Timer?
    @State private var isAnimating = true

    private let spectrumColors: [Color] = [
        .purple, .indigo, .blue, .cyan, .mint, .green, .yellow, .orange, .red, .pink
    ]

    var body: some View {
        // MARK: - Full Bleed Visualization (no header bar)
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            // MARK: - Mirror Bars
            GeometryReader { geo in
                let barCount = CGFloat(levels.count)
                let spacing: CGFloat = 2.5
                let barWidth = (geo.size.width - (barCount - 1) * spacing - 16) / barCount

                ZStack {
                    // Reflected bars from top (lower opacity)
                    HStack(spacing: spacing) {
                        ForEach(0..<levels.count, id: \.self) { index in
                            let barHeight = max(4, geo.size.height * 0.45 * levels[index])
                            RoundedRectangle(cornerRadius: 3)
                                .fill(barGradient(for: index, flipped: true))
                                .frame(width: barWidth, height: barHeight)
                                .frame(maxHeight: .infinity, alignment: .top)
                                .opacity(0.25)
                                .shadow(color: spectrumColor(for: index).opacity(0.2), radius: 4, y: 2)
                        }
                    }
                    .padding(.horizontal, 8)

                    // Primary bars from bottom
                    HStack(spacing: spacing) {
                        ForEach(0..<levels.count, id: \.self) { index in
                            let barHeight = max(4, geo.size.height * 0.45 * levels[index])
                            RoundedRectangle(cornerRadius: 3)
                                .fill(barGradient(for: index, flipped: false))
                                .frame(width: barWidth, height: barHeight)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                                // Subtle glow/bloom effect
                                .shadow(color: spectrumColor(for: index).opacity(0.4), radius: 6, y: -2)
                                .shadow(color: spectrumColor(for: index).opacity(0.15), radius: 14, y: -4)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }

            // MARK: - Floating Glass Pill Play/Pause Button
            Button {
                isAnimating.toggle()
                if isAnimating { startAnimation() } else { stopAnimation() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isAnimating ? "pause.fill" : "play.fill")
                        .font(.subheadline.weight(.semibold))
                        .contentTransition(.symbolEffect(.replace))

                    Text(isAnimating ? "Pause" : "Play")
                        .font(.caption.bold())
                }
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            .padding(.bottom, 16)
        }
        .onAppear { startAnimation() }
        .onDisappear { stopAnimation() }
    }

    // MARK: - Gradient Helpers

    private func spectrumColor(for index: Int) -> Color {
        let fraction = CGFloat(index) / CGFloat(levels.count - 1)
        let colorIndex = fraction * CGFloat(spectrumColors.count - 1)
        let lower = Int(colorIndex)
        let upper = min(lower + 1, spectrumColors.count - 1)
        return spectrumColors[lower]
    }

    private func barGradient(for index: Int, flipped: Bool) -> LinearGradient {
        let fraction = CGFloat(index) / CGFloat(levels.count - 1)
        let colorIndex = fraction * CGFloat(spectrumColors.count - 1)
        let lower = Int(colorIndex)
        let upper = min(lower + 1, spectrumColors.count - 1)

        let colors = [spectrumColors[lower], spectrumColors[upper]]
        return LinearGradient(
            colors: flipped ? colors.reversed() : colors,
            startPoint: flipped ? .top : .bottom,
            endPoint: flipped ? .bottom : .top
        )
    }

    // MARK: - Animation

    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.08)) {
                for i in 0..<levels.count {
                    let base = sin(Double(i) * 0.3 + Date().timeIntervalSince1970 * 3) * 0.3 + 0.4
                    let noise = CGFloat.random(in: -0.15...0.15)
                    levels[i] = max(0.05, min(1.0, CGFloat(base) + noise))
                }
            }
        }
    }

    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}
