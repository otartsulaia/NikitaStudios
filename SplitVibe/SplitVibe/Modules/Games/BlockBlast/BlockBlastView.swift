import SwiftUI
import SpriteKit

struct BlockBlastView: View {
    @State private var viewModel = BlockBlastViewModel()

    var body: some View {
        ZStack {
            // Game scene
            SpriteView(scene: viewModel.scene, options: [.allowsTransparency])
                .ignoresSafeArea()
                .background(Color(.systemBackground))

            // Score overlay
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SCORE")
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                        Text("\(viewModel.score)")
                            .font(.title3.bold().monospacedDigit())
                            .foregroundStyle(.primary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("BEST")
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                        Text("\(viewModel.highScore)")
                            .font(.title3.bold().monospacedDigit())
                            .foregroundStyle(.purple)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()
            }

            // Game over overlay
            if viewModel.isGameOver {
                gameOverOverlay
            }
        }
    }

    private var gameOverOverlay: some View {
        VStack(spacing: 16) {
            Text("Game Over")
                .font(.title.bold())
                .foregroundStyle(.primary)

            Text("Score: \(viewModel.score)")
                .font(.title3.monospacedDigit())
                .foregroundStyle(.secondary)

            Button {
                viewModel.restart()
            } label: {
                Text("Play Again")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(.purple, in: Capsule())
            }
        }
        .padding(32)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
