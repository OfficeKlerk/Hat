//
//  ApiResponses.swift
//  UsersDbServer
//
//  Created by Леон Слободян on 01.02.2026.
//
import Vapor


//единый формат ошибки
struct ErrorResponse: Content {
    let error: Bool
    let message: String
}

//единый формат успеха
struct SuccessResponse<T: Content>: Content {
    let success: Bool
    let data: T
}
