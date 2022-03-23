import Vapor
import Fluent
import FluentSQLiteDriver

// configures your application
public func configure(_ app: Application) throws {

  app.routes.defaultMaxBodySize = "10mb"
  app.middleware.use(FileMiddleware(publicDirectory: app.directory.workingDirectory))

  // MARK: Database
  
  app.databases.use(.sqlite(.memory), as: .sqlite)
  
  // MARK: Migrations

  app.migrations.add(CreateTodoListMigration(), to: .sqlite)
  app.migrations.add(CreateTodoMigration(), to: .sqlite)
  app.migrations.add(AddTodoListImageURLMigration(), to: .sqlite)
  try app.autoMigrate().wait()
  
  // MARK: Routes
  
  try routes(app)
}
