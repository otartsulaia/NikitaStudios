import SwiftUI

enum SplitMode: String, CaseIterable, Identifiable, Codable {
    case youtubeAndSoundCloud
    case youtubeAndBlockBlast
    case youtubeAndRunner
    case youtubeAndNotes
    case youtubeAndBrowser
    case soundCloudAndPuzzle
    case youtubeAndTimer
    case youtubeAndDrawing
    case dualYouTube
    case soundCloudAndVisualizer
    case youtubeAndTrivia

    var id: String { rawValue }

    var title: String {
        switch self {
        case .youtubeAndSoundCloud: "YouTube + SoundCloud"
        case .youtubeAndBlockBlast: "YouTube + Block Blast"
        case .youtubeAndRunner: "YouTube + Runner"
        case .youtubeAndNotes: "YouTube + Notes"
        case .youtubeAndBrowser: "YouTube + Browser"
        case .soundCloudAndPuzzle: "SoundCloud + Puzzle"
        case .youtubeAndTimer: "YouTube + Timer"
        case .youtubeAndDrawing: "YouTube + Drawing"
        case .dualYouTube: "Dual YouTube"
        case .soundCloudAndVisualizer: "SoundCloud + Visualizer"
        case .youtubeAndTrivia: "YouTube + Trivia"
        }
    }

    var subtitle: String {
        switch self {
        case .youtubeAndSoundCloud: "Watch & listen separately"
        case .youtubeAndBlockBlast: "Watch & play blocks"
        case .youtubeAndRunner: "Watch & run"
        case .youtubeAndNotes: "Watch & take notes"
        case .youtubeAndBrowser: "Watch & browse"
        case .soundCloudAndPuzzle: "Listen & solve"
        case .youtubeAndTimer: "Watch & focus"
        case .youtubeAndDrawing: "Watch & sketch"
        case .dualYouTube: "Two videos at once"
        case .soundCloudAndVisualizer: "Listen & visualize"
        case .youtubeAndTrivia: "Watch & quiz"
        }
    }

    var topIcon: String {
        switch self {
        case .dualYouTube: "play.rectangle.fill"
        case .soundCloudAndPuzzle, .soundCloudAndVisualizer: "cloud.fill"
        default: "play.rectangle.fill"
        }
    }

    var bottomIcon: String {
        switch self {
        case .youtubeAndSoundCloud: "cloud.fill"
        case .youtubeAndBlockBlast: "square.grid.3x3.fill"
        case .youtubeAndRunner: "figure.run"
        case .youtubeAndNotes: "note.text"
        case .youtubeAndBrowser: "globe"
        case .soundCloudAndPuzzle: "puzzlepiece.fill"
        case .youtubeAndTimer: "timer"
        case .youtubeAndDrawing: "paintbrush.fill"
        case .dualYouTube: "play.rectangle.fill"
        case .soundCloudAndVisualizer: "waveform.path"
        case .youtubeAndTrivia: "questionmark.circle.fill"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .youtubeAndSoundCloud: [.red, .orange]
        case .youtubeAndBlockBlast: [.red, .purple]
        case .youtubeAndRunner: [.red, .green]
        case .youtubeAndNotes: [.red, .yellow]
        case .youtubeAndBrowser: [.red, .blue]
        case .soundCloudAndPuzzle: [.orange, .mint]
        case .youtubeAndTimer: [.red, .indigo]
        case .youtubeAndDrawing: [.red, .pink]
        case .dualYouTube: [.red, .red.opacity(0.6)]
        case .soundCloudAndVisualizer: [.orange, .purple]
        case .youtubeAndTrivia: [.red, .cyan]
        }
    }

    var topPanel: PanelType {
        switch self {
        case .soundCloudAndPuzzle, .soundCloudAndVisualizer: .soundCloud
        default: .youtube
        }
    }

    var bottomPanel: PanelType {
        switch self {
        case .youtubeAndSoundCloud: .soundCloud
        case .youtubeAndBlockBlast: .blockBlast
        case .youtubeAndRunner: .endlessRunner
        case .youtubeAndNotes: .notes
        case .youtubeAndBrowser: .browser
        case .soundCloudAndPuzzle: .puzzle
        case .youtubeAndTimer: .timer
        case .youtubeAndDrawing: .drawing
        case .dualYouTube: .youtube
        case .soundCloudAndVisualizer: .visualizer
        case .youtubeAndTrivia: .trivia
        }
    }
}

enum PanelType {
    case youtube
    case soundCloud
    case blockBlast
    case endlessRunner
    case notes
    case browser
    case puzzle
    case timer
    case drawing
    case visualizer
    case trivia
}
