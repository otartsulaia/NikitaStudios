import SwiftUI
import WebKit

// MARK: - Shimmer Modifier

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.08),
                        .white.opacity(0.15),
                        .white.opacity(0.08),
                        .clear,
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.4)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 200
                    }
                }
            )
            .clipped()
    }
}

private extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - YouTube Player View

struct YouTubePlayerView: View {
    @State private var viewModel = YouTubeViewModel()
    @State private var searchIconBounce = false

    var body: some View {
        VStack(spacing: 0) {
            // Glass search bar
            searchBar

            // Content
            if let videoId = viewModel.currentVideoId {
                YouTubeWebView(videoId: videoId)
                    .id(videoId)

                nowPlayingBar
            } else if viewModel.isSearching {
                ProgressView()
                    .tint(.red)
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
            Image(systemName: "play.rectangle.fill")
                .foregroundStyle(.red)
                .font(.subheadline)

            TextField("Search YouTube...", text: $viewModel.searchQuery)
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
                    .background(.red, in: Circle())
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
            // Gradient accent line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.red, .red.opacity(0.6), .orange.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)

            HStack(spacing: 10) {
                Image(systemName: "waveform")
                    .foregroundStyle(.red)
                    .font(.caption)
                    .symbolEffect(.variableColor.iterative, options: .repeating)

                Text(viewModel.currentTitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer()

                Button {
                    viewModel.clearVideo()
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
                ForEach(viewModel.searchResults) { video in
                    YouTubeResultRow(video: video) {
                        viewModel.play(video)
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
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red.opacity(0.7), .red.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(spacing: 6) {
                Text("Search YouTube")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("Find videos to watch while you vibe")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Search Result Row

struct YouTubeResultRow: View {
    let video: Video
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Thumbnail
                AsyncImage(url: video.thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(16 / 9, contentMode: .fill)
                    default:
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.red.opacity(0.15),
                                        Color.gray.opacity(0.1),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay {
                                Image(systemName: "play.fill")
                                    .foregroundStyle(.white.opacity(0.3))
                                    .font(.caption)
                            }
                            .shimmer()
                    }
                }
                .frame(width: 120, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(video.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(video.channelTitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(8)
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
