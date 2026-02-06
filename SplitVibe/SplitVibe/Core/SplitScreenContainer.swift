import SwiftUI

struct SplitScreenContainer: View {
    let mode: SplitMode
    @Environment(AppRouter.self) private var router
    @State private var splitRatio: CGFloat = 0.45
    @State private var isDragging = false
    @GestureState private var dragOffset: CGFloat = 0

    private let minRatio: CGFloat = 0.25
    private let maxRatio: CGFloat = 0.75
    private let dividerHeight: CGFloat = 28

    var body: some View {
        GeometryReader { geo in
            let totalHeight = geo.size.height
            let dividerY = totalHeight * splitRatio

            VStack(spacing: 0) {
                // Top panel
                topPanelView
                    .frame(height: dividerY - dividerHeight / 2)
                    .clipped()

                // Draggable divider
                dividerView
                    .frame(height: dividerHeight)
                    .gesture(
                        DragGesture(minimumDistance: 1)
                            .onChanged { value in
                                isDragging = true
                                let newRatio = (dividerY + value.translation.height) / totalHeight
                                splitRatio = min(maxRatio, max(minRatio, newRatio))
                            }
                            .onEnded { _ in
                                isDragging = false
                                snapToNearestPreset()
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(duration: 0.3)) {
                            splitRatio = 0.5
                        }
                    }

                // Bottom panel
                bottomPanelView
                    .frame(height: totalHeight - dividerY - dividerHeight / 2)
                    .clipped()
            }
        }
        .ignoresSafeArea(.keyboard)
        .overlay(alignment: .topLeading) {
            backButton
        }
        .statusBarHidden(false)
    }

    // MARK: - Panels

    @ViewBuilder
    private var topPanelView: some View {
        PanelView(type: mode.topPanel)
    }

    @ViewBuilder
    private var bottomPanelView: some View {
        PanelView(type: mode.bottomPanel)
    }

    // MARK: - Divider

    private var dividerView: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            Capsule()
                .fill(Color.white.opacity(isDragging ? 0.9 : 0.5))
                .frame(width: 48, height: 5)

            HStack {
                Spacer()
                Text(ratioText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 12)
                    .opacity(isDragging ? 1 : 0)
            }
        }
        .contentShape(Rectangle())
    }

    private var ratioText: String {
        let top = Int(splitRatio * 100)
        let bottom = 100 - top
        return "\(top)/\(bottom)"
    }

    // MARK: - Back Button

    private var backButton: some View {
        Button {
            router.goHome()
        } label: {
            Image(systemName: "chevron.left.circle.fill")
                .font(.title)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)
                .padding(12)
        }
        .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
    }

    // MARK: - Snap

    private func snapToNearestPreset() {
        let presets: [CGFloat] = [0.3, 0.45, 0.5, 0.55, 0.7]
        let closest = presets.min(by: { abs($0 - splitRatio) < abs($1 - splitRatio) }) ?? 0.5
        if abs(closest - splitRatio) < 0.04 {
            withAnimation(.spring(duration: 0.25)) {
                splitRatio = closest
            }
        }
    }
}
