import Vapor
import Authentication
import Crypto

public func routes(_ router: Router) throws {
    let api = router.grouped("api").grouped(ServerErrorMiddleware())
    try api.register(collection: UserController())
}
