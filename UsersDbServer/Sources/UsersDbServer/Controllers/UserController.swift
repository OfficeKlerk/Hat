//
//  UserController.swift
//  UsersDbServer
//
//  Created by Леон Слободян on 01.02.2026.
//

import Vapor
import Fluent

//контроллер для юзеров
struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        
        //регистрируем роуты
        let users = routes.grouped("users")
        users.get(use: getAll)                     //GET /users
        users.post(use: create)                    //POST /users
        users.group(":userID") { user in
            user.get(use: getById)                 //GET /users/:userID
            user.put(use: update)                  //PUT /users/:userID
            user.delete(use: delete)               //DELETE /users/:userID
        }
    }

    //получение всех юзеров
    func getAll(req: Request) async throws -> Response {
        let users = try await User.query(on: req.db).all()
        return try req.ok(users)
    }

    //получение юзера по id
    func getById(req: Request) async throws -> Response {
        //если нашли юзера, то вернем его, иначе кинем ошибку
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            return try req.fail("User not found", status: .notFound)
        }
        return try req.ok(user)
    }

    //создание юзера
    func create(req: Request) async throws -> Response {
        //достаем юзера из запроса
        let input = try req.content.decode(CreateUserRequest.self)
        
        //обрезаем лишнее в строке
        let name = input.userName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !name.isEmpty else {
            return try req.fail("userName is empty", status: .badRequest)
        }

        let user = User(userName: name)
        try await user.save(on: req.db)
        return try req.ok(user, status: .created)
    }

    //удаление юзера по id
    func delete(req: Request) async throws -> Response {
        //если нашли юзера, удалим, иначе кинем исключение
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            return try req.fail("User not found", status: .notFound)
        }
        try await user.delete(on: req.db)
        return try req.ok(["message": "User deleted"])
    }
    
    //обновление юзера
    func update(req: Request) async throws -> Response {
        //ишем юзера
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            return try req.fail("User not found", status: .notFound)
        }

        //достаем нового юзера из параметров
        let input = try req.content.decode(UpdateUserRequest.self)
        let name = input.userName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            return try req.fail("userName is empty", status: .badRequest)
        }

        //обновляем юзера
        user.userName = name
        try await user.save(on: req.db)
        return try req.ok(user)
    }
}
