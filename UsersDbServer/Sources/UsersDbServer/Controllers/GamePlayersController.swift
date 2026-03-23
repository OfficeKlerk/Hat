//
// GamePlayersController.swift
// UsersDbServer
//
// Created by OpenAI on 08.03.2026.
//

import Vapor
import Fluent

//контроллер для участников игровых комнат
struct GamePlayersController: RouteCollection {
    //регистрирует роуты для участников игровых комнат
    func boot(routes: any RoutesBuilder) throws {
        let gamePlayers = routes.grouped("game-players")
        gamePlayers.get(use: getAll)
        gamePlayers.post(use: create)
        gamePlayers.group(":gamePlayerID") { gamePlayer in
            gamePlayer.get(use: getById)
            gamePlayer.put(use: update)
            gamePlayer.delete(use: delete)
        }
    }

    //получает всех участников игровых комнат
    func getAll(req: Request) async throws -> Response {
        let gamePlayers = try await GamePlayer.query(on: req.db).all()
        return try req.ok(gamePlayers)
    }

    //получает участника игровой комнаты по id
    func getById(req: Request) async throws -> Response {
        guard let gamePlayer = try await GamePlayer.find(req.parameters.get("gamePlayerID"), on: req.db) else {
            return try req.fail("Game player not found", status: .notFound)
        }
        return try req.ok(gamePlayer)
    }

    //создает участника игровой комнаты
    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(CreateGamePlayerRequest.self)
        let teamName = input.teamName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !teamName.isEmpty else {
            return try req.fail("teamName is empty", status: .badRequest)
        }
        
        guard let _ = try await Game.find(input.gameID, on: req.db) else {
            return try req.fail("Game not found", status: .notFound)
        }
        
        guard let _ = try await User.find(input.playerID, on: req.db) else {
            return try req.fail("Player not found", status: .notFound)
        }
        
        let existingGamePlayer = try await GamePlayer.query(on: req.db)
            .filter(\.$game.$id == input.gameID)
            .filter(\.$player.$id == input.playerID)
            .first()
        
        guard existingGamePlayer == nil else {
            return try req.fail("Player already joined the game", status: .conflict)
        }
        
        let gamePlayer = GamePlayer(
            teamName: teamName,
            gameID: input.gameID,
            playerID: input.playerID
        )
        
        try await gamePlayer.save(on: req.db)
        return try req.ok(gamePlayer, status: .created)
    }

    //удаляет участника игровой комнаты по id
    func delete(req: Request) async throws -> Response {
        guard let gamePlayer = try await GamePlayer.find(req.parameters.get("gamePlayerID"), on: req.db) else {
            return try req.fail("Game player not found", status: .notFound)
        }
        
        try await gamePlayer.delete(on: req.db)
        return try req.ok(["message": "Game player deleted"])
    }
    
    //обновляет участника игровой комнаты
    func update(req: Request) async throws -> Response {
        guard let gamePlayer = try await GamePlayer.find(req.parameters.get("gamePlayerID"), on: req.db) else {
            return try req.fail("Game player not found", status: .notFound)
        }

        let input = try req.content.decode(UpdateGamePlayerRequest.self)
        let teamName = input.teamName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !teamName.isEmpty else {
            return try req.fail("teamName is empty", status: .badRequest)
        }
        
        guard let _ = try await Game.find(input.gameID, on: req.db) else {
            return try req.fail("Game not found", status: .notFound)
        }
        
        guard let _ = try await User.find(input.playerID, on: req.db) else {
            return try req.fail("Player not found", status: .notFound)
        }
        
        let existingGamePlayer = try await GamePlayer.query(on: req.db)
            .filter(\.$game.$id == input.gameID)
            .filter(\.$player.$id == input.playerID)
            .first()
        
        if let existingGamePlayer {
            guard existingGamePlayer.id == gamePlayer.id else {
                return try req.fail("Player already joined the game", status: .conflict)
            }
        }
        
        gamePlayer.teamName = teamName
        gamePlayer.$game.id = input.gameID
        gamePlayer.$player.id = input.playerID
        
        try await gamePlayer.save(on: req.db)
        return try req.ok(gamePlayer)
    }
}
