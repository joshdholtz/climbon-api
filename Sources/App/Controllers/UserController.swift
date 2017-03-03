import Vapor
import HTTP
import Turnstile

final class UserController: ResourceRepresentable {
	func create(request: Request) throws -> ResponseRepresentable {
		let credentials = try request.usernamePassword()
		guard var user = try User.register(credentials: credentials) as? User else {
			throw Abort.serverError
		}
		
		try user.patch(node: request.json?.makeNode())
		try user.save()
		
		return user
	}
	
	func show(request: Request, user: User) throws -> ResponseRepresentable {
		return user
	}
	
	func update(request: Request, user: User) throws -> ResponseRepresentable {
		var user = user
		try user.patch(node: request.json?.makeNode())
		try user.save()
		return user
	}
	
	func makeResource() -> Resource<User> {
		return Resource(
			index: nil,
			store: create,
			show: show,
			replace: nil,
			modify: update,
			destroy: nil,
			clear: nil
		)
	}
}

extension UserController {
	func user(_ request: Request) throws -> User {
		guard let json = request.json else { throw Abort.badRequest }
		return try User(node: json)
	}
}
