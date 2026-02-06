import SwiftUI

struct PanelView: View {
    let type: PanelType

    var body: some View {
        switch type {
        case .youtube:
            YouTubePlayerView()
        case .soundCloud:
            SoundCloudPlayerView()
        case .blockBlast:
            BlockBlastView()
        case .endlessRunner:
            RunnerView()
        case .notes:
            NotesView()
        case .browser:
            WebBrowserView()
        case .puzzle:
            PuzzleView()
        case .timer:
            PomodoroTimerView()
        case .drawing:
            DrawingCanvasView()
        case .visualizer:
            AudioVisualizerView()
        case .trivia:
            TriviaView()
        }
    }
}
