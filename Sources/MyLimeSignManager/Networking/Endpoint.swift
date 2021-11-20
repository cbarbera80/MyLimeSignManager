import Foundation

protocol RequestProviding {
    func buildURLRequest(againstBaseURL baseUrl: URL) -> URLRequest
}

typealias Requestable = RequestProviding

enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

enum Endpoint {
    case getSignatureKey
    
    var method: HTTPMethod {
        switch self {
        case .getSignatureKey:
            return .post
        }
    }
    
    var pathComponent: String {
        switch self {
        case .getSignatureKey:
            return "/users/signature_key"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getSignatureKey:
            return [URLQueryItem(name: "private_key_format", value: "pkcs1")]
        }
    }
}

extension Endpoint: RequestProviding {
    
    func buildURLRequest(againstBaseURL baseUrl: URL) -> URLRequest {
        
        var url = baseUrl
        url.appendPathComponent(pathComponent)
        
        // Build parameters
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return URLRequest(url: url) }
        urlComponents.queryItems = queryItems
        guard let finalUrl = urlComponents.url else { return URLRequest(url: url) }
        
        var request = URLRequest(url: finalUrl)
        request.httpMethod = method.rawValue
        return request
    }
}
