//
//  UserMessageDTO.swift
//  UsersDbServer
//
//  Created by Леон Слободян on 01.02.2026.
//

import Vapor

//запрос на создание сообщения
struct CreateMessageRequest: Content {
    let messageType: String
    let payload: String
    let createdAt: Date?
    let gameID: UUID
    let playerID: UUID
}

//запрос на обновление сообщения
struct UpdateMessageRequest: Content {
    let messageType: String
    let payload: String
    let createdAt: Date?
    let gameID: UUID
    let playerID: UUID
}
