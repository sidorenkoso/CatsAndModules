import Foundation

public struct CatAPIClient: CatService {

    private let baseURL: URL
    private let apiKey: String?
    private let session: URLSession

    public init(apiKey: String? = nil,
                host: String = "api.thecatapi.com",
                session: URLSession = .shared) {
        self.apiKey = apiKey
        self.baseURL = URL(string: "https://\(host)/v1")!
        self.session = session
    }

    public func getCats(limit: Int = 20) async throws -> [Cat] {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("images/search"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "limit", value: String(max(1, min(limit, 100)))),
            URLQueryItem(name: "size", value: "small"),
            URLQueryItem(name: "order", value: "RANDOM")
        ]

        guard let url = components?.url else {
            throw NetworkingError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let apiKey, !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkingError.transport(underlying: error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkingError.invalidResponse(statusCode: -1)
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkingError.invalidResponse(statusCode: http.statusCode)
        }

        do {
            return try JSONDecoder().decode([Cat].self, from: data)
        } catch {
            throw NetworkingError.decodingFailed(underlying: error)
        }
    }
}
