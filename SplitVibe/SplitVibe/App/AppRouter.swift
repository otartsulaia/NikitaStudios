import SwiftUI

@Observable
final class AppRouter {
    var selectedMode: SplitMode?
    var isShowingSettings = false

    func open(_ mode: SplitMode) {
        Haptics.impact(.medium)
        withAnimation(.spring(duration: 0.55, bounce: 0.2)) {
            selectedMode = mode
        }
    }

    func goHome() {
        Haptics.tap()
        withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
            selectedMode = nil
        }
    }
}
