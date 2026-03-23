//
//  GamePlayer.swift
//  UsersDbServer
//
//  Created by OpenAI on 08.03.2026.
//

import Fluent
import Vapor

// участник игровой комнаты
final class GamePlayer: Model, Content, @unchecked Sendable {
    // fluent понимает, с какой таблицей связана модель
    static let schema = "game_players"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "team_name")
    var teamName: String
    
    // ссылка на игру
    @Parent(key: "game_id")
    var game: Game
    
    // ссылка на игрока
    @Parent(key: "player_id")
    var player: User
    
    init() {}
    
    init(
        id: UUID? = nil,
        teamName: String,
        gameID: Game.IDValue,
        playerID: User.IDValue
    ) {
        self.id = id
        self.teamName = teamName
        self.$game.id = gameID
        self.$player.id = playerID
    }
}
