import XCTest
@testable import MovieQuiz

// MARK: MOCK QuestionFactory

final class QuestionFactoryMock: QuestionFactoryProtocol {
    
    private var questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather".data(using: .utf8) ?? Data(),
                     text: "Рейтинг этого фильма больше чем 1?",
                     correctAnswer: true),
        QuizQuestion(image: "The Dark Knight".data(using: .utf8) ?? Data(),
                     text: "Рейтинг этого фильма больше чем 2?",
                     correctAnswer: true),
        QuizQuestion(image: "Kill Bill".data(using: .utf8) ?? Data(),
                     text: "Рейтинг этого фильма больше чем 3?",
                     correctAnswer: true),
        QuizQuestion(image: "The Avengers".data(using: .utf8) ?? Data(),
                     text: "Рейтинг этого фильма больше чем 4?",
                     correctAnswer: true),
        QuizQuestion(image: "Deadpool".data(using: .utf8) ?? Data(),
                     text: "Рейтинг этого фильма больше чем 5?",
                     correctAnswer: true),
        QuizQuestion(image: "The Green Knight".data(using: .utf8) ?? Data(),
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "Old".data(using: .utf8) ?? Data(),
                     text: "Рейтинг этого фильма больше чем 7?",
                     correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild".data(using: .utf8) ?? Data(),
                     text: "Рейтинг этого фильма больше чем 8?",
                     correctAnswer: false),
        QuizQuestion(image: "Tesla".data(using: .utf8) ?? Data(),
                     text: "Рейтинг этого фильма больше чем 9?",
                     correctAnswer: false),
        QuizQuestion(image: "Vivarium".data(using: .utf8) ?? Data(),
                     text: "Рейтинг этого фильма больше чем 10?",
                     correctAnswer: false)
    ]
    
    var arrayOfQuestion = [QuizQuestion]()
    
    var currentQuestion: QuizQuestion?
    
    func loadData() {
        
    }
    
    func reloadQuestion() {
        
    }
    
    func requestNextQuestion() {
        if arrayOfQuestion.isEmpty { makeArrayOfRandomMovies() }
        
        let index = (0..<self.arrayOfQuestion.count).randomElement() ?? 0
        
        currentQuestion = arrayOfQuestion[safe:index]
        
        arrayOfQuestion.remove(at: index)
    }
    
    func makeArrayOfRandomMovies() {
        arrayOfQuestion.removeAll()
        for _ in 1...10 {
            let index = (0..<self.questions.count).randomElement() ?? 0
            guard let movieForQuestion = self.questions[safe: index] else { return }
            self.arrayOfQuestion.append(movieForQuestion)
            self.questions.remove(at: index)
        }
    }
}

// MARK: - QuestionFactoryTest

class QuestionFactoryTest: XCTestCase {
    
    let questionFactory = QuestionFactoryMock()
    
    func testMakesArrayOfQuestions() {
        questionFactory.makeArrayOfRandomMovies()
        
        XCTAssertFalse(questionFactory.arrayOfQuestion.isEmpty)
    }
    
    func testRequestNextQuestion() {
        questionFactory.makeArrayOfRandomMovies()
        let currentQuestion = questionFactory.currentQuestion
        questionFactory.requestNextQuestion()
        let secondQuestion = questionFactory.currentQuestion
        
        XCTAssertTrue(currentQuestion?.text != secondQuestion?.text)
    }
}
