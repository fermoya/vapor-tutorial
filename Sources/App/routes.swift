import Vapor

func routes(_ app: Application) throws {
  let v1Routes = app.grouped("v1")

  // MARK: Todo Lists

  let todoListsRoutes = v1Routes.grouped("todo-lists")
  try todoListsRoutes.register(collection: TodoListController())

  // MARK: Todos


}





