import Foundation

final class MovieQuizPresenter {
    
    // MARK: - Properties
    
    let questionsAmount = 10
    private var currentQuestionIndex = 1

    // MARK: - Public Methods
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: Data(model.image),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount
    }
    
    func switchQuestionIndex() {
        currentQuestionIndex += 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 1
    }
    
    // MARK: - Private Methods
}
