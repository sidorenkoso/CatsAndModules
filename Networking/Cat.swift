import Foundation

public struct Cat: Identifiable, Decodable, Sendable, Hashable {
    public let id: String
    public let url: URL
    public let width: Int?
    public let height: Int?

    public init(id: String, url: URL, width: Int? = nil, height: Int? = nil) {
        self.id = id
        self.url = url
        self.width = width
        self.height = height
    }
}
