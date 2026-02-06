import Foundation

struct Track: Identifiable {
    let id = UUID()
    let trackId: String
    let title: String
    let artist: String
    let duration: Int? // seconds
    let permalinkURL: String

    var formattedDuration: String? {
        guard let duration else { return nil }
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    static func mockResults(for query: String) -> [Track] {
        [
            Track(trackId: "1", title: "\(query) - Original Mix", artist: "DJ Producer", duration: 215, permalinkURL: "https://soundcloud.com/search?q=\(query)"),
            Track(trackId: "2", title: "\(query) (Chill Remix)", artist: "Lo-Fi Beats", duration: 183, permalinkURL: "https://soundcloud.com/search?q=\(query)"),
            Track(trackId: "3", title: "Best \(query) Playlist", artist: "Music Curator", duration: 342, permalinkURL: "https://soundcloud.com/search?q=\(query)"),
            Track(trackId: "4", title: "\(query) - Bass Boosted", artist: "Bass Nation", duration: 198, permalinkURL: "https://soundcloud.com/search?q=\(query)"),
            Track(trackId: "5", title: "\(query) Acoustic Cover", artist: "Indie Artist", duration: 247, permalinkURL: "https://soundcloud.com/search?q=\(query)"),
        ]
    }
}
