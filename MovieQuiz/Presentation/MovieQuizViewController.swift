import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        isVisibleLoadingIndicator(status: true)
        presenter?.addQuestionFactory()
        presenter?.addGameResult()
        presenter?.questionFactory?.loadData()
    }
    
    // MARK: - IBActions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        self.presenter?.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        self.presenter?.noButtonClicked()
    }
    
    // MARK: - Public Methods
    
    func show(quiz step: QuizStepViewModel) {
        isVisibleLoadingIndicator(status: true)
        
        imageView.image = UIImage(data: step.image) ?? UIImage()
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        
        isVisibleLoadingIndicator(status: false)
        
        imageView.layer.borderWidth = 0
        view.isUserInteractionEnabled = true
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            isVisibleLoadingIndicator(status: true)
            self.presenter?.restartGame()
        }
        
        self.alertPresenter.show(in: self, model: model)
    }
    
    func isVisibleLoadingIndicator(status: Bool) {
        if status == true {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    func makeBorder(isAnswerCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor =
        isAnswerCorrect
        ? UIColor.ypGreen.cgColor
        : UIColor.ypRed.cgColor
    }
    
    func showNetworkError() {
        isVisibleLoadingIndicator(status: false)
        
        let errorModel = AlertModel(title: "Что-то пошло не так(",
                                    message: "Невозможно загрузить данные",
                                    buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }
            isVisibleLoadingIndicator(status: true)
            self.presenter?.questionFactory?.loadData()
        }
        
        self.alertPresenter.show(in: self, model: errorModel)
    }
}
