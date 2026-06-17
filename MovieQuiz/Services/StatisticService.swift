import Foundation

class StatisticService: StatisticServiceProtocol {
    private enum Keys: String {
        case gamesCount //счётчик сыгранных игр
        case bestGameCorrectAnswers //рекордное количество правильных ответов
        case bestGameTotalAnswers //общее количество вопросов в рекордной игре
        case bestGameDate //дата рекордной игры
        case totalCorrectAnswers //общее количество верных ответов
    }
    
    private let storage: UserDefaults = .standard
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            return GameResult(correctAnswers: storage.integer(forKey: Keys.bestGameCorrectAnswers.rawValue),
                              totalAnswers: storage.integer(forKey: Keys.bestGameTotalAnswers.rawValue),
                              date: storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date())
        }
        set {
            storage.set(newValue.correctAnswers, forKey: Keys.bestGameCorrectAnswers.rawValue)
            storage.set(newValue.totalAnswers, forKey: Keys.bestGameTotalAnswers.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            getTotalAccuracy()
        }
    }
    
    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    private func getTotalAccuracy() -> Double {
        guard gamesCount != 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(gamesCount * 10) * 100
    }
    
    func store(game result: GameResult) {
        gamesCount += 1
        totalCorrectAnswers += result.correctAnswers
        if result.isBetterThan(bestGame) {
            bestGame = result
        }
    }
    
    
}
