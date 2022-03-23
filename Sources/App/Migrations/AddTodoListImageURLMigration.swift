import Fluent

struct AddTodoListImageURLMigration: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database
      .schema(TodoList.schema)
      .field(.imageURL, .string)
      .update()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database
      .schema(TodoList.schema)
      .deleteField(.imageURL)
      .update()
  }
}
