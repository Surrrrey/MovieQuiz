import XCTest
@testable import MovieQuiz

// MARK: - MOCK ViewController

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func show(quiz result: MovieQuiz.QuizResultsViewModel) {
        
    }
    
    func isVisibleLoadingIndicator(status: Bool) {
        
    }
    
    func makeBorder(isAnswerCorrect: Bool) {
        
    }
    
    func showNetworkError() {
        
    }
}

// MARK: - TestMovieQuizPresenter

final class MovieQuizPresenterTests: XCTestCase {
    
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let testPresenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question text", correctAnswer: true)
        let viewModel = testPresenter.convert(model: question)
        
        XCTAssertEqual(viewModel.image, emptyData)
        XCTAssertEqual(viewModel.question, "Question text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
