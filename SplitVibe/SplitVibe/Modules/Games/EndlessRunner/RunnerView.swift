import SwiftUI
import SpriteKit

struct RunnerView: View {
    @State private var viewModel = RunnerViewModel()

    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.scene, options: [.allowsTransparency])
                .ignoresSafeArea()
                .background(Color(.systemBackground))

            // HUD
            VStack {
                HStack {
                    // Score
                    HStack(spacing: 4) {
                        Image(systemName: "figure.run")
                            .font(.caption)
                            .foregroundStyle(.green)
                        Text("\(viewModel.score)")
                            .font(.headline.bold().monospacedDigit())
                            .foregroundStyle(.primary)
                    }

                    Spacer()

                    // Coins
                    HStack(spacing: 4) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                        Text("\(viewModel.coins)")
                            .font(.headline.bold().monospacedDigit())
                            .foregroundStyle(.primary)
                    }

                    Spacer()

                    // Best
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text("\(viewModel.highScore)")
                            .font(.caption.bold().monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()
            }

            // Game over
            if viewModel.isGameOver {
                VStack(spacing: 16) {
                    Text("Crashed!")
                        .font(.title.bold())
                        .foregroundStyle(.primary)

                    HStack(spacing: 24) {
                        VStack {
                            Text("\(viewModel.score)")
                                .font(.title2.bold().monospacedDigit())
                            Text("Distance")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        VStack {
                            Text("\(viewModel.coins)")
                                .font(.title2.bold().monospacedDigit())
                                .foregroundStyle(.yellow)
                            Text("Coins")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button {
                        viewModel.restart()
                    } label: {
                        Text("Run Again")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(.green, in: Capsule())
                    }
                }
                .padding(32)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
        }
    }
}
