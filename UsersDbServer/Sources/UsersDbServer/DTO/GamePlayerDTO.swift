//
//  GamePlayerDTO.swift
//  UsersDbServer
//
//  Created by OpenAI on 08.03.2026.
//

import Vapor

//данные для добавления участника в комнату
struct CreateGamePlayerRequest: Content {
    let gameID: UUID
    let playerID: UUID
    let teamName: String
}

//данные для обновления участника комнаты
struct UpdateGamePlayerRequest: Content {
    let gameID: UUID
    let playerID: UUID
    let teamName: String
}
