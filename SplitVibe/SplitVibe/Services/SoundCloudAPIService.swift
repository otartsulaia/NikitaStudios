import Foundation

actor SoundCloudAPIService {
    // SoundCloud API client ID for searching tracks.
    // Register your app at: https://developers.soundcloud.com/
    private let clientId = "" // TODO: Add your SoundCloud client ID

    func search(query: String, limit: Int = 10) async throws -> [Track] {
        guard !clientId.isEmpty else {
            return Track.mockResults(for: query)
        }

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://api.soundcloud.com/tracks?q=\(encodedQuery)&limit=\(limit)&client_id=\(clientId)"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let items = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []

        return items.compactMap { item -> Track? in
            guard let id = item["id"] as? Int,
                  let title = item["title"] as? String else {
                return nil
            }

            let artist = (item["user"] as? [String: Any])?["username"] as? String ?? "Unknown"
            let duration = (item["duration"] as? Int).map { $0 / 1000 }
            let permalink = item["permalink_url"] as? String ?? ""

            return Track(trackId: String(id), title: title, artist: artist, duration: duration, permalinkURL: permalink)
        }
    }
}
