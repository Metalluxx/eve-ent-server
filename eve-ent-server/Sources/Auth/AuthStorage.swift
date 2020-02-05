import Foundation
import Vapor
import Core

protocol AuthStorageObject {}

final class AuthStorage: Service {
    private var storage = [ObjectIdentifier: Any]()
    
    subscript<A>(_ type: A.Type) -> A?  where A: AuthStorageObject {
        get { storage[ObjectIdentifier(A.self)] as? A }
        set { storage[ObjectIdentifier(A.self)] = newValue }
    }
}


extension Request {
    func authenticate<A>(_ instance: A) throws where A: AuthStorageObject {
        let cache = try privateContainer.make(AuthStorage.self)
        cache[A.self] = instance
    }
    
    func unauthenticate<A>(_ type: A.Type = A.self) throws where A: AuthStorageObject {
        let cache = try privateContainer.make(AuthStorage.self)
        cache[A.self] = nil
    }
    
    func authenticated<A>(_ type: A.Type = A.self) throws -> A? where A: AuthStorageObject {
        let cache = try privateContainer.make(AuthStorage.self)
        return cache[A.self]
    }
    
    func isAuthenticated<A>(_ type: A.Type = A.self) throws -> Bool where A: AuthStorageObject {
        return try authenticated(A.self) != nil
    }
    
    func requireAuthenticated<A>(_ type: A.Type = A.self) throws -> A where A: AuthStorageObject {
        guard let a = try authenticated(A.self) else {
            throw AuthError(
                identifier: "ahahah",
                reason: "aaaaaaa",
                source: .caprute()
            )
            
        }
    }
}
