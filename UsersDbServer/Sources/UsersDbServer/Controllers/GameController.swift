//
// GameController.swift
// UsersDbServer
//
// Created by OpenAI on 08.03.2026.
//

import Vapor
import Fluent

//контроллер для игровых комнат
struct GameController: RouteCollection {
    //регистрирует роуты для игровых комнат
    func boot(routes: any RoutesBuilder) throws {
        let games = routes.grouped("games")
        games.get(use: getAll)
        games.post(use: create)
        games.group(":gameID") { game in
            game.get(use: getById)
            game.put(use: update)
            game.delete(use: delete)
        }
    }

    //получает все игровые комнаты
    func getAll(req: Request) async throws -> Response {
        let games = try await Game.query(on: req.db).all()
        return try req.ok(games)
    }

    //получает игровую комнату по id
    func getById(req: Request) async throws -> Response {
        guard let game = try await Game.find(req.parameters.get("gameID"), on: req.db) else {
            return try req.fail("Game not found", status: .notFound)
        }
        return try req.ok(game)
    }

    //создает игровую комнату
    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(CreateGameRequest.self)
        let joinCode = input.joinCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let status = input.status.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !joinCode.isEmpty else {
            return try req.fail("joinCode is empty", status: .badRequest)
        }
        
        guard !status.isEmpty else {
            return try req.fail("status is empty", status: .badRequest)
        }
        
        guard let _ = try await User.find(input.hostID, on: req.db) else {
            return try req.fail("Host not found", status: .notFound)
        }
        
        let existingGame = try await Game.query(on: req.db)
            .filter(\.$joinCode == joinCode)
            .first()
        
        guard existingGame == nil else {
            return try req.fail("joinCode already exists", status: .conflict)
        }
        
        let game = Game(
            joinCode: joinCode,
            status: status,
            hostID: input.hostID
        )
        
        try await game.save(on: req.db)
        return try req.ok(game, status: .created)
    }

    //удаляет игровую комнату по id
    func delete(req: Request) async throws -> Response {
        guard let game = try await Game.find(req.parameters.get("gameID"), on: req.db) else {
            return try req.fail("Game not found", status: .notFound)
        }
        
        try await game.delete(on: req.db)
        return try req.ok(["message": "Game deleted"])
    }
    
    //обновляет игровую комнату
    func update(req: Request) async throws -> Response {
        guard let game = try await Game.find(req.parameters.get("gameID"), on: req.db) else {
            return try req.fail("Game not found", status: .notFound)
        }

        let input = try req.content.decode(UpdateGameRequest.self)
        let joinCode = input.joinCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let status = input.status.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !joinCode.isEmpty else {
            return try req.fail("joinCode is empty", status: .badRequest)
        }
        
        guard !status.isEmpty else {
            return try req.fail("status is empty", status: .badRequest)
        }
        
        guard let _ = try await User.find(input.hostID, on: req.db) else {
            return try req.fail("Host not found", status: .notFound)
        }
        
        let existingGame = try await Game.query(on: req.db)
            .filter(\.$joinCode == joinCode)
            .first()
        
        if let existingGame {
            guard existingGame.id == game.id else {
                return try req.fail("joinCode already exists", status: .conflict)
            }
        }
        
        game.joinCode = joinCode
        game.status = status
        game.$host.id = input.hostID
        
        try await game.save(on: req.db)
        return try req.ok(game)
    }
}
