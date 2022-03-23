import Vapor

final class TodoListController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    routes.get(use: getEntities)
    routes.post(use: postEntity)

    let singleListRoutes = routes.grouped(":id")
    singleListRoutes.get(use: getEntity)
    singleListRoutes.post("upload-image", use: uploadImage)

    let todosRoutes = singleListRoutes.grouped("todos")
    try todosRoutes.register(collection: TodoController())
  }

  // MARK: Multipart

  private func uploadImage(req: Request) throws -> EventLoopFuture<Response> {
    let uuid = req.parameters.get("id", as: UUID.self)
    let file = try req.content.decode(File.self)
    var fileName = "\(uuid?.uuidString ?? "").\(Date().timeIntervalSince1970)"
    fileName = file.extension.flatMap { "\(fileName).\($0)" } ?? fileName
    let path = req.application.directory.workingDirectory + fileName

    guard file.isImage else {
      throw Abort(.badRequest)
    }

    return TodoList
      .find(uuid, on: req.db)
      .unwrap(orError: Abort(.notFound))
      .flatMap { list in
        req.fileio
          .writeFile(file.data, at: fileName)
          .map { list }
      }
      .flatMap { list in
        let hostname = req.application.http.server.configuration.hostname
        let port = req.application.http.server.configuration.port
        list.imageURL = "\(hostname):\(port)/\(fileName)"
        return list.update(on: req.db)
          .map { list }
          .encodeResponse(status: .accepted, for: req)
      }
  }

  // MARK: GET

  private func getEntities(req: Request) throws -> EventLoopFuture<Response> {
    let limit = req.query[Int.self, at: "limit"] ?? 100
    let offset = req.query[Int.self, at: "offset"] ?? 0
    return TodoList.query(on: req.db)
      .range(offset..<(limit + offset))
      .with(\.$todos)
      .all()
      .encodeResponse(for: req)
  }

  private func getEntity(req: Request) throws -> EventLoopFuture<Response> {
    let uuid = req.parameters.get("id", as: UUID.self)
    return TodoList.find(uuid, on: req.db)
      .unwrap(orError: Abort(.notFound))
      .flatMap { list in
        list.$todos.load(on: req.db).map { list }
      }
      .encodeResponse(for: req)
  }

  // MARK: POST

  private func postEntity(req: Request) throws -> EventLoopFuture<Response> {
    let todoList = try req.content.decode(TodoList.self)
    return todoList.save(on: req.db)
      .map { todoList }
      .encodeResponse(status: .created, for: req)
  }

}

extension File {
  var isImage: Bool {
    [
      "png",
      "jpeg",
      "jpg",
      "gif"
    ].contains(self.extension?.lowercased())
  }
}
