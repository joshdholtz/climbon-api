import Vapor
import HTTP
import Turnstile

final class SessionController {
	func login(request: Request) throws -> ResponseRepresentable {
		let credentials = try request.usernamePassword()
		
		try request.auth.login(credentials)
		guard let user = request.user() else {
			throw Abort.custom(status: .badRequest, message: "Invalid credentials")
		}
		
		return user
	}
	
	func current(request: Request) throws -> ResponseRepresentable {
		guard let user = request.user() else {
			throw Abort.notFound
		}
		
		return user
	}
}
