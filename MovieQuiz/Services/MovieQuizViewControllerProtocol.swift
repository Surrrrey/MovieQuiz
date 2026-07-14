protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func isVisibleLoadingIndicator(status: Bool)
    
    func makeBorder(isAnswerCorrect: Bool)
    
    func showNetworkError()
}
