import SwiftUI

struct RootView: View {
    @Environment(AppRouter.self) private var router
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Deep dark base
            Color.black.ignoresSafeArea()

            if let mode = router.selectedMode {
                SplitScreenContainer(mode: mode)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.92).combined(with: .opacity),
                            removal: .scale(scale: 1.06).combined(with: .opacity)
                        )
                    )
            } else {
                HomeView()
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 1.06).combined(with: .opacity),
                            removal: .scale(scale: 0.92).combined(with: .opacity)
                        )
                    )
                    .scaleEffect(appeared ? 1.0 : 0.96)
                    .opacity(appeared ? 1.0 : 0.0)
            }
        }
        .animation(.spring(duration: 0.55, bounce: 0.22), value: router.selectedMode)
        .onAppear {
            withAnimation(.spring(duration: 0.6, bounce: 0.15)) {
                appeared = true
            }
        }
    }
}
