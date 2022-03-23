import Vapor
import Fluent

protocol Updatable {
  func update(with newValue: Self) -> Self
}

final class CRUDController<Entity: Model & Content & Updatable>: RouteCollection where Entity.IDValue == UUID {
  func boot(routes: RoutesBuilder) throws {
    routes.get(use: getAllEntities)
    routes.get(":id", use: getEntity)
    routes.delete(":id", use: deleteEntity)
    routes.post(use: postEntity)
    routes.put(use: putEntity)
  }

  // MARK: GET

  func getAllEntities(req: Request) throws -> EventLoopFuture<Response> {
    Entity.query(on: req.db)
      .all()
      .encodeResponse(for: req)
  }

  func getEntity(req: Request) throws -> EventLoopFuture<Response> {
    findEntity(on: req).encodeResponse(for: req)
  }

  // MARK: POST

  func postEntity(req: Request) throws -> EventLoopFuture<Response> {
    try req.content
      .decode(Entity.self)
      .save(on: req.db)
      .transform(to: Response(status: .created))
  }

  // MARK: DELETE

  func deleteEntity(req: Request) throws -> EventLoopFuture<Response> {
    findEntity(on: req)
      .flatMap { $0.delete(on: req.db) }
      .transform(to: Response(status: .noContent))
  }

  // MARK: PUT

  func putEntity(req: Request) throws -> EventLoopFuture<Response> {
    let updated = try req.content.decode(Entity.self)
    return findEntity(id: updated.id, on: req)
      .flatMap {
        $0.update(with: updated)
          .update(on: req.db)
      }
      .transform(to: Response(status: .accepted))
  }
}

// TODO: Helpers

extension CRUDController {
  private func findEntity(id: UUID? = nil, on req: Request) -> EventLoopFuture<Entity> {
    let uuid = id ?? req.parameters.get("id", as: UUID.self)
    return Entity.find(uuid, on: req.db)
      .unwrap(orError: Abort(.notFound))
  }
}
