import Fluent

struct CreateTodoListMigration: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database
      .schema(TodoList.schema)
      .id()
      .field(.name, .string, .required)
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    database
      .schema(TodoList.schema)
      .delete()
  }
}
