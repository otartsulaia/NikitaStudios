import SwiftUI
import SpriteKit

@Observable
final class BlockBlastViewModel {
    var score = 0
    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: "blockBlastHighScore") }
        set { UserDefaults.standard.set(newValue, forKey: "blockBlastHighScore") }
    }
    var isGameOver = false

    let scene: BlockBlastScene

    init() {
        let scene = BlockBlastScene()
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        self.scene = scene

        scene.onScoreChanged = { [weak self] newScore in
            guard let self else { return }
            self.score = newScore
            if newScore > self.highScore {
                self.highScore = newScore
            }
        }

        scene.onGameOver = { [weak self] in
            self?.isGameOver = true
        }
    }

    func restart() {
        isGameOver = false
        score = 0
        scene.restart()
    }
}
