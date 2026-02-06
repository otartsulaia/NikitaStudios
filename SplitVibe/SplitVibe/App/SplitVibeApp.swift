import SwiftUI
import SwiftData

@main
struct SplitVibeApp: App {
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [GameScore.self, FavoriteMode.self])
    }
}
