import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @Query private var favorites: [FavoriteMode]
    @State private var searchText = ""

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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Hero header
                    headerView

                    // Favorites section
                    if !favoriteModes.isEmpty && searchText.isEmpty {
                        sectionHeader("Favorites", icon: "star.fill")
                        modeGrid(favoriteModes)
                    }

                    // All modes
                    sectionHeader(
                        searchText.isEmpty ? "All Modes" : "Results",
                        icon: "square.grid.2x2.fill"
                    )
                    modeGrid(filteredModes)

                    if filteredModes.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                            .padding(.top, 40)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .background(Color(.systemBackground))
            .searchable(text: $searchText, prompt: "Search modes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        router.isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .symbolRenderingMode(.hierarchical)
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
        VStack(alignment: .leading, spacing: 8) {
            Text("SplitVibe")
                .font(.largeTitle.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Two things at once. One screen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .foregroundStyle(.primary)
    }

    // MARK: - Grid

    private func modeGrid(_ modes: [SplitMode]) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(modes) { mode in
                ModeCardView(mode: mode, isFavorite: favoriteModeIds.contains(mode.rawValue))
                    .onTapGesture {
                        router.open(mode)
                    }
            }
        }
    }
}
