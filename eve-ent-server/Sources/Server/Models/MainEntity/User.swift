import Foundation
import FluentMySQL
import Vapor
import Authentication

public struct User {
    public var id: Int?
    public var name: String
    public var email: String
    public var password: String
    
    public init(id: Int? = nil, name: String, email: String, password: String) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
    }
    
}

extension User: Content {}
extension User: MySQLModel {}
extension User: MySQLMigration {}
extension User: Parameter {}

extension User: TokenAuthenticatable {
    public typealias TokenType = Token
}

public extension User {
    struct Public: Content {
        public let name: String
        
        public init(name: String) {
            self.name = name
        }
    }
    
    var `public`: Public {
        return Public(name: self.name)
    }
}

public extension User {
    struct Login: Content {
        public let email: String
        public let password: String
        
        public init(email: String, password: String) {
            self.email = email
            self.password = password
        }
    }
    
    var login: Login {
        return Login(email: self.email, password: self.password)
    }
}

public extension User {
    struct RegisterForm: Content {
        public var email: String
        public var name: String
        public var password: String
    }
    
    init(registerForm: RegisterForm) {
        self = User(
            name: registerForm.name,
            email: registerForm.email,
            password: registerForm.password)
    }
}
