import SwiftUI

struct AudioVisualizerView: View {
    @State private var levels: [CGFloat] = Array(repeating: 0.1, count: 32)
    @State private var timer: Timer?
    @State private var isAnimating = true

    private let barColors: [Color] = [
        .purple, .blue, .cyan, .green, .yellow, .orange, .red, .pink
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "waveform.path")
                    .foregroundStyle(.purple)
                    .font(.caption)
                Text("Visualizer")
                    .font(.subheadline.bold())
                Spacer()

                Button {
                    isAnimating.toggle()
                    if isAnimating { startAnimation() } else { stopAnimation() }
                } label: {
                    Image(systemName: isAnimating ? "pause.circle" : "play.circle")
                        .font(.title3)
                        .foregroundStyle(.purple)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)

            // Visualizer
            GeometryReader { geo in
                HStack(spacing: 2) {
                    ForEach(0..<levels.count, id: \.self) { index in
                        let colorIndex = index * barColors.count / levels.count
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        barColors[colorIndex % barColors.count],
                                        barColors[(colorIndex + 1) % barColors.count]
                                    ],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(
                                width: (geo.size.width - CGFloat(levels.count) * 2) / CGFloat(levels.count),
                                height: max(4, geo.size.height * levels[index])
                            )
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .background(Color.black)
        }
        .onAppear { startAnimation() }
        .onDisappear { stopAnimation() }
    }

    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.08)) {
                for i in 0..<levels.count {
                    // Simulate audio levels with smooth randomness
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
