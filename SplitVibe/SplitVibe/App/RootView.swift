import SwiftUI

struct RootView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            if let mode = router.selectedMode {
                SplitScreenContainer(mode: mode)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                HomeView()
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.4, bounce: 0.2), value: router.selectedMode)
    }
}
