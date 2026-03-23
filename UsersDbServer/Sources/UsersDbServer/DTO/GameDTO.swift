//
//  GameDTO.swift
//  UsersDbServer
//
//  Created by OpenAI on 08.03.2026.
//

import Vapor

//данные для создания комнаты
struct CreateGameRequest: Content {
    let joinCode: String
    let hostID: UUID
    let status: String
}

//данные для обновления комнаты
struct UpdateGameRequest: Content {
    let joinCode: String
    let hostID: UUID
    let status: String
}
