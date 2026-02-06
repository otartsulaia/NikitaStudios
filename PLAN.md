# SplitVibe - Project Plan

## 1. App Concept

**SplitVibe** is an iOS app that provides a true split-screen multitasking experience. Users can combine media (YouTube, SoundCloud) with games or other activities in a single view. The screen is divided into two panels (top/bottom or left/right) that each run an independent module.

---

## 2. Core Split-Screen Modes

### Mode 1: YouTube + SoundCloud
- Top panel: YouTube video player (webview or YouTube IFrame API)
- Bottom panel: SoundCloud music player (SoundCloud widget/API)
- Use case: Watch a music video on mute while listening to a different track

### Mode 2: YouTube + Block Blast Game
- Top panel: YouTube video playing
- Bottom panel: A Tetris/block-puzzle style game (custom built, inspired by Block Blast)
- Use case: Watch content while casually gaming

### Mode 3: YouTube + Endless Runner Game
- Top panel: YouTube video playing
- Bottom panel: Subway Surfers-style endless runner game (custom built)
- Use case: Play a simple swipe game while catching up on videos

---

## 3. Additional Split-Screen Mode Ideas

### Mode 4: YouTube + Chat / Notes
- Watch a video while taking notes or chatting with friends
- Great for students watching lectures

### Mode 5: YouTube + Reddit / Social Feed
- Watch a video while scrolling a social feed
- Embedded web view for Reddit, Twitter/X, etc.

### Mode 6: SoundCloud + Puzzle Game
- Listen to music while playing a puzzle (Sudoku, crossword, 2048)
- Relaxation combo

### Mode 7: YouTube + Live Sports Scores
- Watch a video/stream while tracking live scores from another game
- Sports API integration

### Mode 8: YouTube + Pomodoro Timer / Study Mode
- Video or music on top, a focus timer + task list on the bottom
- Productivity-oriented split

### Mode 9: YouTube + Drawing Canvas
- Watch a tutorial on top, draw/sketch on the bottom
- Great for art tutorials

### Mode 10: Dual YouTube (Picture-in-Picture)
- Two YouTube videos side by side
- Compare videos, watch two streams at once

### Mode 11: SoundCloud + Visualizer
- Music plays on top, a real-time audio visualizer on the bottom
- Eye-candy mode

### Mode 12: YouTube + Trivia / Quiz Game
- Watch a video while answering trivia questions
- Could tie into the video topic for educational use

---

## 4. Technical Architecture

### Platform
- **iOS 16+** (Swift / SwiftUI)
- **Xcode 15+**

### Project Structure
```
SplitVibe/
├── App/
│   ├── SplitVibeApp.swift          # App entry point
│   └── ContentView.swift           # Root view with mode selection
├── Core/
│   ├── SplitScreenContainer.swift  # Generic split-screen layout manager
│   ├── PanelPosition.swift         # Enum: top/bottom, left/right
│   └── SplitRatio.swift            # Adjustable divider (50/50, 70/30, etc.)
├── Modules/
│   ├── YouTube/
│   │   ├── YouTubePlayerView.swift # WKWebView-based YouTube player
│   │   ├── YouTubeSearchView.swift # Search & browse videos
│   │   └── YouTubeViewModel.swift  # YouTube Data API integration
│   ├── SoundCloud/
│   │   ├── SoundCloudPlayerView.swift  # SoundCloud widget embed
│   │   ├── SoundCloudSearchView.swift  # Search tracks
│   │   └── SoundCloudViewModel.swift   # SoundCloud API integration
│   ├── Games/
│   │   ├── BlockBlast/
│   │   │   ├── BlockBlastView.swift       # SpriteKit game view
│   │   │   ├── BlockBlastScene.swift      # Game scene & logic
│   │   │   ├── BlockPiece.swift           # Piece models
│   │   │   └── BlockBlastViewModel.swift  # Score, state management
│   │   ├── EndlessRunner/
│   │   │   ├── RunnerView.swift           # SpriteKit game view
│   │   │   ├── RunnerScene.swift          # Game scene & logic
│   │   │   ├── PlayerCharacter.swift      # Player model
│   │   │   ├── ObstacleManager.swift      # Obstacle spawning
│   │   │   └── RunnerViewModel.swift      # Score, state management
│   │   └── Puzzle/
│   │       ├── PuzzleView.swift           # 2048 / Sudoku view
│   │       └── PuzzleViewModel.swift      # Game logic
│   ├── Utilities/
│   │   ├── NotesView.swift            # Simple note-taking panel
│   │   ├── TimerView.swift            # Pomodoro timer panel
│   │   ├── DrawingCanvasView.swift    # PencilKit drawing panel
│   │   └── WebBrowserView.swift       # Generic web view panel
│   └── Visualizer/
│       ├── AudioVisualizerView.swift  # Real-time audio bars
│       └── VisualizerRenderer.swift   # Metal/Core Animation rendering
├── Services/
│   ├── YouTubeAPIService.swift    # YouTube Data API v3 calls
│   ├── SoundCloudAPIService.swift # SoundCloud API calls
│   └── AudioSessionManager.swift  # AVAudioSession management
├── Models/
│   ├── Video.swift                # YouTube video model
│   ├── Track.swift                # SoundCloud track model
│   └── GameScore.swift            # Game score model
├── Resources/
│   ├── Assets.xcassets            # App icons, colors, images
│   └── Sounds/                    # Game sound effects
└── Info.plist
```

