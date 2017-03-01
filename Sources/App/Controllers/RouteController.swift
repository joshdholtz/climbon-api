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

//    func delete(request: Request, post: Post) throws -> ResponseRepresentable {
//        try post.delete()
//        return JSON([:])
//    }
//
//    func clear(request: Request) throws -> ResponseRepresentable {
//        try Post.query().delete()
//        return JSON([])
//    }
//
    func update(request: Request, route: Route) throws -> ResponseRepresentable {
		var route = route
		try route.patch(node: request.json?.makeNode())
		try route.save()
        return route
    }
//
//    func replace(request: Request, post: Post) throws -> ResponseRepresentable {
//        print("in replace")
//        try post.delete()
//        return try create(request: request)
//    }

    func makeResource() -> Resource<Route> {
        return Resource(
            index: index,
            store: create,
            show: show,
//            replace: replace,
            modify: update
//            destroy: delete,
//            clear: clear
        )
    }
}

extension Request {
	func route() throws -> Route {
		guard let json = json else { throw Abort.badRequest }
		return try Route(node: json)
	}
}
