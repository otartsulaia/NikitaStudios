import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @Query private var favorites: [FavoriteMode]
    @State private var searchText = ""
    @State private var scrollOffset: CGFloat = 0

    // MARK: - Computed Properties

    private var filteredModes: [SplitMode] {
        if searchText.isEmpty {
            return SplitMode.allCases
        }
        return SplitMode.allCases.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var favoriteModeIds: Set<String> {
        Set(favorites.map(\.modeId))
    }

    private var favoriteModes: [SplitMode] {
        SplitMode.allCases.filter { favoriteModeIds.contains($0.rawValue) }
    }

    /// Featured modes shown in the horizontal carousel
    private var featuredModes: [SplitMode] {
        [.youtubeAndSoundCloud, .dualYouTube, .soundCloudAndVisualizer, .youtubeAndBlockBlast]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // Hero header with parallax
                    headerView
                        .offset(y: scrollOffset * 0.3)

                    // Featured / Popular horizontal carousel
                    if searchText.isEmpty {
                        featuredSection
                    }

                    // Favorites section
                    if !favoriteModes.isEmpty && searchText.isEmpty {
                        sectionHeader("Favorites", icon: "star.fill", tint: .yellow)
                        modeGrid(favoriteModes)
                    }

                    // All modes / search results
                    sectionHeader(
                        searchText.isEmpty ? "All Modes" : "Results",
                        icon: searchText.isEmpty ? "square.grid.2x2.fill" : "magnifyingglass",
                        tint: .purple
                    )

                    if filteredModes.isEmpty {
                        emptySearchView
                    } else {
                        modeGrid(filteredModes)
                    }
                }
                .padding(.bottom, 48)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: ScrollOffsetKey.self,
                                value: geo.frame(in: .named("scroll")).minY
                            )
                    }
                )
            }
            .contentMargins(.horizontal, 20, for: .scrollContent)
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                scrollOffset = value
            }
            .background(Color(.systemBackground))
            .searchable(text: $searchText, prompt: "Search modes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Haptics.tap()
                        router.isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.body.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: Bindable(router).isShowingSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                let phase = timeline.date.timeIntervalSinceReferenceDate

                Text("SplitVibe")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.purple,
                                Color.pink,
                                Color.orange,
                                Color.purple
                            ],
                            startPoint: UnitPoint(
                                x: 0.0 + cos(phase * 0.5) * 0.3,
                                y: 0.0
                            ),
                            endPoint: UnitPoint(
                                x: 1.0 + sin(phase * 0.5) * 0.3,
                                y: 1.0
                            )
                        )
                    )
            }

            Text("Two things at once. One screen.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 12)
    }

    // MARK: - Featured Section

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Popular", icon: "flame.fill", tint: .orange)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(featuredModes) { mode in
                        FeaturedCard(mode: mode)
                            .onTapGesture {
                                router.open(mode)
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, 0, for: .scrollContent)
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String, icon: String, tint: Color = .primary) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(tint)
                .symbolRenderingMode(.hierarchical)

            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
        }
        .padding(.top, 4)
    }

    // MARK: - Grid

    private func modeGrid(_ modes: [SplitMode]) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14)
            ],
            spacing: 14
        ) {
            ForEach(modes) { mode in
                ModeCardView(mode: mode, isFavorite: favoriteModeIds.contains(mode.rawValue))
                    .onTapGesture {
                        router.open(mode)
                    }
            }
        }
    }

    // MARK: - Empty Search

    private var emptySearchView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.tertiary)

            Text("No modes found")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Try searching for \"\(SplitMode.allCases.randomElement()?.title.components(separatedBy: " + ").last ?? "YouTube")\"")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Featured Card

private struct FeaturedCard: View {
    let mode: SplitMode

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: mode.topIcon)
                    .font(.title3)
                    .foregroundStyle(.white)

                Image(systemName: "plus")
                    .font(.caption2.bold())
                    .foregroundStyle(.white.opacity(0.5))

                Image(systemName: mode.bottomIcon)
                    .font(.title3)
                    .foregroundStyle(.white)
            }

            Text(mode.title)
                .font(.subheadline.bold())
                .foregroundStyle(.white)

            Text(mode.subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(16)
        .frame(width: 180, alignment: .leading)
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
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: mode.gradientColors.first?.opacity(0.35) ?? .clear, radius: 12, y: 6)
    }
}

// MARK: - Scroll Offset Preference Key

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
