//
//  CreateUser.swift
//  UsersDbServer
//
//  Created by Леон Слободян on 01.02.2026.
//

import Fluent

//миграция создает пользователя в таблице "users", в случае отката миграции удаляет пользователя
struct CreateUser: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("user_name", .string, .required)
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}
