//
//  UserMessage.swift
//  UsersDbServer
//
//  Created by Леон Слободян on 01.02.2026.
//

import Fluent
import Vapor

// модель "message"
final class UserMessage: Model, Content, @unchecked Sendable {
    // модель связана с таблицей "messages"
    static let schema = "messages"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "message_type")
    var messageType: String
    
    @Field(key: "payload")
    var payload: String
    
    @Field(key: "created_at")
    var createdAt: Date
    
    // ссылка на игру
    @Parent(key: "game_id")
    var game: Game
    
    // ссылка на игрока
    @Parent(key: "player_id")
    var player: User
    
    init() {}
    
    init(
        id: UUID? = nil,
        messageType: String,
        payload: String,
        createdAt: Date = Date(),
        gameID: Game.IDValue,
        playerID: User.IDValue
    ) {
        self.id = id
        self.messageType = messageType
        self.payload = payload
        self.createdAt = createdAt
        self.$game.id = gameID
        self.$player.id = playerID
    }
}
