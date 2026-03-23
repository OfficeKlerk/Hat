import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case serverError(String)
    case decodingError
    case gameNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный URL"
        case .serverError(let msg): return msg
        case .decodingError: return "Ошибка чтения данных с сервера"
        case .gameNotFound: return "Игра с таким кодом не найдена"
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "http://62.233.43.45:8080"
    
    private init() {}
    
    private var decoder: JSONDecoder { return JSONDecoder() }
    private var encoder: JSONEncoder { return JSONEncoder() }
    
    private func postRequest<T: Codable, U: Codable>(endpoint: String, body: T) async throws -> U {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.serverError("Нет ответа") }
        let serverResponse = try decoder.decode(ServerResponse<U>.self, from: data)
        
        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            if let responseData = serverResponse.data { return responseData }
            throw NetworkError.decodingError
        } else {
            throw NetworkError.serverError(serverResponse.message ?? "Ошибка сервера")
        }
    }
    
    private func putRequest<T: Codable, U: Codable>(endpoint: String, body: T) async throws -> U {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.serverError("Нет ответа") }
        let serverResponse = try decoder.decode(ServerResponse<U>.self, from: data)
        
        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            if let responseData = serverResponse.data { return responseData }
            throw NetworkError.decodingError
        } else {
            throw NetworkError.serverError(serverResponse.message ?? "Ошибка сервера")
        }
    }
    
    // ДОБАВЛЕНО: Базовый метод для удаления
    private func deleteRequest(endpoint: String) async throws {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.serverError("Нет ответа") }
        
        if !(200...299).contains(httpResponse.statusCode) {
            throw NetworkError.serverError("Ошибка сервера при удалении (код \(httpResponse.statusCode))")
        }
    }
    
    func createUser(name: String) async throws -> UserDTO {
        let request = CreateUserRequest(userName: name)
        return try await postRequest(endpoint: "/users", body: request)
    }
    
    func updateUser(id: UUID, name: String) async throws -> UserDTO {
        let request = UpdateUserRequest(userName: name)
        return try await putRequest(endpoint: "/users/\(id)", body: request)
    }
    
    func createGame(hostID: UUID, joinCode: String) async throws -> GameDTO {
        let request = CreateGameRequest(joinCode: joinCode, hostID: hostID, status: "active")
        return try await postRequest(endpoint: "/games", body: request)
    }
    
    func findGame(by joinCode: String) async throws -> GameDTO {
        guard let url = URL(string: "\(baseURL)/games") else { throw NetworkError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        let serverResponse = try decoder.decode(ServerResponse<[GameDTO]>.self, from: data)
        
        guard let games = serverResponse.data,
              let foundGame = games.first(where: { $0.joinCode.uppercased() == joinCode.uppercased() }) else {
            throw NetworkError.gameNotFound
        }
        return foundGame
    }
    
    func joinGame(gameID: UUID, playerID: UUID) async throws {
        let request = CreateGamePlayerRequest(gameID: gameID, playerID: playerID, teamName: "Default")
        do {
            let _: GamePlayerResponseDTO = try await postRequest(endpoint: "/game-players", body: request)
        } catch NetworkError.serverError(let msg) {
            if msg.lowercased().contains("already joined") { return }
            throw NetworkError.serverError(msg)
        }
    }
    
    func fetchLobbyPlayers(for gameID: UUID) async throws -> [UserDTO] {
        guard let gpUrl = URL(string: "\(baseURL)/game-players") else { throw NetworkError.invalidURL }
        let (gpData, _) = try await URLSession.shared.data(from: gpUrl)
        let gpResponse = try decoder.decode(ServerResponse<[GamePlayerResponseDTO]>.self, from: gpData)
        
        let playerIDsInOurGame = (gpResponse.data ?? [])
            .filter { $0.game.id == gameID }
            .map { $0.player.id }
        
        guard let usersUrl = URL(string: "\(baseURL)/users") else { throw NetworkError.invalidURL }
        let (usersData, _) = try await URLSession.shared.data(from: usersUrl)
        let usersResponse = try decoder.decode(ServerResponse<[UserDTO]>.self, from: usersData)
        
        return (usersResponse.data ?? []).filter { playerIDsInOurGame.contains($0.id) }
    }
    
    func sendMessage(request: CreateMessageRequest) async throws -> MessageDTO {
        return try await postRequest(endpoint: "/messages", body: request)
    }
    
    func fetchMessages(for gameID: UUID) async throws -> [MessageDTO] {
        guard let url = URL(string: "\(baseURL)/messages") else { throw NetworkError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        let serverResponse = try decoder.decode(ServerResponse<[MessageDTO]>.self, from: data)
        
        return (serverResponse.data ?? []).filter { $0.game.id == gameID }
    }
    
    func deleteGame(gameID: UUID) async throws {
        try await deleteRequest(endpoint: "/games/\(gameID.uuidString)")
    }
}
