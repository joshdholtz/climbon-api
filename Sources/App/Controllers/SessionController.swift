import Vapor
import HTTP
import Turnstile

final class SessionController {
	func login(request: Request) throws -> ResponseRepresentable {
		// Gets username/password credentials
		let credentials = try request.usernamePassword()
		
		// Logs user in
		try request.auth.login(credentials)
		guard let user = request.user() else {
			throw Abort.custom(status: .badRequest, message: "Invalid credentials")
		}
		
		return user
	}
	
	func current(request: Request) throws -> ResponseRepresentable {
		guard let user = request.user() else {
			throw Abort.custom(status: .forbidden, message: "User not logged in")
		}
		
		return user
	}
	
	func logout(request: Request) throws -> ResponseRepresentable {
		try request.auth.logout()
		
		return JSON([:])
	}
}
