import Foundation
import SwiftData

@Model
final class GameScore {
    var gameType: String
    var score: Int
    var date: Date

    init(gameType: String, score: Int, date: Date = .now) {
        self.gameType = gameType
        self.score = score
        self.date = date
    }
}

@Model
final class FavoriteMode {
    @Attribute(.unique) var modeId: String
    var dateAdded: Date

    init(modeId: String, dateAdded: Date = .now) {
        self.modeId = modeId
        self.dateAdded = dateAdded
    }
}
