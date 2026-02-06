import SpriteKit
import SwiftUI

final class BlockBlastScene: SKScene {
    // MARK: - Grid Constants
    private let gridSize = 8
    private var cellSize: CGFloat = 0
    private var gridOrigin: CGPoint = .zero

    // MARK: - State
    private var grid: [[SKSpriteNode?]] = []
    private var availablePieces: [BlockPiece] = []
    private var pieceNodes: [SKNode] = []
    private var draggedPiece: SKNode?
    private var draggedPieceData: BlockPiece?
    private var draggedPieceIndex: Int?
    private var originalPosition: CGPoint = .zero

    var onScoreChanged: ((Int) -> Void)?
    var onGameOver: (() -> Void)?
    private var currentScore = 0

    // MARK: - Colors
    private let blockColors: [UIColor] = [
        .systemPurple, .systemBlue, .systemCyan,
        .systemGreen, .systemYellow, .systemOrange,
        .systemRed, .systemPink
    ]

    // MARK: - Setup

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        setupGrid()
        spawnNewPieces()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 0, size.height > 0 else { return }
        removeAllChildren()
        grid = []
        pieceNodes = []
        setupGrid()
        spawnNewPieces()
    }

    private func setupGrid() {
        let margin: CGFloat = 16
        let availableWidth = size.width - margin * 2
        let gridHeight = size.height * 0.65
        cellSize = min(availableWidth / CGFloat(gridSize), gridHeight / CGFloat(gridSize))
        let totalGridWidth = cellSize * CGFloat(gridSize)
        let totalGridHeight = cellSize * CGFloat(gridSize)
        gridOrigin = CGPoint(
            x: (size.width - totalGridWidth) / 2,
            y: size.height - totalGridHeight - 40
        )

        grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)

        // Draw grid background
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = SKSpriteNode(color: UIColor.systemGray6, size: CGSize(width: cellSize - 2, height: cellSize - 2))
                cell.position = positionForCell(row: row, col: col)
                cell.zPosition = 0
                addChild(cell)
            }
        }
    }

    private func positionForCell(row: Int, col: Int) -> CGPoint {
        CGPoint(
            x: gridOrigin.x + CGFloat(col) * cellSize + cellSize / 2,
            y: gridOrigin.y + CGFloat(gridSize - 1 - row) * cellSize + cellSize / 2
        )
    }

    // MARK: - Pieces

    private func spawnNewPieces() {
        // Remove old piece nodes
        pieceNodes.forEach { $0.removeFromParent() }
        pieceNodes.removeAll()
        availablePieces.removeAll()

        let pieces = (0..<3).map { _ in BlockPiece.random() }
        availablePieces = pieces

        let pieceAreaY: CGFloat = 40
        let spacing = size.width / 3

        for (index, piece) in pieces.enumerated() {
            let node = createPieceNode(piece: piece, scale: 0.6)
            node.position = CGPoint(
                x: spacing * CGFloat(index) + spacing / 2,
                y: pieceAreaY
            )
            node.name = "piece_\(index)"
            node.zPosition = 10
            addChild(node)
            pieceNodes.append(node)
        }

        // Check if any piece can be placed
        if !canAnyPieceBePlaced() {
            onGameOver?()
        }
    }

    private func createPieceNode(piece: BlockPiece, scale: CGFloat) -> SKNode {
        let container = SKNode()
        let color = blockColors.randomElement() ?? .systemPurple

        for cell in piece.cells {
            let blockSize = cellSize * scale
            let block = SKSpriteNode(color: color, size: CGSize(width: blockSize - 2, height: blockSize - 2))
            block.position = CGPoint(
                x: CGFloat(cell.col) * blockSize,
                y: CGFloat(-cell.row) * blockSize
            )
            block.name = "block"
            container.addChild(block)
        }
        container.userData = ["color": color]
        return container
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        for (index, node) in pieceNodes.enumerated() {
            if node.contains(location) {
                draggedPiece = node
                draggedPieceData = availablePieces[index]
                draggedPieceIndex = index
                originalPosition = node.position

                // Scale up for dragging
                node.run(SKAction.scale(to: 1.0, duration: 0.15))
                node.zPosition = 100
                break
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let node = draggedPiece else { return }
        let location = touch.location(in: self)
        node.position = CGPoint(x: location.x, y: location.y + cellSize * 2)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let node = draggedPiece,
              let piece = draggedPieceData,
              let index = draggedPieceIndex else { return }

        let gridPos = gridPositionForNode(node, piece: piece)

        if let pos = gridPos, canPlace(piece: piece, at: pos) {
            placePiece(piece: piece, at: pos, color: node.userData?["color"] as? UIColor ?? .systemPurple)
            node.removeFromParent()
            pieceNodes[index] = SKNode() // placeholder
            availablePieces[index] = BlockPiece(cells: []) // empty

            clearFullLines()

            // Check if all pieces used
            if availablePieces.allSatisfy({ $0.cells.isEmpty }) {
                spawnNewPieces()
            } else if !canAnyPieceBePlaced() {
                onGameOver?()
            }
        } else {
            // Snap back
            node.run(SKAction.group([
                SKAction.move(to: originalPosition, duration: 0.2),
                SKAction.scale(to: 0.6, duration: 0.2)
            ]))
            node.zPosition = 10
        }

        draggedPiece = nil
        draggedPieceData = nil
        draggedPieceIndex = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    // MARK: - Grid Logic

    private func gridPositionForNode(_ node: SKNode, piece: BlockPiece) -> GridPosition? {
        let pos = node.position
        let col = Int((pos.x - gridOrigin.x) / cellSize)
        let row = gridSize - 1 - Int((pos.y - gridOrigin.y) / cellSize)

        let gridPos = GridPosition(row: row, col: col)
        return gridPos
    }

    private func canPlace(piece: BlockPiece, at origin: GridPosition) -> Bool {
        for cell in piece.cells {
            let r = origin.row + cell.row
            let c = origin.col + cell.col
            guard r >= 0, r < gridSize, c >= 0, c < gridSize else { return false }
            if grid[r][c] != nil { return false }
        }
        return true
    }

    private func placePiece(piece: BlockPiece, at origin: GridPosition, color: UIColor) {
        for cell in piece.cells {
            let r = origin.row + cell.row
            let c = origin.col + cell.col
            let block = SKSpriteNode(color: color, size: CGSize(width: cellSize - 2, height: cellSize - 2))
            block.position = positionForCell(row: r, col: c)
            block.zPosition = 5
            addChild(block)
            grid[r][c] = block
        }
        addScore(piece.cells.count)
    }

    private func clearFullLines() {
        var rowsToClear: [Int] = []
        var colsToClear: [Int] = []

        // Check rows
        for row in 0..<gridSize {
            if (0..<gridSize).allSatisfy({ grid[row][$0] != nil }) {
                rowsToClear.append(row)
            }
        }

        // Check columns
        for col in 0..<gridSize {
            if (0..<gridSize).allSatisfy({ grid[$0][col] != nil }) {
                colsToClear.append(col)
            }
        }

        let totalLines = rowsToClear.count + colsToClear.count
        guard totalLines > 0 else { return }

        // Bonus for multiple lines
        let bonus = totalLines > 1 ? totalLines * 10 : 0
        addScore(totalLines * gridSize + bonus)

        // Clear rows
        for row in rowsToClear {
            for col in 0..<gridSize {
                clearCell(row: row, col: col)
            }
        }

        // Clear columns
        for col in colsToClear {
            for row in 0..<gridSize {
                clearCell(row: row, col: col)
            }
        }
    }

    private func clearCell(row: Int, col: Int) {
        guard let node = grid[row][col] else { return }
        node.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.3, duration: 0.1),
                SKAction.fadeAlpha(to: 0.5, duration: 0.1)
            ]),
            SKAction.group([
                SKAction.scale(to: 0, duration: 0.15),
                SKAction.fadeOut(withDuration: 0.15)
            ]),
            SKAction.removeFromParent()
        ]))
        grid[row][col] = nil
    }

    private func canAnyPieceBePlaced() -> Bool {
        for piece in availablePieces where !piece.cells.isEmpty {
            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    if canPlace(piece: piece, at: GridPosition(row: row, col: col)) {
                        return true
                    }
                }
            }
        }
        return false
    }

    private func addScore(_ points: Int) {
        currentScore += points
        onScoreChanged?(currentScore)
    }

    // MARK: - Restart

    func restart() {
        currentScore = 0
        onScoreChanged?(0)

        // Clear grid
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                grid[row][col]?.removeFromParent()
                grid[row][col] = nil
            }
        }

        spawnNewPieces()
    }
}

struct GridPosition {
    let row: Int
    let col: Int
}
