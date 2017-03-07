//
//  001CreateUser.swift
//  ClimbOn
//
//  Created by Josh Holtz on 3/7/17.
//
//

import Fluent

struct Migration001CreateUser: Preparation {
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

struct Migration002CreateLocation: Preparation {
	static func prepare(_ database: Database) throws {
		try database.create("locations") { locations in
			locations.id()
			locations.text("name", optional: false, unique: false)
			locations.text("address1", optional: true, unique: false)
			locations.text("address2", optional: true, unique: false)
			locations.text("city", optional: true, unique: false)
			locations.text("state", optional: true, unique: false)
			locations.text("zip", optional: true, unique: false)
			locations.double("lat", optional: true, unique: false)
			locations.double("lng", optional: true, unique: false)
			locations.parent(User.self, optional: false, unique: false)
			
			locations.timestamp("created_at", optional: false, unique: false)
			locations.timestamp("updated_at", optional: false, unique: false)
		}
	}
	
	static func revert(_ database: Database) throws {
		
	}
}

struct Migration003CreateRoute: Preparation {
	static func prepare(_ database: Database) throws {
		try database.create("routes") { routes in
			routes.id()
			routes.text("name", optional: true, unique: false)
			routes.text("info", optional: true, unique: false)
			routes.text("grade", optional: true, unique: false)
			routes.text("setter", optional: true, unique: false)
			routes.text("type", optional: true, unique: false)
			routes.parent(User.self, optional: true, unique: false)
			routes.parent(Location.self, optional: true, unique: false)
			
			routes.timestamp("created_at", optional: false, unique: false)
			routes.timestamp("updated_at", optional: false, unique: false)
		}
	}
	
	static func revert(_ database: Database) throws {
		
	}
}

struct Migration004CreateReview: Preparation {
	static func prepare(_ database: Database) throws {
		try database.create("reviews") { reviews in
			reviews.id()
			reviews.text("title", optional: false, unique: false)
			reviews.int("rating", optional: false, unique: false)
			reviews.text("text", optional: true, unique: false)
			reviews.text("suggested_grade", optional: true, unique: false)
			reviews.parent(User.self, optional: false, unique: false)
			reviews.parent(Route.self, optional: false, unique: false)
			
			reviews.timestamp("created_at", optional: false, unique: false)
			reviews.timestamp("updated_at", optional: false, unique: false)
		}
	}
	
	static func revert(_ database: Database) throws {
		
	}
}
