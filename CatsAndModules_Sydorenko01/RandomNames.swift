import Foundation

enum RandomNames {
    private static let names = [
        "Whiskers", "Mittens", "Simba", "Luna", "Oliver", "Leo", "Bella",
        "Milo", "Charlie", "Lucy", "Max", "Nala", "Tiger", "Smokey",
        "Shadow", "Pumpkin", "Cleo", "Felix", "Ginger", "Loki",
        "Mochi", "Pepper", "Biscuit", "Salem", "Cooper", "Nimbus"
    ]

    static func name(for seed: String) -> String {
        guard !names.isEmpty else { return "Cat" }
        var hash = 5381
        for byte in seed.utf8 {
            hash = ((hash << 5) &+ hash) &+ Int(byte)
        }
        return names[abs(hash) % names.count]
    }
}
