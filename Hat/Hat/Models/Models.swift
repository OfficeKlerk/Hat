import Foundation

struct Player: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var score: Int = 0
}

struct Word: Identifiable, Hashable, Codable {
    let id = UUID()
    var text: String
}

struct TurnWord: Identifiable {
    let id = UUID()
    var word: Word
    var isGuessed: Bool
}

struct WordDictionary: Identifiable, Codable {
    let id = UUID()
    var name: String
    var words: [Word]
}
