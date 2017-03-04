import Vapor
import Fluent
import Foundation

final class Route: Model {
	var id: Node?
	var name: String?
	var info: String?
	var grade: String?
	var setter: String?
	var type: String?
	
	var userId: Int
	
	init(node: JSON, userId: Int) throws {
		id = try node.extract("id")
		name = try node.extract("name")
		info = try node.extract("info")
		grade = try node.extract("grade")
		setter = try node.extract("setter")
		type = try node.extract("type")
		self.userId = userId
	}
	
	init(node: Node, in context: Context) throws {
		id = try node.extract("id")
		name = try node.extract("name")
		info = try node.extract("info")
		grade = try node.extract("grade")
		setter = try node.extract("setter")
		type = try node.extract("type")
		userId = try node.extract("user_id")
	}
	
	func patch(node: Node?) throws {
		guard let node = node else {
			return
		}
		
		try node.exists("name", { [unowned self] (s: String?) in
			self.name = s
		})
		try node.exists("info", { [unowned self] (s: String?) in
			self.info = s
		})
		try node.exists("grade", { [unowned self] (s: String?) in
			self.grade = s
		})
		try node.exists("setter", { [unowned self] (s: String?) in
			self.setter = s
		})
		try node.exists("type", { [unowned self] (s: String?) in
			self.type = s
		})
	}
	
	func makeNode(context: Context) throws -> Node {
		return try Node(node: [
			"id": id,
			"name": name,
			"info": info,
			"grade": grade,
			"setter": setter,
			"type": type,
			"user_id": userId
			])
	}
}

extension Route: Preparation {
	static func prepare(_ database: Database) throws {
		try database.create("routes") { routes in
			routes.id()
			routes.custom("name", type: "TEXT", optional: true, unique: false)
			routes.custom("info", type: "TEXT", optional: true, unique: false)
			routes.custom("grade", type: "TEXT", optional: true, unique: false)
			routes.custom("setter", type: "TEXT", optional: true, unique: false)
			routes.custom("type", type: "TEXT", optional: true, unique: false)
			routes.parent(User.self, optional: true, unique: false)
		}
	}
	
	static func revert(_ database: Database) throws {
		
	}
}
