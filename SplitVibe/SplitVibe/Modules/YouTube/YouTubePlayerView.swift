import SwiftUI
import WebKit

struct YouTubePlayerView: View {
    @State private var viewModel = YouTubeViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "play.rectangle.fill")
                    .foregroundStyle(.red)
                    .font(.caption)

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
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }

                Button {
                    viewModel.search()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(.red, in: Circle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)

            // Content
            if let videoId = viewModel.currentVideoId {
                YouTubeWebView(videoId: videoId)
                    .id(videoId)

                // Mini controls
                HStack {
                    Text(viewModel.currentTitle)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Spacer()
                    Button {
                        viewModel.clearVideo()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
            } else if viewModel.isSearching {
                ProgressView("Searching...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
            } else if !viewModel.searchResults.isEmpty {
                // Search results list
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.searchResults) { video in
                            YouTubeResultRow(video: video) {
                                viewModel.play(video)
                            }
                        }
                    }
                    .padding(8)
                }
                .background(Color(.systemBackground))
            } else {
                // Placeholder
                VStack(spacing: 12) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.red.opacity(0.5))
                    Text("Search for a YouTube video")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
    }
}

// MARK: - Search Result Row

struct YouTubeResultRow: View {
    let video: Video
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // Thumbnail
                AsyncImage(url: video.thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay {
                                Image(systemName: "play.fill")
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
                .frame(width: 120, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(video.title)
                        .font(.caption.bold())
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(video.channelTitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}