### Key Technologies
| Component | Technology |
|---|---|
| UI Framework | SwiftUI + UIKit interop |
| YouTube Playback | WKWebView + YouTube IFrame API |
| SoundCloud Playback | WKWebView + SoundCloud Widget API |
| Games | SpriteKit (2D games) |
| Audio Management | AVAudioSession (mixing audio sources) |
| Drawing | PencilKit |
| Visualizer | Core Animation / Metal |
| Networking | URLSession + async/await |
| State Management | SwiftUI @Observable / MVVM |
| Persistence | SwiftData (scores, favorites, history) |

### API Requirements
- **YouTube Data API v3** - Video search, metadata
- **SoundCloud API** - Track search, streaming widget
- No API key needed for embed/widget approach (webview-based)

---

## 5. Key Features

### Split-Screen Engine
- Draggable divider to resize panels (30/70, 50/50, 70/30)
- Horizontal or vertical split orientation
- Smooth animations when resizing
- Double-tap divider to reset to 50/50

### Mode Selector (Home Screen)
- Grid of mode cards showing available combinations
- Each card shows an icon preview of both panels
- Favorites / recently used at the top

### Media Controls
- Floating mini-controls for play/pause/skip
- Volume mixer — independent volume for each panel
- Background audio support

### Game Features
- **Block Blast**: Place blocks on a grid, clear rows/columns, score points
- **Endless Runner**: Swipe to dodge obstacles, collect coins, increasing speed
- **Puzzle**: 2048-style merge game or Sudoku
- One-handed friendly controls (bottom half of screen)

### Quality of Life
- Auto-pause video when switching modes
- Resume where you left off (persist state)
- Dark mode support
- Haptic feedback for games

---

## 6. Development Phases

### Phase 1: Foundation
- [ ] Xcode project setup (SwiftUI lifecycle)
- [ ] Split-screen container with draggable divider
- [ ] Mode selector home screen
- [ ] Basic YouTube player via WKWebView

### Phase 2: Media Integration
- [ ] YouTube search and browse
- [ ] SoundCloud player integration
- [ ] Audio session management (simultaneous playback)
- [ ] Floating media controls

### Phase 3: Games
- [ ] Block Blast game (SpriteKit)
- [ ] Endless Runner game (SpriteKit)
- [ ] Score tracking and persistence
- [ ] Game pause/resume when split-screen changes

### Phase 4: Extra Modules
- [ ] Notes panel
- [ ] Drawing canvas
- [ ] Pomodoro timer
- [ ] Web browser panel
- [ ] Audio visualizer

### Phase 5: Polish & Ship
- [ ] Animations and transitions
- [ ] Haptics
- [ ] App icon and launch screen
- [ ] Settings screen
- [ ] TestFlight beta
- [ ] App Store submission

---

## 7. Monetization Ideas

- **Free tier**: YouTube + one game mode, ads between sessions
- **Pro ($4.99/mo or $29.99/yr)**: All modes, no ads, custom themes
- **One-time unlock ($9.99)**: Lifetime access to all features

---

## 8. Design Principles

1. **Simplicity** - One tap to start a split-screen session
2. **Performance** - 60fps games even while streaming video
3. **Battery conscious** - Throttle frame rates when not in focus
4. **Accessibility** - VoiceOver support, dynamic type, high contrast
