//
//  CreateUserMessage.swift
//  UsersDbServer
//
//  Created by Леон Слободян on 01.02.2026.
//

import Fluent

//миграция создает таблицу "messages", при откате удаляет ее
struct CreateUserMessage: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("messages")
            .id()
            .field("game_id", .uuid, .required, .references("games", "id", onDelete: .cascade))
            .field("player_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("message_type", .string, .required)
            .field("payload", .string, .required)
            .field("created_at", .datetime, .required)
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("messages").delete()
    }
}
