//
//  UserDTO.swift
//  UsersDbServer
//
//  Created by Леон Слободян on 01.02.2026.
//

import Vapor

struct CreateUserRequest: Content {
    let userName: String
}

struct UpdateUserRequest: Content {
    let userName: String
}
