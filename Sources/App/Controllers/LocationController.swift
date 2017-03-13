import Vapor
import HTTP

final class LocationController: ResourceRepresentable {
	func index(request: Request) throws -> ResponseRepresentable {
		return try Location.all().makeJSON().converted(to: JSON.self)
	}
	
	func create(request: Request) throws -> ResponseRepresentable {
		// Must be logged in
		let (_, userId) = try request.protected()
		
		var location = try request.location(userId: userId)
		try location.validate()
		try location.save()
		return location
	}
	
	func show(request: Request, location: Location) throws -> ResponseRepresentable {
		return location
	}
	
	func delete(request: Request, location: Location) throws -> ResponseRepresentable {
		// TODO: This must be an admin/gym permission only (or have no activity)
		
		let (_, userId) = try request.protected()
		guard location.userId == userId else {
			throw Abort.custom(status: .forbidden, message: "Can only delete your own location")
		}
		
		try location.delete()
		return JSON([:])
	}
	
	func update(request: Request, location: Location) throws -> ResponseRepresentable {
		// TODO: This must be an admin/gym permission only (or have no activity)
		
		let (_, userId) = try request.protected()
		guard location.userId == userId else {
			throw Abort.custom(status: .forbidden, message: "Can only update your own route")
		}
		
		var location = location
		try location.patch(node: request.json?.makeNode())
		try location.save()
		return location
	}
	
	func makeResource() -> Resource<Location> {
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
	func location(userId: Int) throws -> Location {
		guard let json = json else { throw Abort.badRequest }
		return try Location(node: json, userId: userId)
	}
}
