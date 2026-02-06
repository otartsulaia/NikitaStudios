import Foundation

struct Video: Identifiable {
    let id = UUID()
    let videoId: String
    let title: String
    let channelTitle: String
    let thumbnailURL: URL?

    static func mockResults(for query: String) -> [Video] {
        [
            Video(videoId: "dQw4w9WgXcQ", title: "\(query) - Top Result", channelTitle: "Popular Channel", thumbnailURL: nil),
            Video(videoId: "kJQP7kiw5Fk", title: "\(query) Official Video", channelTitle: "Music Channel", thumbnailURL: nil),
            Video(videoId: "RgKAFK5djSk", title: "\(query) Remix 2025", channelTitle: "Remix Studio", thumbnailURL: nil),
            Video(videoId: "OPf0YbXqDm0", title: "Best of \(query)", channelTitle: "Compilation TV", thumbnailURL: nil),
            Video(videoId: "JGwWNGJdvx8", title: "\(query) - Live Performance", channelTitle: "Live Music", thumbnailURL: nil),
        ]
    }
}
