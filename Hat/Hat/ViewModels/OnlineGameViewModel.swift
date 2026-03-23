import SwiftUI
import Combine

@MainActor
class OnlineGameViewModel: ObservableObject {
    @AppStorage("savedPlayerID") private var savedPlayerID: String = ""
    
    @Published var myName: String = ""
    @Published var myPlayerID: UUID?
    @Published var joinCode: String = ""
    @Published var currentGameID: UUID?
    @Published var isHost: Bool = false
    @Published var playersInLobby: [UserDTO] = []
    @Published var messages: [MessageDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var isGameStarted: Bool = false
    @Published var isMyTurnToExplain: Bool = false
    @Published var currentWordToExplain: String = ""
    @Published var explainPlayerName: String = ""
    @Published var isTurnFinished: Bool = false
    
    private var pollingTimer: Timer?
    private var processedMessageIDs: Set<UUID> = []
    private var wordsList: [String] = []
    private var currentTurnIndex: Int = 0
    
    @Published var lastGuessedWord: String = ""
    @Published var lastWinnerName: String = ""
    @Published var isGameOver: Bool = false
    @Published var finalScores: [(name: String, score: Int)] = []
    
    @Published var winningMessageIDs: Set<UUID> = []

    private func getOrCreateUser() async throws -> UUID {
        if let savedUUID = UUID(uuidString: savedPlayerID) {
            do {
                let _ = try await NetworkManager.shared.updateUser(id: savedUUID, name: myName)
                self.myPlayerID = savedUUID
                return savedUUID
            } catch {
                return try await createNewUser()
            }
        } else {
            return try await createNewUser()
        }
    }
    
    private func createNewUser() async throws -> UUID {
        let user = try await NetworkManager.shared.createUser(name: myName)
        self.savedPlayerID = user.id.uuidString
        self.myPlayerID = user.id
        return user.id
    }

    func createGameAndHost() async -> Bool {
        isLoading = true; errorMessage = nil
        do {
            let pID = try await getOrCreateUser()
            let newCode = String((0..<4).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement()! })
            let game = try await NetworkManager.shared.createGame(hostID: pID, joinCode: newCode)
            try await NetworkManager.shared.joinGame(gameID: game.id, playerID: pID)
            
            self.currentGameID = game.id
            self.joinCode = game.joinCode
            self.isHost = true
            isLoading = false
            startPolling()
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func joinGameByCode() async -> Bool {
        isLoading = true; errorMessage = nil
        do {
            let pID = try await getOrCreateUser()
            let foundGame = try await NetworkManager.shared.findGame(by: joinCode)
            
            let pastMessages = try await NetworkManager.shared.fetchMessages(for: foundGame.id)
            if pastMessages.contains(where: { $0.messageType == "sys_game_over" }) {
                self.errorMessage = "Эта игра уже завершена"
                self.isLoading = false
                return false
            }
            
            try await NetworkManager.shared.joinGame(gameID: foundGame.id, playerID: pID)
            
            self.currentGameID = foundGame.id
            self.isHost = (foundGame.host.id == pID)
            
            isLoading = false
            startPolling()
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func startPolling() {
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.fetchLobbyPlayers()
                self?.fetchMessages()
            }
        }
    }
    
    private func fetchLobbyPlayers() {
        guard let gameID = currentGameID else { return }
        Task {
            if let players = try? await NetworkManager.shared.fetchLobbyPlayers(for: gameID) {
                self.playersInLobby = players
                self.calculateScores()
            }
        }
    }
    
    private func fetchMessages() {
        guard let gameID = currentGameID else { return }
        Task {
            if let fetchedMessages = try? await NetworkManager.shared.fetchMessages(for: gameID) {
                self.messages = fetchedMessages
                self.processSystemMessages(fetchedMessages)
                self.calculateScores()
                self.calculateWinningMessages()
            }
        }
    }
    
    func startOnlineGame(with words: [String]) {
        guard isHost else { return }
        self.wordsList = words.shuffled()
        currentTurnIndex = 0
        startNextTurn()
    }
    
    func startNextTurn() {
        guard isHost, !playersInLobby.isEmpty else { return }
        if wordsList.isEmpty {
            sendSystemMessage(type: "sys_game_over", payload: "")
            return
        }
        let explainingPlayer = playersInLobby[currentTurnIndex % playersInLobby.count]
        let word = wordsList.removeLast()
        currentTurnIndex += 1
        sendSystemMessage(type: "sys_start_turn", payload: "\(explainingPlayer.id)|\(word)")
    }
    
    func endGameEarly() {
        guard isHost else { return }
        self.isGameOver = true
        sendSystemMessage(type: "sys_game_over", payload: "")
    }
    
    func sendChatMessage(_ text: String) {
        sendSystemMessage(type: "chat", payload: text)
    }
    
    private func sendSystemMessage(type: String, payload: String) {
        guard let gameID = currentGameID, let playerID = myPlayerID else { return }
        let request = CreateMessageRequest(messageType: type, payload: payload, gameID: gameID, playerID: playerID)
        Task { try? await NetworkManager.shared.sendMessage(request: request) }
    }
    
    private func processSystemMessages(_ newMessages: [MessageDTO]) {
        for msg in newMessages {
            if processedMessageIDs.contains(msg.id) { continue }
            processedMessageIDs.insert(msg.id)
            
            switch msg.messageType {
            case "sys_start_turn":
                let parts = msg.payload.components(separatedBy: "|")
                if parts.count == 2, let pID = UUID(uuidString: parts[0]) {
                    self.currentWordToExplain = parts[1]
                    self.isMyTurnToExplain = (pID == self.myPlayerID)
                    self.explainPlayerName = playersInLobby.first(where: { $0.id == pID })?.userName ?? "Кто-то"
                    self.isTurnFinished = false
                    self.isGameStarted = true
                }
            case "sys_end_turn":
                if let winnerID = UUID(uuidString: msg.payload) {
                    self.lastWinnerName = playersInLobby.first(where: { $0.id == winnerID })?.userName ?? "Кто-то"
                    self.lastGuessedWord = self.currentWordToExplain
                    self.isTurnFinished = true
                }
            case "sys_game_over":
                self.isGameOver = true
            case "chat":
                if isMyTurnToExplain && msg.player.id != self.myPlayerID && !self.isTurnFinished {
                    if normalize(msg.payload) == normalize(currentWordToExplain) {
                        self.isTurnFinished = true
                        sendSystemMessage(type: "sys_end_turn", payload: msg.player.id.uuidString)
                    }
                }
            default: break
            }
        }
    }
    
    private func calculateScores() {
        var scores: [UUID: Int] = [:]
        for player in playersInLobby { scores[player.id] = 0 }
        
        for msg in messages where msg.messageType == "sys_end_turn" {
            if let guesserID = UUID(uuidString: msg.payload) {
                scores[guesserID, default: 0] += 1
            }
        }
        
        var newFinalScores: [(name: String, score: Int)] = []
        for (id, score) in scores {
            let name = playersInLobby.first(where: { $0.id == id })?.userName ?? "Неизвестный"
            newFinalScores.append((name: name, score: score))
        }
        self.finalScores = newFinalScores.sorted { $0.score > $1.score }
    }
    
    private func calculateWinningMessages() {
        var winners = Set<UUID>()
        var currentTarget: String? = nil
        var isRoundActive = false
        
        let sortedAll = messages.sorted { ($0.createdAt ?? "") < ($1.createdAt ?? "") }
        
        for msg in sortedAll {
            if msg.messageType == "sys_start_turn" {
                let parts = msg.payload.components(separatedBy: "|")
                if parts.count == 2 {
                    currentTarget = parts[1]
                    isRoundActive = true
                }
            } else if msg.messageType == "sys_end_turn" || msg.messageType == "sys_game_over" {
                isRoundActive = false
                currentTarget = nil
            } else if msg.messageType == "chat" && isRoundActive {
                if let target = currentTarget, normalize(msg.payload) == normalize(target) {
                    winners.insert(msg.id)
                    isRoundActive = false
                }
            }
        }
        self.winningMessageIDs = winners
    }
    
    func getPlayerName(by id: UUID) -> String {
        return playersInLobby.first(where: { $0.id == id })?.userName ?? "Игрок"
    }
    
    var displayMessages: [MessageDTO] {
        messages.filter { $0.messageType == "chat" }.sorted(by: { ($0.createdAt ?? "") < ($1.createdAt ?? "") })
    }
    
    private func normalize(_ text: String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().replacingOccurrences(of: "ё", with: "е")
    }
    
    func leaveGame() {
        let gameIDToKill = currentGameID
        let wasHost = isHost
        
        if wasHost && gameIDToKill != nil && !isGameOver {
            sendSystemMessage(type: "sys_game_over", payload: "")
        }
        
        if wasHost, let gameID = gameIDToKill {
            Task {
                try? await NetworkManager.shared.deleteGame(gameID: gameID)
            }
        }
        
        pollingTimer?.invalidate()
        pollingTimer = nil
        currentGameID = nil
        joinCode = ""
        isHost = false
        playersInLobby.removeAll()
        messages.removeAll()
        processedMessageIDs.removeAll()
        wordsList.removeAll()
        currentTurnIndex = 0
        isGameStarted = false
        isMyTurnToExplain = false
        currentWordToExplain = ""
        explainPlayerName = ""
        isTurnFinished = false
        lastGuessedWord = ""
        lastWinnerName = ""
        isGameOver = false
        finalScores.removeAll()
        winningMessageIDs.removeAll()
    }
}
