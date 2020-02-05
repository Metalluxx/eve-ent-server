// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "eve-ent-server",
    products: [
        .library(
            name: "Server",
            targets: ["Server"]),
        .library(
            name: "Run",
            targets: ["Run"])
    ],
    
    dependencies: [
        .package(
            url: "https://github.com/vapor/vapor",
            from: Version(3, 0, 0)),
        .package(
            url: "https://github.com/vapor/routing.git",
            from: Version(3, 0, 0)),
        
        // Auth
        .package(
            url: "https://github.com/vapor-community/Imperial.git",
            from: Version(0, 5, 3)),
        .package(
            url: "https://github.com/vapor/auth.git",
            from: Version(2, 0, 0)),
        .package(
            url: "https://github.com/vapor/crypto.git",
            from: Version(3, 0, 0)),
        
        // Database
        .package(
            url: "https://github.com/vapor/fluent-mysql-driver",
            from: Version(3, 0, 0)),
    ],
    targets: [
        .target(
            name: "Auth",
            dependencies: ["Routing", "Vapor", "Authentication", "FluentMySQL", "Crypto"]),
        .target(
            name: "Run",
            dependencies: ["Server"]),
        .target(
            name: "Server",
            dependencies: ["Auth", "Routing", "Vapor", "Authentication", "FluentMySQL", "Crypto"]),
    ]
)
