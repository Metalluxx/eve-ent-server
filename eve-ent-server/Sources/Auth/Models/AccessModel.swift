import Foundation
import Fluent
import Vapor

protocol AccessToken {
    associatedtype RefreshTokenType
    associatedtype RefreshTokenIDType
    typealias RefreshTokenIDKey = WritableKeyPath<Self, RefreshTokenIDType>
    static var refreshTokenIDKey: RefreshTokenIDKey { get }
}

extension Model where Self: AccessToken, Self.RefreshTokenType: Model {
    typealias RefreshTokenIDKey = RefreshTokenType.ID
}

protocol AccessTokenAuthenticatable {
    associatedtype AccessTokenType: AccessToken
        where AccessTokenType.RefreshTokenType == Self
    
    static func authenticate(token: AccessTokenType, on connection: DatabaseConnectable) -> Future<Self?>
}

extension AccessTokenAuthenticatable
where
    Self: Model,
    Self.AccessTokenType: Model,
    Self.AccessTokenType.Database == Self.Database,
    Self.AccessTokenType.RefreshTokenIDType == Self.ID
{
    static func authenticate(
        accessToken: AccessTokenType,
        on connection: DatabaseConnectable)
        -> Future<Self?>
    {
        accessToken.refreshToken.get(on: connection).map { $0 }
    }
    
    var accessTokens: Children<Self, AccessTokenType> {
        children(AccessTokenType.refreshTokenIDKey)
    }
    
}

extension AccessToken
where
    Self: Model,
    Self.RefreshTokenType: Model,
    Self.RefreshTokenType.Database == Self.Database,
    Self.RefreshTokenIDType == Self.RefreshTokenType.ID
{
    var refreshToken: Parent<Self, RefreshTokenType> {
        parent(Self.refreshTokenIDKey)
    }
}


