import SwiftUI

enum SwipeDirection {
    case up, down, left, right
}

@Observable
final class PuzzleViewModel {
    var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    var score = 0
    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: "puzzleHighScore") }
        set { UserDefaults.standard.set(newValue, forKey: "puzzleHighScore") }
    }
    var isGameOver = false

    init() {
        restart()
    }

    func restart() {
        grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        score = 0
        isGameOver = false
        spawnTile()
        spawnTile()
    }

    func swipe(_ direction: SwipeDirection) {
        guard !isGameOver else { return }

        let oldGrid = grid

        switch direction {
        case .left: slideLeft()
        case .right: slideRight()
        case .up: slideUp()
        case .down: slideDown()
        }

        if grid != oldGrid {
            spawnTile()
            if !canMove() {
                isGameOver = true
            }
        }
    }

    // MARK: - Slide Logic

    private func slideLeft() {
        for row in 0..<4 {
            let merged = mergeRow(grid[row])
            grid[row] = merged
        }
    }

    private func slideRight() {
        for row in 0..<4 {
            let merged = mergeRow(grid[row].reversed()).reversed()
            grid[row] = Array(merged)
        }
    }

    private func slideUp() {
        for col in 0..<4 {
            var column = (0..<4).map { grid[$0][col] }
            column = mergeRow(column)
            for row in 0..<4 {
                grid[row][col] = column[row]
            }
        }
    }

    private func slideDown() {
        for col in 0..<4 {
            var column = (0..<4).map { grid[$0][col] }
            column = mergeRow(column.reversed()).reversed()
            for row in 0..<4 {
                grid[row][col] = Array(column)[row]
            }
        }
    }

    private func mergeRow(_ row: [Int]) -> [Int] {
        var filtered = row.filter { $0 != 0 }
        var result: [Int] = []
        var i = 0

        while i < filtered.count {
            if i + 1 < filtered.count && filtered[i] == filtered[i + 1] {
                let merged = filtered[i] * 2
                result.append(merged)
                score += merged
                if score > highScore { highScore = score }
                i += 2
            } else {
                result.append(filtered[i])
                i += 1
            }
        }

        while result.count < 4 {
            result.append(0)
        }

        return result
    }

    // MARK: - Helpers

    private func spawnTile() {
        var emptyCells: [(Int, Int)] = []
        for row in 0..<4 {
            for col in 0..<4 {
                if grid[row][col] == 0 {
                    emptyCells.append((row, col))
                }
            }
        }

        guard let cell = emptyCells.randomElement() else { return }
        grid[cell.0][cell.1] = Int.random(in: 0...9) < 9 ? 2 : 4
    }

    private func canMove() -> Bool {
        // Any empty cell?
        for row in 0..<4 {
            for col in 0..<4 {
                if grid[row][col] == 0 { return true }
            }
        }

        // Any adjacent equal?
        for row in 0..<4 {
            for col in 0..<4 {
                let val = grid[row][col]
                if col + 1 < 4 && grid[row][col + 1] == val { return true }
                if row + 1 < 4 && grid[row + 1][col] == val { return true }
            }
        }

        return false
    }
}
