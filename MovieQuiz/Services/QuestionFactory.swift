import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    // MARK: - Properties
    
    private weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoadingProtocol
    
    private var moviesFromData = [MostPopularMovie]()
    private var arrayOfMovies = [MostPopularMovie]()
    private var currentMovie: MostPopularMovie?
        
    // MARK: - Init
    
    init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoadingProtocol) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    // MARK: - Public Methods
    
    func requestNextQuestion() {
        randomMovie()
        loadQuestion()
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.moviesFromData = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func reloadQuestion() {
        loadQuestion()
    }
    
    // MARK: - Private Methods
    
    private func loadQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self,
                  let movie = currentMovie
            else { return }
            
            let question = makeQuestion(from: movie)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    private func randomMovie() {
        if arrayOfMovies.isEmpty { makeArrayOfRandomMovies() }
        
        let index = (0..<self.arrayOfMovies.count).randomElement() ?? 0
        
        currentMovie = arrayOfMovies[safe:index]
        
        arrayOfMovies.remove(at: index)
    }
    
    private func makeArrayOfRandomMovies() {
        arrayOfMovies.removeAll()
        for _ in 1...10 {
            let index = (0..<self.moviesFromData.count).randomElement() ?? 0
            guard let movieForQuestion = self.moviesFromData[safe: index] else { return }
            self.arrayOfMovies.append(movieForQuestion)
            self.moviesFromData.remove(at: index)
        }
    }
    
    private func loadImageData() -> Data {
        var imageData = Data()
        if let currentMovie = currentMovie {
            do {
                imageData = try Data(contentsOf: currentMovie.imageURL)
            } catch {
                print("LoadImageError")
            }
        }
        return imageData
    }
    
    private func makeQuestion(from movie: MostPopularMovie) -> QuizQuestion? {
        
        let imageData = loadImageData()
        
        let rating = Float(movie.rating) ?? 0
        
        let numInQuestion: Int
        
        if Int(rating) != 0 && Int(rating) < 9 {
            guard let randomNumber = (Int(rating)-1...Int(rating)+1).randomElement() else { return nil }
            numInQuestion = randomNumber
        } else {
            guard let randomNumber = (Int(rating)-1...Int(rating)).randomElement() else { return nil }
            numInQuestion = randomNumber
        }
        
        let text = "Рейтинг этого фильма больше чем \(numInQuestion)?"
        
        let correctAnswer = rating > Float(numInQuestion)
        
        return QuizQuestion(image: imageData,
                            text: text,
                            correctAnswer: correctAnswer)
    }
}
