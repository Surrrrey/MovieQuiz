import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    // MARK: - Properties
    
    private let questionsAmount = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var gameResult: GameResult?
    
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    private var currentQuestionIndex = 1
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addQuestionFactory()
        addGameResult()
    }
    
    // MARK: - IBActions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        checkAnswer(true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        checkAnswer(false)
    }
    
    // MARK: - Private Methods
    
    private func addQuestionFactory() {
        let questionFactory = QuestionFactory()
        
        questionFactory.delegate = self
        
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
    }
    
    private func addGameResult() {
        self.gameResult = GameResult(correctAnswers: 0, totalAnswers: self.questionsAmount, date: Date())
    }
    
    private func checkAnswer(_ answer: Bool) {
        guard let currentQuestion else { return }
        let isCorrect = answer == currentQuestion.correctAnswer
        showAnswerResult(isCorrect: isCorrect)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
    }
    
    
    private func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            self.restartGame()
        }
        alertPresenter.show(in: self, model: model)
    }
    
    private func restartGame() {
        self.currentQuestionIndex = 1
        self.gameResult?.correctAnswers = 0
        self.questionFactory?.requestNextQuestion()
    }
    
    private func makeBorder(color: UIColor) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = color.cgColor
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        isCorrect == true
        ? makeBorder(color: UIColor.ypGreen)
        : makeBorder(color: UIColor.ypRed)
        isCorrect ? gameResult?.correctAnswers += 1 : nil
        view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
            self.imageView.layer.borderWidth = 0
            self.view.isUserInteractionEnabled = true}
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount {
            guard let gameResult else { return }
            statisticService.store(game: gameResult)
            show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!",
                                            text: "Ваш результат: \(gameResult.correctAnswers)/\(gameResult.totalAnswers)\n" +
                                            "Количество сыграных квизов: \(statisticService.gamesCount)\n" +
                                            "Рекорд: \(statisticService.bestGame.correctAnswers)/\(statisticService.bestGame.totalAnswers) (\(statisticService.bestGame.date.dateTimeString))\n" +
                                            "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%",
                                            buttonText: "Сыграть ещё раз"))
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}
// MARK: - Extensions
// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController: QuestionFactoryDelegate {
    
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}

