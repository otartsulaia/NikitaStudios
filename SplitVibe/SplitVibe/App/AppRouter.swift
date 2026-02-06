import SwiftUI

@Observable
final class AppRouter {
    var selectedMode: SplitMode?
    var isShowingSettings = false

    func open(_ mode: SplitMode) {
        withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
            selectedMode = mode
        }
    }

    func goHome() {
        withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
            selectedMode = nil
        }
    }
}
