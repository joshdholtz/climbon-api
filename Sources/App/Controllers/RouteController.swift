import Vapor
import HTTP

import FluentPostgreSQL

final class RouteController: ResourceRepresentable {
    func index(request: Request) throws -> ResponseRepresentable {
        return try Route.all().makeNode().converted(to: JSON.self)
    }

    func create(request: Request) throws -> ResponseRepresentable {
		// Must be logged in
		let (_, userId) = try request.protected()
		
		var route = try request.route(userId: userId)
		try route.validate()
        try route.save()
        return route
    }

    func show(request: Request, route: Route) throws -> ResponseRepresentable {
        return route
    }

    func delete(request: Request, route: Route) throws -> ResponseRepresentable {
		// TODO: This must be an admin/gym permission only (or have no activity)
		
		let (_, userId) = try request.protected()
		guard route.userId == userId else {
			throw Abort.custom(status: .forbidden, message: "Can only delete your own route")
		}
		
        try route.delete()
        return JSON([:])
    }

    func update(request: Request, route: Route) throws -> ResponseRepresentable {
		// TODO: This must be an admin/gym permission only (or have no activity)
		
		let (_, userId) = try request.protected()
		guard route.userId == userId else {
			throw Abort.custom(status: .forbidden, message: "Can only update your own route")
		}
		
		var route = route
		try route.patch(node: request.json?.makeNode())
		try route.save()
        return route
    }

    func makeResource() -> Resource<Route> {
        return Resource(
            index: index,
            store: create,
            show: show,
            replace: nil,
            modify: update,
            destroy: delete,
            clear: nil
        )
    }
}

extension Request {
	func route(userId: Int) throws -> Route {
		guard let json = json else { throw Abort.badRequest }
		return try Route(node: json, userId: userId)
	}
}
