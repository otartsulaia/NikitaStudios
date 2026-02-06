import SwiftUI
import SwiftData

struct ModeCardView: View {
    let mode: SplitMode
    let isFavorite: Bool
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 12) {
            // Icon pair
            HStack(spacing: 16) {
                Image(systemName: mode.topIcon)
                    .font(.title2)
                    .foregroundStyle(.white)

                Image(systemName: "plus")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.6))

                Image(systemName: mode.bottomIcon)
                    .font(.title2)
                    .foregroundStyle(.white)
            }

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
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: mode.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(alignment: .topTrailing) {
            favoriteButton
        }
        .shadow(color: mode.gradientColors.first?.opacity(0.3) ?? .clear, radius: 8, y: 4)
    }

    private var favoriteButton: some View {
        Button {
            toggleFavorite()
        } label: {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
                .padding(8)
        }
    }

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
