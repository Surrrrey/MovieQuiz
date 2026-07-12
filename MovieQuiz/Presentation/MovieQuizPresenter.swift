import Foundation

final class MovieQuizPresenter {
    
    // MARK: - Properties
    
    var questionFactory: QuestionFactoryProtocol?
    
    private var currentQuestionIndex = 1
    private let questionsAmount = 10
    
    private var gameResult: GameResult?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    // MARK: - Init
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
    }
    
    // MARK: - Public Methods
    
    func addGameResult() {
        self.gameResult = GameResult(correctAnswers: 0, totalAnswers: self.questionsAmount, date: Date())
    }
    
    func addQuestionFactory() {
        let questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        
        self.questionFactory = questionFactory
    }
    
    func yesButtonClicked() {
        checkAnswer(true)
    }
    
    func noButtonClicked() {
        checkAnswer(false)
    }
    
    func restartGame() {
        resetQuestionIndex()
        gameResult?.correctAnswers = 0
        questionFactory?.loadData()
    }
    
    // MARK: - Private Methods
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount
    }
    
    private func switchQuestionIndex() {
        currentQuestionIndex += 1
    }
    
    private func resetQuestionIndex() {
        currentQuestionIndex = 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: Data(model.image),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex)/\(questionsAmount)")
    }
    
    private func checkAnswer(_ answer: Bool) {
        guard let currentQuestion else { return }
        let isCorrect = answer == currentQuestion.correctAnswer
        isCorrect ? self.gameResult?.correctAnswers += 1 : nil
        self.showAnswerResult(isCorrect: isCorrect)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        isCorrect == true
        ? viewController?.makeBorder(isAnswerCorrect: true)
        : viewController?.makeBorder(isAnswerCorrect: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
            self.viewController?.isVisibleLoadingIndicator(status: true)
        }
    }
    
    private func showNextQuestionOrResult() {
        if self.isLastQuestion() {
            guard let gameResult else { return }
            statisticService.store(game: gameResult)
            viewController?.show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!",
                                                            text: "Ваш результат: \(gameResult.correctAnswers)/\(gameResult.totalAnswers)\n" +
                                                            "Количество сыграных квизов: \(statisticService.gamesCount)\n" +
                                                            "Рекорд: \(statisticService.bestGame.correctAnswers)/\(statisticService.bestGame.totalAnswers) (\(statisticService.bestGame.date.dateTimeString))\n" +
                                                            "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%",
                                                            buttonText: "Сыграть ещё раз"))
        } else {
            self.switchQuestionIndex()
            questionFactory?.requestNextQuestion()
        }
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizPresenter: QuestionFactoryDelegate {
    
    func didLoadDataFromServer() {
        self.questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        self.viewController?.showNetworkError()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
}
