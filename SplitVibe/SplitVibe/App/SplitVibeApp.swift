import SwiftUI
import SwiftData

@main
struct SplitVibeApp: App {
    @State private var router = AppRouter()

    init() {
        AudioSessionManager.shared.configureForMixedPlayback()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [GameScore.self, FavoriteMode.self])
    }
}
