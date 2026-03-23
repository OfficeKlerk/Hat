import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    
    // база данных (Postgres)
    let hostname = Environment.get("DATABASE_HOST") ?? "localhost"
    let port = Environment.get("DATABASE_PORT").flatMap(Int.init) ?? 5432
    let username = Environment.get("DATABASE_USERNAME") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "vapor"
    let database = Environment.get("DATABASE_NAME") ?? "vapor_database"

    let postgresConfig = SQLPostgresConfiguration(
        hostname: hostname,
        port: port,
        username: username,
        password: password,
        database: database,
        tls: .disable
    )
    
    app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
    
    // миграции
    app.migrations.add(CreateUser())
    app.migrations.add(CreateGame())
    app.migrations.add(CreateGamePlayer())
    app.migrations.add(CreateUserMessage())
    
    try await app.autoMigrate()
    
    // контроллеры
    try app.register(collection: UserController())
    try app.register(collection: UserMessagesController())
    try app.register(collection: GameController())
    try app.register(collection: GamePlayersController())
    
    // register routes
    try routes(app)
}
