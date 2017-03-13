import Vapor
import Fluent
import Foundation

import FluentPostgreSQL

final class Route: Model {
	var id: Node?
	var name: String?
	var info: String?
	var grade: String?
	var setter: String?
	var type: String?
	
	var userId: Int
	var locationId: Int
	
	var setAt: PG.Date?
	
	var images: PG.TextArray?
	
	var createdAt: PG.DateTime!
	var updatedAt: PG.DateTime!
	
	init(node: JSON, userId: Int) throws {
		id = try node.extract("id")
		name = try node.extract("name")
		info = try node.extract("info")
		grade = try node.extract("grade")
		setter = try node.extract("setter")
		type = try node.extract("type")
		
		setAt = try node.extract("set_at")
		
		if let imagesJSON: [String] = try node.extract("images") {
			images = PG.TextArray(array: imagesJSON)
		}
		
		self.userId = userId
		locationId = try node.extract("location_id")
	}
	
	init(node: Node, in context: Context) throws {
		id = try node.extract("id")
		name = try node.extract("name")
		info = try node.extract("info")
		grade = try node.extract("grade")
		setter = try node.extract("setter")
		type = try node.extract("type")
		
		userId = try node.extract("user_id")
		locationId = try node.extract("location_id")
		
		setAt = try node.extract("set_at")
		
		// TODO: Replace thi swith something less fugly
		if let id = id?.int,
			let postgres = Route.database?.driver as? PostgreSQLDriver {
			let result = try postgres.raw("select array_to_json(images) as images from routes where id = \(id);")
			images = try result.nodeArray?.first?.extract("images")
		}
//		images  = try node.extract("images")
		
		createdAt = try node.extract("created_at")
		updatedAt = try node.extract("updated_at")
	}
	
	func validate() throws {
		if try User.find(userId) == nil {
			throw Abort.custom(status: .badRequest, message: "Invalid user")
		}
		
		if try Location.find(locationId) == nil {
			throw Abort.custom(status: .badRequest, message: "Invalid location")
		}
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
		try node.exists("set_at", { [unowned self] (s: String?) in
			self.setAt = try? node.extract("set_at")
		})
		try node.exists("images", { [unowned self] (ss: [String]?) in
			if let imagesJSON = ss {
				self.images = PG.TextArray(array: imagesJSON)
			} else {
				self.images = nil
			}
		})
	}
	
	func makeNode(context: Context) throws -> Node {
		print("Images: \(images)")
		return try Node(node: [
			"id": id,
			"name": name,
			"info": info,
			"grade": grade,
			"setter": setter,
			"type": type,
			"user_id": userId,
			"location_id": locationId,
			"set_at": setAt,
			"images": images,
			"created_at": createdAt,
			"updated_at": updatedAt
			])
	}
	
	func makeJSON() throws -> JSON {
		return try JSON(node: [
			"id": id,
			"name": name,
			"info": info,
			"grade": grade,
			"setter": setter,
			"type": type,
			"user_id": userId,
			"location_id": locationId,
			"set_at": setAt,
			"images": JSON(node: images?.array ?? []),
			"created_at": createdAt,
			"updated_at": updatedAt
			])
	}
	
	func willCreate() {
		createdAt = PG.DateTime()
		updatedAt = PG.DateTime()
	}
	
	func willUpdate() {
		updatedAt = PG.DateTime()
	}
}

extension Route: Preparation {
	static func prepare(_ database: Database) throws {
		
	}
	
	static func revert(_ database: Database) throws {
		
	}
}
