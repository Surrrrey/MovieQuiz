import Foundation

struct NetworkClient {
    
    // MARK: - Error Codes
    
    private enum NetworkError: Error {
        case codeError
    }
    
    // MARK: - Public Methods
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error  in
            if let error = error {
                handler(Result.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(Result.failure(NetworkError.codeError))
                return
            }
            
            guard let data = data else { return }
            handler(Result.success(data))
        }
        
        task.resume()
    }
}
