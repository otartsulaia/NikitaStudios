import SwiftUI

// MARK: - SoundCloud Player View

struct SoundCloudPlayerView: View {
    @State private var viewModel = SoundCloudViewModel()
    @State private var searchIconBounce = false

    var body: some View {
        VStack(spacing: 0) {
            // Glass search bar
            searchBar

            // Content
            if let trackURL = viewModel.currentTrackURL {
                SoundCloudWebView(trackURL: trackURL)
                    .id(trackURL)

                nowPlayingBar
            } else if viewModel.isSearching {
                ProgressView()
                    .tint(.orange)
                    .scaleEffect(1.1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
            } else if !viewModel.searchResults.isEmpty {
                searchResultsList
            } else {
                emptyState
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "cloud.fill")
                .foregroundStyle(.orange)
                .font(.subheadline)

            TextField("Search SoundCloud...", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
                .font(.subheadline)
                .submitLabel(.search)
                .onSubmit {
                    viewModel.search()
                }

            if !viewModel.searchQuery.isEmpty {
                Button {
                    viewModel.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.3))
                        .font(.subheadline)
                }
                .transition(.scale.combined(with: .opacity))
            }

            Button {
                withAnimation(.spring(duration: 0.2)) {
                    searchIconBounce = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    searchIconBounce = false
                }
                viewModel.search()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(7)
                    .background(.orange, in: Circle())
                    .scaleEffect(searchIconBounce ? 1.2 : 1.0)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThickMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.ultraThickMaterial)
    }

    // MARK: - Now Playing Bar

    private var nowPlayingBar: some View {
        VStack(spacing: 0) {
            // Orange gradient accent line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.orange, .orange.opacity(0.6), .red.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)

            HStack(spacing: 10) {
                Image(systemName: "waveform")
                    .foregroundStyle(.orange)
                    .font(.caption)
                    .symbolEffect(.variableColor.iterative, options: .repeating)

                Text(viewModel.currentTitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer()

                Button {
                    viewModel.clearTrack()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(.white.opacity(0.08))
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThickMaterial)
        }
    }

    // MARK: - Search Results

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.searchResults) { track in
                    SoundCloudResultRow(track: track) {
                        viewModel.play(track)
                    }
                }
            }
            .padding(10)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange.opacity(0.7), .orange.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(spacing: 6) {
                Text("Search SoundCloud")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("Discover tracks to listen while you vibe")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - SoundCloud Result Row

struct SoundCloudResultRow: View {
    let track: Track
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Play button circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                        )

                    Image(systemName: "play.fill")
                        .foregroundStyle(.white)
                        .font(.caption)
                }

                // Track info
                VStack(alignment: .leading, spacing: 3) {
                    Text(track.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(track.artist)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    if let duration = track.formattedDuration {
                        Text(duration)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer(minLength: 0)

                // Animated waveform
                Image(systemName: "waveform")
                    .foregroundStyle(.orange.opacity(0.5))
                    .font(.caption)
                    .symbolEffect(.variableColor.iterative, options: .repeating)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(.white.opacity(0.06), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
