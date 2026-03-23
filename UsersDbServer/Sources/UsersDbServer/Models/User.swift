//
//  User.swift
//  UsersDbServer
//
//  Created by Леон Слободян on 01.02.2026.
//

import Fluent
import Vapor

//пользователь
final class User: Model, Content, @unchecked Sendable {
    //fluent с помощью schema узнает, с какой таблицей связана модель
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "user_name")
    var userName: String
    
    // ссылки на записи в таблице "messages"
    @Children(for: \.$player)
    var messages: [UserMessage]
    
    init() {}
    
    init(id: UUID? = nil, userName: String){
        self.id = id
        self.userName = userName
    }
}
