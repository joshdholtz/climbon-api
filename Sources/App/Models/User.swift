import Vapor
import Auth
import HTTP
import Node
import Fluent
import BCrypt
import Turnstile
import Foundation

final class User: Model {
	var id: Node?
	var username: String
	var password: String
	var name: String?
	
	init(username: String, password: String) {
		self.username = username
		self.password = password
	}
	
	init(node: Node, in context: Context) throws {
		id = try node.extract("id")
		username = try node.extract("username")
		password = try node.extract("password")
		name = try node.extract("name")
	}
	
	func patch(node: Node?) throws {
		guard let node = node else {
			return
		}
		
		try node.exists("name", { [unowned self] (s: String?) in
			self.name = s
		})
	}
	
	func makeNode(context: Context) throws -> Node {
		return try Node(node: [
			"id": id,
			"username": username,
			"password": password,
			"name": name
			])
	}
	
	func makeJSON() throws -> JSON {
		return try JSON(node: [
			"id": id,
			"username": username,
			"name": name
			])
	}

}

extension User: Auth.User {
	static func authenticate(credentials: Credentials) throws -> Auth.User {
		var user: User?
		
		switch credentials {
		case let up as UsernamePasswordSession:
			if let maybeUser = try User.query().filter("username", up.username).first(),
				let userID = maybeUser.id,
				try BCrypt.verify(password: up.password, matchesHash: maybeUser.password) {
				user = maybeUser
				
				try up.request.session().currentUser = maybeUser
			}
		default:
			throw Abort.custom(status: .badRequest, message: "Invalid credentials.")
		}
		
		guard let u = user else {
			throw Abort.custom(status: .badRequest, message: "User not found.")
		}
		
		return u
	}
	
	static func register(credentials: Credentials) throws -> Auth.User {
		let user: User?
		
		switch credentials {
		case let up as UsernamePasswordSession:
			let password = BCrypt.hash(password: up.password)
			user = User(username: up.username, password: password)
		default:
			throw Abort.custom(status: .badRequest, message: "Invalid credentials.")
		}
		
		guard var u = user else {
			throw Abort.custom(status: .badRequest, message: "User not found.")
		}
		
		try u.save()
		
		return u
	}
}

extension User: Preparation {
	static func prepare(_ database: Database) throws {
		try database.create("users") { users in
			users.id()
			users.custom("username", type: "TEXT", optional: false, unique: true)
			users.custom("password", type: "TEXT", optional: false, unique: true)
			users.custom("name", type: "TEXT", optional: true, unique: false)
		}
	}
	
	static func revert(_ database: Database) throws {
		
	}
}
