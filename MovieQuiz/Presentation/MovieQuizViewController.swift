import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    private let questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex = 1
    private var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        
    }

    // MARK: - QuestionFactoryDelegate
    
    func didReciveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        checkAnswer(true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        checkAnswer(false)
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
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currentQuestionIndex = 1
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
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
        isCorrect ? correctAnswers += 1 : nil
        view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
            self.imageView.layer.borderWidth = 0
            self.view.isUserInteractionEnabled = true}
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount {
            show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!",
                                            text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                                            buttonText: "Сыграть ещё раз"))
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}
