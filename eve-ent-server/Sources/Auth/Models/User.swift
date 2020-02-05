import Foundation
import Fluent
import Vapor

protocol User {
    associatedtype UserIDType
    typealias UserIDKey = WritableKeyPath<Self, UserIDType>
    static var userIDKey: UserIDKey { get }
}

extension Model where Self: User {
    typealias UserIDType = ID
}
