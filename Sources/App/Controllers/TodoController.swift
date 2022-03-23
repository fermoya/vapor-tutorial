import Vapor
import Fluent

private struct TodoData: Content {
  var title: String
  var description: String?
}

final class TodoController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    routes.get(use: getEntities)
    routes.post(use: postEntity)
  }

  private func getEntities(req: Request) throws -> EventLoopFuture<Response> {
    guard let listID = req.parameters.get("id", as: UUID.self) else {
      throw Abort(.notFound)
    }
    return Todo.query(on: req.db)
      .filter(\.$list.$id == listID)
      .all()
      .encodeResponse(for: req)
  }

  private func postEntity(req: Request) throws -> EventLoopFuture<Response> {
    let todo = try req.content.decode(Todo.self)
    return todo.save(on: req.db)
      .map { todo }
      .encodeResponse(status: .created, for: req)
  }

}
