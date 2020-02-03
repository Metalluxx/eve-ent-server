//
//  File.swift
//  
//
//  Created by Араик Гарибян on 24.12.2019.
//

import Foundation
import Vapor

public final class ServerErrorMiddleware: Middleware {
    public init() {}
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        do {
            return try next.respond(to: request)
                .thenIfError { (error) in
                let dataResponse = DataResponse<String>.failure(message: "\(error)", description: error.localizedDescription)
                return dataResponse.encode(status: .badRequest, for: request)
            }
        } catch {
            let dataResponse = DataResponse<String>.failure(message: "\(error)", description: error.localizedDescription)
            return dataResponse.encode(status: .badRequest, for: request)
        }
    }
}
