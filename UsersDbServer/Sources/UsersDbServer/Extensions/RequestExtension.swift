//
//  RequestExtension.swift
//  UsersDbServer
//
//  Created by Леон Слободян on 01.02.2026.
//

import Vapor

//расширим класс Request для того, чтобы возвращать красивые сообщения
extension Request {
    func ok<T: Content>(_ data: T, status: HTTPStatus = .ok) throws -> Response {
        let body = SuccessResponse(success: true, data: data)
        let res = Response(status: status)
        try res.content.encode(body, as: .json)
        return res
    }

    func fail(_ message: String, status: HTTPStatus) throws -> Response {
        let body = ErrorResponse(error: true, message: message)
        let res = Response(status: status)
        try res.content.encode(body, as: .json)
        return res
    }
}
