import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    
    @Published var players: [Player] = [
        Player(name: "Игрок 1"),
        Player(name: "Игрок 2"),
    ]
    @Published var roundDuration: Int = 60
    @Published var totalWordsInGame: Int = 30
    
    @Published var availableDictionaries: [WordDictionary] = []
    @Published var selectedDictionaryID: UUID?
    
    private let dictionariesKey = "saved_custom_dictionaries"
    
    @Published var wordsInHat: [Word] = []
    @Published var currentTurnWords: [TurnWord] = []
    
    @Published var currentPlayerIndex: Int = 0
    @Published var timeLeft: Int = 60
    private var timer: Timer?
    
    var activePlayer: Player {
        if players.indices.contains(currentPlayerIndex) {
            return players[currentPlayerIndex]
        }
        return Player(name: "Неизвестный игрок")
    }
    
    init() {
        loadDefaultDictionary()
        loadCustomDictionaries()
    }
    
    private func loadDefaultDictionary() {
        var words: [Word] = []
        if let filepath = Bundle.main.path(forResource: "DefaultWords", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let lines = contents.components(separatedBy: .newlines)
                words = lines.compactMap { line in
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    return trimmed.isEmpty ? nil : Word(text: trimmed)
                }
            } catch {
                print("Ошибка чтения")
            }
        }
        if words.isEmpty {
            words = (1...100).map { Word(text: "Слово \($0)") }
        }
        
        let defaultDict = WordDictionary(name: "Стандартный словарь", words: words)
        availableDictionaries.append(defaultDict)
        selectedDictionaryID = defaultDict.id
    }
    
    private func saveCustomDictionaries() {
        let customDicts = availableDictionaries.filter { $0.name != "Стандартный словарь" }
        if let encodedData = try? JSONEncoder().encode(customDicts) {
            UserDefaults.standard.set(encodedData, forKey: dictionariesKey)
        }
    }
    
    private func loadCustomDictionaries() {
        if let savedData = UserDefaults.standard.data(forKey: dictionariesKey),
           let decodedDicts = try? JSONDecoder().decode([WordDictionary].self, from: savedData) {
            availableDictionaries.append(contentsOf: decodedDicts)
        }
    }
    
    func parseWordsFromFile(url: URL) -> [Word]? {
        do {
            let data = try Data(contentsOf: url)
            if let contents = String(data: data, encoding: .utf8) {
                let lines = contents.components(separatedBy: .newlines)
                let words = lines.compactMap { line -> Word? in
                    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    return trimmed.isEmpty ? nil : Word(text: trimmed)
                }
                return words.isEmpty ? nil : words
            }
        } catch {
            print("Ошибка при чтении файла: \(error.localizedDescription)")
        }
        return nil
    }
        
    func addNewCustomDictionary(name: String, words: [Word]) {
        let newDict = WordDictionary(name: name, words: words)
        availableDictionaries.append(newDict)
        selectedDictionaryID = newDict.id
        
        saveCustomDictionaries()
    }
    
    func addPlayer() {
        players.append(Player(name: "Игрок \(players.count + 1)"))
    }
    
    func removePlayer(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }
    
    func movePlayer(from source: IndexSet, to destination: Int) {
        players.move(fromOffsets: source, toOffset: destination)
    }
    
    func prepareGame() {
        guard let id = selectedDictionaryID,
              let dict = availableDictionaries.first(where: { $0.id == id }) else { return }
        
        for i in 0..<players.count {
            players[i].score = 0
        }
        
        var shuffledDict = dict.words.shuffled()
        let countToTake = min(totalWordsInGame, shuffledDict.count)
        wordsInHat = Array(shuffledDict.prefix(countToTake))
        
        currentPlayerIndex = 0
    }
    
    func startTurn() {
        currentTurnWords = []
        wordsInHat.shuffle()
        timeLeft = roundDuration
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerTick()
        }
    }
    
    func timerTick() {
        if timeLeft > 0 {
            timeLeft -= 1
        } else {
            endTurnEarly()
        }
    }
    
    func wordGuessed() { processWord(isGuessed: true) }
    func wordSkipped() { processWord(isGuessed: false) }
    
    private func processWord(isGuessed: Bool) {
        guard !wordsInHat.isEmpty else { return }
        
        let word = wordsInHat.removeFirst()
        currentTurnWords.append(TurnWord(word: word, isGuessed: isGuessed))
        
        if wordsInHat.isEmpty { endTurnEarly() }
    }
    
    func endTurnEarly() {
        timer?.invalidate()
    }
    
    func finalizeTurn() {
        guard players.indices.contains(currentPlayerIndex) else { return }
        
        for turnWord in currentTurnWords {
            if turnWord.isGuessed {
                players[currentPlayerIndex].score += 1
            } else {
                wordsInHat.append(turnWord.word)
            }
        }
        
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }
}
