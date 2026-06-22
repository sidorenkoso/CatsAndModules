import Foundation
import Networking

struct DisplayCat: Identifiable, Hashable {
    let cat: Cat
    let name: String

    var id: String { cat.id }
    var imageURL: URL { cat.url }
}
