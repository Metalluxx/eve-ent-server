//
//  File.swift
//  
//
//  Created by Metalluxx on 12.12.2019.
//

import Foundation
import Vapor

public struct DataResponse<T: Codable>: Content {
    public let success: Bool
    public let data: T?
    public let errorMessage: String?
    public let errorDescription: String?
    
    private init(
        success: Bool,
        data: T?,
        errorMessage: String?,
        errorDescription: String?)
    {
        self.success = success
        self.data = data
        self.errorMessage = errorMessage
        self.errorDescription = errorDescription
    }
    
    public static func success(data: T) -> DataResponse<T> {
        return DataResponse(success: true, data: data, errorMessage: nil, errorDescription: nil)
    }
    
    public static func failure(message: String?, description: String?) -> DataResponse<T> {
        return DataResponse(success: false, data: nil, errorMessage: message, errorDescription: description)
    }
}

// MARK: EvenLoopFuture extensions
public typealias ResponseEventLoopFuture<T: Codable> = EventLoopFuture<DataResponse<T>>
public typealias EmptyResponseEventLoopFuture = EventLoopFuture<DataResponse<String>>

public extension EventLoopFuture {
    func asDataResponse(info: String = "") -> EmptyResponseEventLoopFuture {
        return self.asDataResponse(info: { _ in return info })
    }
    
    func asDataResponse(info: @escaping (T) -> String) -> EmptyResponseEventLoopFuture {
        return self
            .map { (data) -> (DataResponse<String>) in
                return .success(data: info(data))
            }
            .catchMap { (error) -> (DataResponse<String>) in
                return .failure(message: "\(error)", description: error.localizedDescription)
            }
    }
}

public extension EventLoopFuture where T: Codable {
    func asDataResponse() -> ResponseEventLoopFuture<T> {
        return self
            .map { (data) -> (DataResponse<T>) in
                return .success(data: data)
            }
            .catchMap { (error) -> (DataResponse<T>) in
                return .failure(message: "\(error)", description: "")
            }
    }
}

public struct ErrorResponse<T: Error & RawRepresentable>: Error, Content where T.RawValue == String {
    public let errorType: String
    public let errorDescription: String
    
    public var localizedDescription: String {
        return errorDescription
    }
    
    public init(_ error: T) {
        self.errorType = error.localizedDescription
        self.errorDescription = error.rawValue
    }
}

extension ErrorResponse: AbortError {
    public var status: HTTPResponseStatus {
        return .badRequest
    }
    
    public var reason: String {
        return errorDescription
    }
    
    public var identifier: String {
        return errorType
    }    
}
