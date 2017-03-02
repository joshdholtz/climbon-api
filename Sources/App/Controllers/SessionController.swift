import Vapor
import HTTP
import Turnstile

final class SessionController {
	func login(request: Request) throws -> ResponseRepresentable {
		let credentials = try request.usernamePassword()
		guard let user = try User.authenticate(credentials: credentials) as? User else {
			throw Abort.serverError
		}
		
		return user
	}
	
	func current(request: Request) throws -> ResponseRepresentable {
		guard let user = try request.session().currentUser else {
			throw Abort.notFound
		}
		
		return user
	}
}
