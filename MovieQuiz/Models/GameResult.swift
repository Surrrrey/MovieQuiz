import Foundation

struct GameResult {
    var correctAnswers: Int
    let totalAnswers: Int
    let date: Date
    
    func isBetterThan(_ anoter: GameResult) -> Bool {
        correctAnswers > anoter.correctAnswers
    }
}

