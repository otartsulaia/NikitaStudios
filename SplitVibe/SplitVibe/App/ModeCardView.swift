import SwiftUI
import SwiftData

struct ModeCardView: View {
    let mode: SplitMode
    let isFavorite: Bool
    @Environment(\.modelContext) private var modelContext
    @State private var shimmerPhase: CGFloat = 0

    var body: some View {
        VStack(spacing: 12) {
            // Animated icon pair with shimmer
            HStack(spacing: 16) {
                Image(systemName: mode.topIcon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse, options: .repeating.speed(0.3))

                Image(systemName: "plus")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.5))

                Image(systemName: mode.bottomIcon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse, options: .repeating.speed(0.3))
            }
            .overlay(
                // Shimmer sweep
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.25),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 50)
                .offset(x: shimmerPhase)
                .blendMode(.overlay)
                .mask(
                    HStack(spacing: 16) {
                        Image(systemName: mode.topIcon).font(.title2)
                        Image(systemName: "plus").font(.caption.bold())
                        Image(systemName: mode.bottomIcon).font(.title2)
                    }
                )
            )
            .clipped()

            // Title
            Text(mode.title)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // Subtitle
            Text(mode.subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: mode.gradientColors.first ?? .purple, location: 0.0),
                            .init(
                                color: mode.gradientColors.count > 1
                                    ? mode.gradientColors[0].mix(with: mode.gradientColors[1], by: 0.5)
                                    : mode.gradientColors.first ?? .purple,
                                location: 0.5
                            ),
                            .init(color: mode.gradientColors.last ?? .pink, location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        // Glass overlay with border
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.15), lineWidth: 0.5)
        )
        // Inner shadow illusion (dark inset at top)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.1), .clear, .black.opacity(0.15)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .allowsHitTesting(false)
        )
        .overlay(alignment: .topTrailing) {
            favoriteButton
        }
        // Smooth colored shadow
        .shadow(color: (mode.gradientColors.first ?? .clear).opacity(0.35), radius: 10, y: 5)
        .shadow(color: (mode.gradientColors.first ?? .clear).opacity(0.15), radius: 20, y: 10)
        // Scale animation via button style
        .buttonStyle(.plain)
        .scaleEffect(1.0) // initial; press handled by parent
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.5)
                .repeatForever(autoreverses: true)
            ) {
                shimmerPhase = 60
            }
        }
    }

    // MARK: - Favorite Button

    private var favoriteButton: some View {
        Button {
            Haptics.selection()
            withAnimation(.spring(duration: 0.35, bounce: 0.4)) {
                toggleFavorite()
            }
        } label: {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.caption)
                .foregroundStyle(isFavorite ? .yellow : .white.opacity(0.7))
                .padding(10)
                .contentTransition(.symbolEffect(.replace))
        }
    }

    // MARK: - Toggle Favorite

    private func toggleFavorite() {
        if isFavorite {
            let modeId = mode.rawValue
            let descriptor = FetchDescriptor<FavoriteMode>(
                predicate: #Predicate { $0.modeId == modeId }
            )
            if let existing = try? modelContext.fetch(descriptor).first {
                modelContext.delete(existing)
            }
        } else {
            let fav = FavoriteMode(modeId: mode.rawValue)
            modelContext.insert(fav)
        }
    }
}

// MARK: - Pressable Card Button Style

struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(duration: 0.25, bounce: 0.3), value: configuration.isPressed)
    }
}

extension Color {
    /// Blend two colors together. `fraction` 0 = self, 1 = other.
    func mix(with other: Color, by fraction: Double) -> Color {
        let f = min(max(fraction, 0), 1)
        let resolved1 = UIColor(self)
        let resolved2 = UIColor(other)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        resolved1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        resolved2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red: r1 + (r2 - r1) * f,
            green: g1 + (g2 - g1) * f,
            blue: b1 + (b2 - b1) * f,
            opacity: a1 + (a2 - a1) * f
        )
    }
}
