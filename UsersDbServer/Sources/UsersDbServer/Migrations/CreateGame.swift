//
//  CreateGame.swift
//  UsersDbServer
//
//  Created by OpenAI on 08.03.2026.
//

import Fluent

//миграция создает игровую комнату в таблице "games", при откате удаляет ее
struct CreateGame: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("games")
            .id()
            .field("join_code", .string, .required)
            .field("host_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("status", .string, .required)
            .field("created_at", .datetime, .required)
            .unique(on: "join_code")
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("games").delete()
    }
}
