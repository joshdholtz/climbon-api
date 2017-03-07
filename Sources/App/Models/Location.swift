import Vapor
import Fluent
import Foundation

final class Location: Model {
	var id: Node?
	var name: String
	var address1: String?
	var address2: String?
	var city: String?
	var state: String?
	var zip: String?
	var lat: Double?
	var lng: Double?
	
	var userId: Int
	
	var createdAt: Date!
	var updatedAt: Date!
	
	init(node: JSON, userId: Int) throws {
		id = try node.extract("id")
		name = try node.extract("name")
		address1 = try node.extract("address1")
		address2 = try node.extract("address2")
		city = try node.extract("city")
		state = try node.extract("state")
		zip = try node.extract("zip")
		lat = try node.extract("lat")
		lng = try node.extract("lng")
		
		self.userId = userId
	}
	
	init(node: Node, in context: Context) throws {
		id = try node.extract("id")
		name = try node.extract("name")
		address1 = try node.extract("address1")
		address2 = try node.extract("address2")
		city = try node.extract("city")
		state = try node.extract("state")
		zip = try node.extract("zip")
		lat = try node.extract("lat")
		lng = try node.extract("lng")
		
		userId = try node.extract("user_id")
		
		createdAt = try node.extract("created_at")
		updatedAt = try node.extract("updated_at")
	}
	
	func validate() throws {
		if try User.find(userId) == nil {
			throw Abort.custom(status: .badRequest, message: "Invalid user")
		}
	}
	
	func patch(node: Node?) throws {
		guard let node = node else {
			return
		}
		
		try node.exists("name", { [unowned self] (s: String) in
			self.name = s
		})
		try node.exists("address1", { [unowned self] (s: String?) in
			self.address1 = s
		})
		try node.exists("address2", { [unowned self] (s: String?) in
			self.address2 = s
		})
		try node.exists("city", { [unowned self] (s: String?) in
			self.city = s
		})
		try node.exists("state", { [unowned self] (s: String?) in
			self.state = s
		})
		try node.exists("zip", { [unowned self] (s: String?) in
			self.zip = s
		})
		try node.exists("lat", { [unowned self] (s: Double?) in
			self.lat = s
		})
		try node.exists("lng", { [unowned self] (s: Double?) in
			self.lng = s
		})
	}
	
	func makeNode(context: Context) throws -> Node {
		return try Node(node: [
			"id": id,
			"name": name,
			"address1": address1,
			"address2": address2,
			"city": city,
			"state": state,
			"zip": zip,
			"lat": lat,
			"lng": lng,
			"user_id": userId,
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

extension Location: Preparation {
	static func prepare(_ database: Database) throws {
		
	}
	
	static func revert(_ database: Database) throws {
		
	}
}
