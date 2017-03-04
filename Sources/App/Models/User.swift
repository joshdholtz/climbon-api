import Vapor
import Auth
import HTTP
import Node
import Fluent
import BCrypt
import Turnstile
import Foundation
import FluentPostgreSQL

final class User: Model {
	var id: Node?
	var username: String
	var password: String
	var name: String?
	
	var createdAt: Date!
	var updatedAt: Date!
	
	init(username: String, password: String) {
		self.username = username
		self.password = password
	}
	
	init(node: Node, in context: Context) throws {
		id = try node.extract("id")
		username = try node.extract("username")
		password = try node.extract("password")
		name = try node.extract("name")
		
		createdAt = try node.extract("created_at")
		updatedAt = try node.extract("updated_at")
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
			"name": name,
			"created_at": createdAt,
			"updated_at": updatedAt
			])
	}
	
	func makeJSON() throws -> JSON {
		return try JSON(node: [
			"id": id,
			"username": username,
			"name": name,
			"created_at": createdAt,
			"updated_at": updatedAt
			])
	}

	func willCreate() {
		createdAt = Date()
		updatedAt = Date()
	}
	
	func willUpdate() {
		updatedAt = Date()
	}
}

extension User: Auth.User {
	static func authenticate(credentials: Credentials) throws -> Auth.User {
		var user: User?
		
		switch credentials {
		case let id as Identifier:
			user = try User.find(id.id)
		case let up as UsernamePassword:
			if let maybeUser = try User.query().filter("username", up.username).first(),
				try BCrypt.verify(password: up.password, matchesHash: maybeUser.password) {
				user = maybeUser
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
		case let id as Identifier:
			user = try User.find(id.id)
		case let up as UsernamePassword:
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
			users.text("username", optional: false, unique: true)
			users.text("password", optional: false, unique: true)
			users.text("name", optional: true, unique: false)
			
			users.timestamp("created_at", optional: false, unique: false)
			users.timestamp("updated_at", optional: false, unique: false)
		}
	}
	
	static func revert(_ database: Database) throws {
		
	}
}
