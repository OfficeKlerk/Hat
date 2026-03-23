import Foundation

struct ServerResponse<T: Codable>: Codable {
    let success: Bool?
    let error: Bool?
    let message: String?
    let data: T?
}

struct ParentRef: Codable {
    let id: UUID
}

struct UserDTO: Codable, Identifiable {
    let id: UUID
    let userName: String
}

struct GameDTO: Codable, Identifiable {
    let id: UUID
    let joinCode: String
    let status: String
    let host: ParentRef
}

struct GamePlayerResponseDTO: Codable, Identifiable {
    let id: UUID
    let teamName: String
    let game: ParentRef
    let player: ParentRef
}

struct MessageDTO: Codable, Identifiable {
    let id: UUID
    let messageType: String
    let payload: String
    let createdAt: String?
    let game: ParentRef
    let player: ParentRef
}

struct CreateUserRequest: Codable {
    let userName: String
}

struct UpdateUserRequest: Codable {
    let userName: String
}

struct CreateGameRequest: Codable {
    let joinCode: String
    let hostID: UUID
    let status: String
}

struct CreateGamePlayerRequest: Codable {
    let gameID: UUID
    let playerID: UUID
    let teamName: String
}

struct CreateMessageRequest: Codable {
    let messageType: String
    let payload: String
    let gameID: UUID
    let playerID: UUID
}
