//
//  Game.swift
//  UsersDbServer
//
//  Created by OpenAI on 08.03.2026.
//

import Fluent
import Vapor

// игровая комната
final class Game: Model, Content, @unchecked Sendable {
    // fluent понимает, с какой таблицей связана модель
    static let schema = "games"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "join_code")
    var joinCode: String
    
    @Field(key: "status")
    var status: String
    
    @Field(key: "created_at")
    var createdAt: Date
    
    // ссылка на хоста комнаты
    @Parent(key: "host_id")
    var host: User
    
    // ссылки на участников комнаты
    @Children(for: \.$game)
    var gamePlayers: [GamePlayer]
    
    init() {}
    
    init(
        id: UUID? = nil,
        joinCode: String,
        status: String,
        createdAt: Date = Date(),
        hostID: User.IDValue
    ) {
        self.id = id
        self.joinCode = joinCode
        self.status = status
        self.createdAt = createdAt
        self.$host.id = hostID
    }
}
