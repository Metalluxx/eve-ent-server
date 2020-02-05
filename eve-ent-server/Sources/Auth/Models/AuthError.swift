import Foundation
import Vapor


struct AuthError: Debuggable {
    static var readableName: String = "Auth Error"
    
    var identifier: String
    var reason: String
    var sourceLocation: SourceLocation?
    var stackTrace: [String]?
    
    init(
        identifier: String,
        reason: String,
        source: SourceLocation
    ) {
        self.identifier = identifier
        self.reason = reason
        self.sourceLocation = source
        self.stackTrace = AuthError.makeStackTrace()
    }
}

extension AuthError: AbortError {
    var status: HTTPResponseStatus {
        .unauthorized
    }
}
