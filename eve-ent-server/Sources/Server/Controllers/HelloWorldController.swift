import Foundation
import Vapor

final class HelloWorldController: RouteCollection {
    func boot(router: Router) throws {
        let authRouter = router.grouped(AuthMiddlware.self)
        
        authRouter.get("hw") { (req) in
            req.eventLoop.future().map { _ in return "Hello World" }
        }
    }
}
