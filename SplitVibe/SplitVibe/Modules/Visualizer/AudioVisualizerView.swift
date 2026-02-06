import SwiftUI

struct AudioVisualizerView: View {
    @State private var isAnimating = true

    private let barCount = 32
    private let spectrumColors: [Color] = [
        .purple, .indigo, .blue, .cyan, .mint, .green, .yellow, .orange, .red, .pink
    ]

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05, paused: !isAnimating)) { timeline in
            let time = timeline.date.timeIntervalSince1970

            ZStack(alignment: .bottom) {
                Color.black.ignoresSafeArea()

                GeometryReader { geo in
                    let spacing: CGFloat = 2.5
                    let barWidth = (geo.size.width - (CGFloat(barCount) - 1) * spacing - 16) / CGFloat(barCount)

                    ZStack {
                        // Reflected bars from top (lower opacity)
                        HStack(spacing: spacing) {
                            ForEach(0..<barCount, id: \.self) { index in
                                let barHeight = max(4, geo.size.height * 0.45 * level(for: index, at: time))
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
                            ForEach(0..<barCount, id: \.self) { index in
                                let barHeight = max(4, geo.size.height * 0.45 * level(for: index, at: time))
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(barGradient(for: index, flipped: false))
                                    .frame(width: barWidth, height: barHeight)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .shadow(color: spectrumColor(for: index).opacity(0.4), radius: 6, y: -2)
                                    .shadow(color: spectrumColor(for: index).opacity(0.15), radius: 14, y: -4)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }

                // Floating Glass Pill Play/Pause Button
                Button {
                    isAnimating.toggle()
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
        }
    }

    // MARK: - Level Computation

    private func level(for index: Int, at time: TimeInterval) -> CGFloat {
        let base = sin(Double(index) * 0.3 + time * 3) * 0.3 + 0.4
        let noise = sin(Double(index) * 7.3 + time * 11.7) * 0.15
        return max(0.05, min(1.0, CGFloat(base + noise)))
    }

    // MARK: - Gradient Helpers

    private func spectrumColor(for index: Int) -> Color {
        let fraction = CGFloat(index) / CGFloat(barCount - 1)
        let colorIndex = fraction * CGFloat(spectrumColors.count - 1)
        let lower = Int(colorIndex)
        return spectrumColors[min(lower, spectrumColors.count - 1)]
    }

    private func barGradient(for index: Int, flipped: Bool) -> LinearGradient {
        let fraction = CGFloat(index) / CGFloat(barCount - 1)
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
}
