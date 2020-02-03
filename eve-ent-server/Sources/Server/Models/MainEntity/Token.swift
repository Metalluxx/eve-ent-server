//
//  File.swift
//  
//
//  Created by Metalluxx on 17.12.2019.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

// MARK: - Main struct
public struct Token {
    public var id: Int?
    public var token: String
    public var userId: User.ID
    
    public init(id: Int? = nil, token: String, userId: User.ID) {
        self.id = id
        self.token = token
        self.userId = userId
    }
}

// MARK: - Vapor extensions
extension Token: Content {}
extension Token: MySQLModel {}
extension Token: MySQLMigration {}

// MARK: - Token extensions
extension Token: BearerAuthenticatable {
    public static var tokenKey: WritableKeyPath<Token, String> {
        return \.token
    }
}

extension Token: Authentication.Token {
    public typealias UserType = User
    public typealias UserIDType = User.ID
    public static var userIDKey: WritableKeyPath<Token, User.ID> {
        return \.userId
    }
}


// MARK: - Public struct
public extension Token {
    struct Public: Content {
        public var token: String
        public var developer: User.Public
        
        public init(token: String, developer: User.Public) {
            self.token = token
            self.developer = developer
        }
    }
}

public extension EventLoopFuture where T == Token {
    func createPublic(for developer: User) -> EventLoopFuture<Token.Public>{
        return self.map { (token) in
            return Token.Public(token: token.token, developer: developer.public)
        }
    }
}
