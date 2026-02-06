import SwiftUI

@Observable
final class YouTubeViewModel {
    var searchQuery = ""
    var searchResults: [Video] = []
    var currentVideoId: String?
    var currentTitle = ""
    var isSearching = false

    private let apiService = YouTubeAPIService()

    func search() {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        searchResults = []

        Task { @MainActor in
            do {
                searchResults = try await apiService.search(query: searchQuery)
            } catch {
                // Fallback: generate mock results for demo
                searchResults = Video.mockResults(for: searchQuery)
            }
            isSearching = false
        }
    }

    func play(_ video: Video) {
        currentVideoId = video.videoId
        currentTitle = video.title
    }

    func clearVideo() {
        currentVideoId = nil
        currentTitle = ""
    }
}
