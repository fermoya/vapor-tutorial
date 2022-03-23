import Vapor
import Fluent

final class Todo: Model, Content {
  static let schema = "todos"

  @ID(key: .id)
  var id: UUID?

  @Field(key: .title)
  var title: String

  @Field(key: .description)
  var description: String?

  @Parent(key: .listID)
  var list: TodoList
}
