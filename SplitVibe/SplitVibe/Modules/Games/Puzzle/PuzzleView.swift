import SwiftUI

struct PuzzleView: View {
    @State private var viewModel = PuzzleViewModel()

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("2048")
                        .font(.headline.bold())
                        .foregroundStyle(.primary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("SCORE")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.score)")
                        .font(.subheadline.bold().monospacedDigit())
                }

                VStack(alignment: .trailing, spacing: 2) {
                    Text("BEST")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.highScore)")
                        .font(.subheadline.bold().monospacedDigit())
                        .foregroundStyle(.orange)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Grid
            GeometryReader { geo in
                let gridSize = min(geo.size.width - 24, geo.size.height - 12)
                let tileSize = (gridSize - 15) / 4

                VStack(spacing: 3) {
                    ForEach(0..<4, id: \.self) { row in
                        HStack(spacing: 3) {
                            ForEach(0..<4, id: \.self) { col in
                                let value = viewModel.grid[row][col]
                                tileView(value: value, size: tileSize)
                            }
                        }
                    }
                }
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
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
                        }
                )
            }

            if viewModel.isGameOver {
                Button {
                    viewModel.restart()
                } label: {
                    Text("New Game")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(.orange, in: Capsule())
                }
                .padding(.bottom, 8)
            }
        }
        .background(Color(.systemBackground))
    }

    private func tileView(value: Int, size: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(colorForTile(value))

            if value > 0 {
                Text("\(value)")
                    .font(value >= 1000 ? .caption.bold() : .subheadline.bold())
                    .foregroundStyle(value <= 4 ? Color(.systemGray) : .white)
                    .minimumScaleFactor(0.5)
            }
        }
        .frame(width: size, height: size)
    }

    private func colorForTile(_ value: Int) -> Color {
        switch value {
        case 0: Color(.systemGray6)
        case 2: Color(red: 0.93, green: 0.89, blue: 0.85)
        case 4: Color(red: 0.93, green: 0.87, blue: 0.78)
        case 8: Color(red: 0.95, green: 0.69, blue: 0.47)
        case 16: Color(red: 0.96, green: 0.58, blue: 0.39)
        case 32: Color(red: 0.96, green: 0.49, blue: 0.37)
        case 64: Color(red: 0.96, green: 0.37, blue: 0.23)
        case 128: Color(red: 0.93, green: 0.81, blue: 0.45)
        case 256: Color(red: 0.93, green: 0.80, blue: 0.38)
        case 512: Color(red: 0.93, green: 0.78, blue: 0.31)
        case 1024: Color(red: 0.93, green: 0.77, blue: 0.25)
        case 2048: Color(red: 0.93, green: 0.76, blue: 0.18)
        default: Color(red: 0.23, green: 0.23, blue: 0.23)
        }
    }
}
