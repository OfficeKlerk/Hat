//
//  UsersMessagesController.swift
//  UsersDbServer
//
//  Created by Леон Слободян on 01.02.2026.
//

import Vapor
import Fluent

//контроллер для сообщений игроков
struct UserMessagesController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        
        //регистрируем роуты
        let messages = routes.grouped("messages")
        messages.get(use: getAll)
        messages.post(use: create)
        messages.group(":messageID") { message in
            message.get(use: getById)
            message.put(use: update)
            message.delete(use: delete)
        }
    }

    //получение всех сообщений
    func getAll(req: Request) async throws -> Response {
        let messages = try await UserMessage.query(on: req.db).all()
        return try req.ok(messages)
    }

    //получение сообщения по id
    func getById(req: Request) async throws -> Response {
        guard let message = try await UserMessage.find(req.parameters.get("messageID"), on: req.db) else {
            return try req.fail("Message not found", status: .notFound)
        }
        return try req.ok(message)
    }

    //создание сообщения
    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(CreateMessageRequest.self)
        let messageType = input.messageType.trimmingCharacters(in: .whitespacesAndNewlines)
        let payload = input.payload.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !messageType.isEmpty else {
            return try req.fail("messageType is empty", status: .badRequest)
        }
        
        guard !payload.isEmpty else {
            return try req.fail("payload is empty", status: .badRequest)
        }
        
        guard let _ = try await Game.find(input.gameID, on: req.db) else {
            return try req.fail("Game not found", status: .notFound)
        }
        
        guard let _ = try await User.find(input.playerID, on: req.db) else {
            return try req.fail("Player not found", status: .notFound)
        }
        
        let gamePlayer = try await GamePlayer.query(on: req.db)
            .filter(\.$game.$id == input.gameID)
            .filter(\.$player.$id == input.playerID)
            .first()
        
        guard let _ = gamePlayer else {
            return try req.fail("Player is not in this game", status: .badRequest)
        }
        
        let message = UserMessage(
            messageType: messageType,
            payload: payload,
            createdAt: input.createdAt ?? Date(),
            gameID: input.gameID,
            playerID: input.playerID
        )
        
        try await message.save(on: req.db)
        return try req.ok(message, status: .created)
    }

    //удаление сообщения по id
    func delete(req: Request) async throws -> Response {
        guard let message = try await UserMessage.find(req.parameters.get("messageID"), on: req.db) else {
            return try req.fail("Message not found", status: .notFound)
        }
        
        try await message.delete(on: req.db)
        return try req.ok(["message": "Message deleted"])
    }
    
    //обновление сообщения
    func update(req: Request) async throws -> Response {
        guard let message = try await UserMessage.find(req.parameters.get("messageID"), on: req.db) else {
            return try req.fail("Message not found", status: .notFound)
        }

        let input = try req.content.decode(UpdateMessageRequest.self)
        let messageType = input.messageType.trimmingCharacters(in: .whitespacesAndNewlines)
        let payload = input.payload.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !messageType.isEmpty else {
            return try req.fail("messageType is empty", status: .badRequest)
        }
        
        guard !payload.isEmpty else {
            return try req.fail("payload is empty", status: .badRequest)
        }
        
        guard let _ = try await Game.find(input.gameID, on: req.db) else {
            return try req.fail("Game not found", status: .notFound)
        }
        
        guard let _ = try await User.find(input.playerID, on: req.db) else {
            return try req.fail("Player not found", status: .notFound)
        }
        
        let gamePlayer = try await GamePlayer.query(on: req.db)
            .filter(\.$game.$id == input.gameID)
            .filter(\.$player.$id == input.playerID)
            .first()
        
        guard let _ = gamePlayer else {
            return try req.fail("Player is not in this game", status: .badRequest)
        }

        message.messageType = messageType
        message.payload = payload
        message.$game.id = input.gameID
        message.$player.id = input.playerID
        
        if let newCreatedAt = input.createdAt {
            message.createdAt = newCreatedAt
        }
        
        try await message.save(on: req.db)
        return try req.ok(message)
    }
}
