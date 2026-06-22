import Foundation

public enum NetworkingError: Error, LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingFailed(underlying: Error)
    case transport(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL could not be built."
        case .invalidResponse(let code):
            return "The server returned an unexpected status code: \(code)."
        case .decodingFailed(let error):
            return "Failed to decode the server response: \(error.localizedDescription)"
        case .transport(let error):
            return "A network error occurred: \(error.localizedDescription)"
        }
    }
}
