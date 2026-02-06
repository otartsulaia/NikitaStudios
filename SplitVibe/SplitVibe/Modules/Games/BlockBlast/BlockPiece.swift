import Foundation

struct BlockPiece {
    struct Cell {
        let row: Int
        let col: Int
    }

    let cells: [Cell]

    static func random() -> BlockPiece {
        let pieces = allPieces
        return pieces.randomElement() ?? pieces[0]
    }

    // All available piece shapes
    static let allPieces: [BlockPiece] = [
        // Single
        BlockPiece(cells: [Cell(row: 0, col: 0)]),

        // Horizontal 2
        BlockPiece(cells: [Cell(row: 0, col: 0), Cell(row: 0, col: 1)]),

        // Horizontal 3
        BlockPiece(cells: [Cell(row: 0, col: 0), Cell(row: 0, col: 1), Cell(row: 0, col: 2)]),

        // Horizontal 4
        BlockPiece(cells: [Cell(row: 0, col: 0), Cell(row: 0, col: 1), Cell(row: 0, col: 2), Cell(row: 0, col: 3)]),

        // Vertical 2
        BlockPiece(cells: [Cell(row: 0, col: 0), Cell(row: 1, col: 0)]),

        // Vertical 3
        BlockPiece(cells: [Cell(row: 0, col: 0), Cell(row: 1, col: 0), Cell(row: 2, col: 0)]),

        // Vertical 4
        BlockPiece(cells: [Cell(row: 0, col: 0), Cell(row: 1, col: 0), Cell(row: 2, col: 0), Cell(row: 3, col: 0)]),

        // 2x2 Square
        BlockPiece(cells: [Cell(row: 0, col: 0), Cell(row: 0, col: 1), Cell(row: 1, col: 0), Cell(row: 1, col: 1)]),

        // 3x3 Square
        BlockPiece(cells: [
            Cell(row: 0, col: 0), Cell(row: 0, col: 1), Cell(row: 0, col: 2),
            Cell(row: 1, col: 0), Cell(row: 1, col: 1), Cell(row: 1, col: 2),
            Cell(row: 2, col: 0), Cell(row: 2, col: 1), Cell(row: 2, col: 2)
        ]),

        // L-shape
        BlockPiece(cells: [Cell(row: 0, col: 0), Cell(row: 1, col: 0), Cell(row: 2, col: 0), Cell(row: 2, col: 1)]),

        // Reverse L
        BlockPiece(cells: [Cell(row: 0, col: 1), Cell(row: 1, col: 1), Cell(row: 2, col: 1), Cell(row: 2, col: 0)]),

        // T-shape
        BlockPiece(cells: [Cell(row: 0, col: 0), Cell(row: 0, col: 1), Cell(row: 0, col: 2), Cell(row: 1, col: 1)]),

        // Z-shape
        BlockPiece(cells: [Cell(row: 0, col: 0), Cell(row: 0, col: 1), Cell(row: 1, col: 1), Cell(row: 1, col: 2)]),

        // S-shape
        BlockPiece(cells: [Cell(row: 0, col: 1), Cell(row: 0, col: 2), Cell(row: 1, col: 0), Cell(row: 1, col: 1)]),

        // Corner (2x2 minus one)
        BlockPiece(cells: [Cell(row: 0, col: 0), Cell(row: 0, col: 1), Cell(row: 1, col: 0)]),
    ]
}
