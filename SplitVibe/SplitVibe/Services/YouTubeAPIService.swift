import Foundation

actor YouTubeAPIService {
    // To use the YouTube Data API, set your API key here.
    // Get one at: https://console.cloud.google.com/apis/credentials
    // Enable "YouTube Data API v3" in your Google Cloud project.
    private let apiKey = "" // TODO: Add your YouTube Data API key

    func search(query: String, maxResults: Int = 10) async throws -> [Video] {
        guard !apiKey.isEmpty else {
            // Return mock data when no API key is configured
            return Video.mockResults(for: query)
        }

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=\(maxResults)&q=\(encodedQuery)&key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let items = json?["items"] as? [[String: Any]] ?? []

        return items.compactMap { item -> Video? in
            guard let id = item["id"] as? [String: Any],
                  let videoId = id["videoId"] as? String,
                  let snippet = item["snippet"] as? [String: Any],
                  let title = snippet["title"] as? String else {
                return nil
            }

            let channelTitle = snippet["channelTitle"] as? String ?? ""
            let thumbnails = snippet["thumbnails"] as? [String: Any]
            let medium = thumbnails?["medium"] as? [String: Any]
            let thumbURL = (medium?["url"] as? String).flatMap { URL(string: $0) }

            return Video(videoId: videoId, title: title, channelTitle: channelTitle, thumbnailURL: thumbURL)
        }
    }
}
