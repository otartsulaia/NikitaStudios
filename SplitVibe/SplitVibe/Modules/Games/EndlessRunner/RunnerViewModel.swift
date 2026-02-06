import SwiftUI
import SpriteKit

@Observable
final class RunnerViewModel {
    var score = 0
    var coins = 0
    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: "runnerHighScore") }
        set { UserDefaults.standard.set(newValue, forKey: "runnerHighScore") }
    }
    var isGameOver = false

    let scene: RunnerScene

    init() {
        let scene = RunnerScene()
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

        scene.onCoinsChanged = { [weak self] newCoins in
            self?.coins = newCoins
        }

        scene.onGameOver = { [weak self] in
            self?.isGameOver = true
        }
    }

    func restart() {
        isGameOver = false
        score = 0
        coins = 0
        scene.restart()
    }
}
