import Vapor
import HTTP

final class RouteController: ResourceRepresentable {
    func index(request: Request) throws -> ResponseRepresentable {
        return try Route.all().makeNode().converted(to: JSON.self)
    }

    func create(request: Request) throws -> ResponseRepresentable {
        var route = try request.route()
        try route.save()
        return route
    }

    func show(request: Request, route: Route) throws -> ResponseRepresentable {
        return route
    }

    func delete(request: Request, route: Route) throws -> ResponseRepresentable {
        try route.delete()
        return JSON([:])
    }

    func update(request: Request, route: Route) throws -> ResponseRepresentable {
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
	func route() throws -> Route {
		guard let json = json else { throw Abort.badRequest }
		return try Route(node: json)
	}
}
