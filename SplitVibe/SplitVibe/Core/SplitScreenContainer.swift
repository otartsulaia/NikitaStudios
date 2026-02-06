import SwiftUI

struct SplitScreenContainer: View {
    let mode: SplitMode
    @Environment(AppRouter.self) private var router
    @State private var splitRatio: CGFloat = 0.45
    @State private var isDragging = false
    @State private var showRatioLabel = false
    @State private var handlePulse = false
    @GestureState private var dragOffset: CGFloat = 0

    private let minRatio: CGFloat = 0.25
    private let maxRatio: CGFloat = 0.75
    private let dividerHeight: CGFloat = 32
    private let innerCornerRadius: CGFloat = 14

    var body: some View {
        GeometryReader { geo in
            let totalHeight = geo.size.height
            let dividerY = totalHeight * splitRatio

            VStack(spacing: 0) {
                // Top panel
                topPanelView
                    .frame(height: dividerY - dividerHeight / 2)
                    .clipShape(
                        UnevenRoundedRectangle(
                            bottomLeadingRadius: innerCornerRadius,
                            bottomTrailingRadius: innerCornerRadius
                        )
                    )

                // Draggable divider
                dividerView
                    .frame(height: dividerHeight)
                    .gesture(
                        DragGesture(minimumDistance: 1)
                            .onChanged { value in
                                if !isDragging {
                                    isDragging = true
                                    withAnimation(.easeIn(duration: 0.15)) {
                                        showRatioLabel = true
                                    }
                                }
                                let newRatio = (dividerY + value.translation.height) / totalHeight
                                splitRatio = min(maxRatio, max(minRatio, newRatio))
                            }
                            .onEnded { _ in
                                isDragging = false
                                snapToNearestPreset()
                                withAnimation(.easeOut(duration: 0.35).delay(0.4)) {
                                    showRatioLabel = false
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(duration: 0.3)) {
                            splitRatio = 0.5
                        }
                        Haptics.selection()
                    }

                // Bottom panel
                bottomPanelView
                    .frame(height: totalHeight - dividerY - dividerHeight / 2)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: innerCornerRadius,
                            topTrailingRadius: innerCornerRadius
                        )
                    )
            }
        }
        .ignoresSafeArea(.keyboard)
        .overlay(alignment: .topLeading) {
            backButton
        }
        .statusBarHidden(false)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.6)
                .repeatForever(autoreverses: true)
            ) {
                handlePulse = true
            }
        }
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
            // Glass bar
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
                )

            // Glowing capsule handle
            Capsule()
                .fill(.white.opacity(isDragging ? 0.95 : 0.55))
                .frame(width: isDragging ? 56 : 48, height: 5)
                .shadow(
                    color: .white.opacity(isDragging ? 0.5 : handlePulse ? 0.25 : 0.08),
                    radius: isDragging ? 10 : 6
                )
                .animation(.spring(duration: 0.25), value: isDragging)

            // Ratio label pill
            HStack {
                Spacer()
                Text(ratioText)
                    .font(.caption2.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.12))
                            .overlay(
                                Capsule()
                                    .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
                            )
                    )
                    .padding(.trailing, 14)
                    .opacity(showRatioLabel ? 1 : 0)
                    .scaleEffect(showRatioLabel ? 1 : 0.8, anchor: .trailing)
                    .animation(.spring(duration: 0.25), value: showRatioLabel)
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
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.subheadline.weight(.semibold))

                Text(mode.title)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
            }
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
            .padding(12)
        }
    }

    // MARK: - Snap

    private func snapToNearestPreset() {
        let presets: [CGFloat] = [0.3, 0.45, 0.5, 0.55, 0.7]
        let closest = presets.min(by: { abs($0 - splitRatio) < abs($1 - splitRatio) }) ?? 0.5
        if abs(closest - splitRatio) < 0.04 {
            withAnimation(.spring(duration: 0.25)) {
                splitRatio = closest
            }
            Haptics.selection()
        }
    }
}
