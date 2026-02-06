import SwiftUI

@Observable
final class SoundCloudViewModel {
    var searchQuery = ""
    var searchResults: [Track] = []
    var currentTrackURL: String?
    var currentTitle = ""
    var isSearching = false

    private let apiService = SoundCloudAPIService()

    func search() {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        searchResults = []

        Task { @MainActor in
            do {
                searchResults = try await apiService.search(query: searchQuery)
            } catch {
                searchResults = Track.mockResults(for: searchQuery)
            }
            isSearching = false
        }
    }

    func play(_ track: Track) {
        currentTrackURL = track.permalinkURL
        currentTitle = "\(track.artist) - \(track.title)"
    }

    func clearTrack() {
        currentTrackURL = nil
        currentTitle = ""
    }
}
