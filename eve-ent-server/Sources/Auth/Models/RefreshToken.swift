import Foundation
import Fluent
import Vapor

protocol RefreshToken {
    associatedtype UserType: User
    associatedtype UserIDType
    typealias UserIDKey = WritableKeyPath<Self, UserIDType>
    static var userIDKey: UserIDKey { get }
}

extension Model where Self: RefreshToken, Self.UserType: Model {
    typealias UserIDTypes = UserType.ID
}

protocol RefreshTokenAuthenticatable {
    associatedtype RefreshTokenType: RefreshToken
        where RefreshTokenType.UserIDType == Self
    
    static func authenticate(refreshToken: RefreshTokenType, on connection: DatabaseConnectable) -> Future<Self?>
}

extension RefreshTokenAuthenticatable
where
    Self: Model,
    Self.RefreshTokenType: Model,
    Self.RefreshTokenType.UserType == Self,
    Self.RefreshTokenType.Database == Self.Database,
    Self.RefreshTokenType.UserIDType == Self.ID
{
    static func authenticate(
        refreshToken: RefreshTokenType,
        on connection: DatabaseConnectable)
        -> Future<Self?>
    {
        refreshToken.users.get(on: connection).map { $0 }
    }
    
    var refreshTokens: Children<Self, RefreshTokenType> {
        children(RefreshTokenType.userIDKey)
    }
}

extension RefreshToken
where
    Self: Model,
    Self.UserType: Model,
    Self.UserType.Database == Self.Database,
    Self.UserIDType == Self.UserType.ID
{
    var users: Parent<Self, UserType> {
        parent(Self.userIDKey)
    }
}
