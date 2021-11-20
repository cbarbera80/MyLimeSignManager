import UIKit

enum NetworkError: Error {
    case invalidMapping
    case networkError(error: Error)
}

protocol DataProviderable {
    func execute<T: Decodable>(_ endpoint: Requestable, of type: T.Type, completion: @escaping (Result<T, Error>) -> Void)
}

class Networking: DataProviderable {
    private let environment: Environment
    private let auth: Auth
    
    init(withEnvironment environment: Environment, auth: Auth) {
        self.environment = environment
        self.auth = auth
    }
    
    func execute<T: Decodable>(_ endpoint: Requestable, of type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        
        var urlRequest = endpoint.buildURLRequest(againstBaseURL: environment.baseUrl)
        
        urlRequest.addValue(auth.token, forHTTPHeaderField: "access-token")
        urlRequest.addValue(auth.client, forHTTPHeaderField: "client")
        urlRequest.addValue(auth.uid, forHTTPHeaderField: "uid")
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print(urlRequest.curlString)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.networkError(error: error)))
                }
                return
            }
            
            guard let data = data else {
                preconditionFailure("No error was received but we also don't have data...")
            }
            
            DispatchQueue.main.async {
                if let decodedObject = try? JSONDecoder().decode(T.self, from: data) {
                    completion(.success(decodedObject))
                } else {
                    completion(.failure(NetworkError.invalidMapping))
                }
            }
            
        }.resume()
    }
}

