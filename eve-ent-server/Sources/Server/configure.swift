import Vapor
import FluentMySQL
import Authentication

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services) throws
{

    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    let serverConfiure = NIOServerConfig.default(hostname: "0.0.0.0", port: 3208)
    services.register(serverConfiure)
    
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)
    
    // Database
    try services.register(FluentMySQLProvider())
    try services.register(MySQLProvider())
    
    let sqlServerConfig = MySQLDatabaseConfig(
        hostname: "45.84.1.115",
        port: 3306,
        username: "Eve-Ent",
        password: "12345678",
        database: "Eve-Ent"
    )
    let sqlDatabase = MySQLDatabase(config: sqlServerConfig)
    
    var databases = DatabasesConfig()
    databases.add(database: sqlDatabase, as: .mysql)
    services.register(databases)
    
    try services.register(AuthenticationProvider())

    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Token.self, database: .mysql)
    services.register(migrations)
}
