//
//  CreateGamePlayer.swift
//  UsersDbServer
//
//  Created by OpenAI on 08.03.2026.
//

import Fluent

//миграция создает участника игровой комнаты в таблице "game_players", при откате удаляет его
struct CreateGamePlayer: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("game_players")
            .id()
            .field("game_id", .uuid, .required, .references("games", "id", onDelete: .cascade))
            .field("player_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("team_name", .string, .required)
            .unique(on: "game_id", "player_id")
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("game_players").delete()
    }
}
