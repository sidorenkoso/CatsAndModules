import Foundation

public protocol CatService: Sendable {
    func getCats(limit: Int) async throws -> [Cat]
}

public extension CatService {
    func getCats() async throws -> [Cat] {
        try await getCats(limit: 20)
    }
}
