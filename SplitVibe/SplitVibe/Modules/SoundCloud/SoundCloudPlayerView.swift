import SwiftUI

struct SoundCloudPlayerView: View {
    @State private var viewModel = SoundCloudViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "cloud.fill")
                    .foregroundStyle(.orange)
                    .font(.caption)

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
                        .background(.orange, in: Circle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)

            // Content
            if let trackURL = viewModel.currentTrackURL {
                SoundCloudWebView(trackURL: trackURL)
                    .id(trackURL)

                HStack {
                    Text(viewModel.currentTitle)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Spacer()
                    Button {
                        viewModel.clearTrack()
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
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.searchResults) { track in
                            SoundCloudResultRow(track: track) {
                                viewModel.play(track)
                            }
                        }
                    }
                    .padding(8)
                }
                .background(Color(.systemBackground))
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange.opacity(0.5))
                    Text("Search for a SoundCloud track")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
    }
}

struct SoundCloudResultRow: View {
    let track: Track
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)

                    Image(systemName: "play.fill")
                        .foregroundStyle(.white)
                        .font(.caption)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.caption.bold())
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

                Spacer()

                Image(systemName: "waveform")
                    .foregroundStyle(.orange.opacity(0.5))
                    .font(.caption)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}
