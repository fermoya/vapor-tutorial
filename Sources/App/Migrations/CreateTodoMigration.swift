import Fluent

struct CreateTodoMigration: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    return database
      .schema(Todo.schema)
      .id()
      .field(.title, .string, .required)
      .field(.description, .string)
      .field(.listID, .uuid, .references(TodoList.schema, .id))
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    return database
      .schema(Todo.schema)
      .delete()
  }
}

