import Vapor
import Fluent

extension TodoList: Content { }

final class TodoList: Model {
  static let schema = "todo-lists"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: .name)
  var name: String

  @Field(key: .imageURL)
  var imageURL: String?
  
  @Children(for: \.$list)
  var todos: [Todo]
}

//extension TodoList: Updatable {
//  func update(with newValue: TodoList) -> Self {
//    self.title = newValue.title
//    return self
//  }
//}
