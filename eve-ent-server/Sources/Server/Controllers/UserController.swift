import Foundation
import Vapor
import FluentMySQL
import Crypto
import Random

final public class UserController: RouteCollection {
    public func boot(router: Router) throws {
        router.post(User.RegisterForm.self, at: "register", use: register)
        router.post(User.Login.self, at: "login", use: login)
        
        let authRouter = User.tokenAuthMiddleware()
        router.grouped(authRouter).post("logout", use: logout)
    }
    
    private func register(_ req :Request, _ regForm: User.RegisterForm) throws -> ResponseEventLoopFuture<User.Public> {
        return User
            .query(on: req)
            .filter(\.email == regForm.email)
            .first()
            .flatMap {
                if $0 != nil { throw Error.userAlreadyExists }
                if !regForm.email.isEmail { throw Error.incorrectEmail }
                return try User(registerForm: regForm)
                    .cryptoPassword(on: req)
                    .create(on: req)
                    .map { (developer) in developer.public  }
            }
            .asDataResponse()
    }
    
    private func login(_ req :Request, _ regForm: User.Login) throws -> ResponseEventLoopFuture<Token.Public> {
        return try req
            .content
            .decode(User.Login.self)
            .flatMap { (loginStructure) in
            return User
                .query(on: req)
                .filter(\.email == loginStructure.email)
                .first()
                .unwrap(or: Error.incorrectEmail)
                .flatMap { (fetchedDeveloper) in
                    let hasher = try req.make(BCryptDigest.self)
                    if try hasher.verify(loginStructure.password, created: fetchedDeveloper.password) {
                        let newToken = try URandom().generateData(count: 32).base64EncodedString()
                        let token = try Token(token: newToken, userId: fetchedDeveloper.requireID())
                        return token.save(on: req).createPublic(for: fetchedDeveloper)
                    } else {
                        throw Abort(.unauthorized)
                    }
                }
                .asDataResponse()
        }
    }
    

    private func logout(on req: Request) throws -> EmptyResponseEventLoopFuture {
        let token = try req.requireAuthenticated(Token.self)
        return Token
            .query(on: req)
            .filter(\.id, .equal, try token.requireID())
            .delete()
            .asDataResponse()
    }
}

public extension UserController {
    enum Error: String, Swift.Error {
        case userAlreadyExists = "This user already exists"
        case incorrectEmail = "You entered an invalid email"
    }
}


fileprivate extension User {
    func cryptoPassword(on req: Request) throws -> User {
        var developer = self
        let hasher = try req.make(BCryptDigest.self)
        developer.password = try hasher.hash(developer.password)
        return developer
    }
}
