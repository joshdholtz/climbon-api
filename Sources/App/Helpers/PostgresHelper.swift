import Fluent
import Foundation

extension Schema.Creator {
	func timestamp(_ name: String,
	               withTimezone: Bool = true,
	               optional: Bool = false,
	               unique: Bool = false,
	               default value: NodeRepresentable? = nil
		) {
		let type = withTimezone ? "timestamp with time zone" : "timestamp without time zone"
		self.custom(name, type: type, optional: optional, unique: unique, default: value)
	}
	
	func date(_ name: String,
	               optional: Bool = false,
	               unique: Bool = false,
	               default value: NodeRepresentable? = nil
		) {
		self.custom(name, type: "DATE", optional: optional, unique: unique, default: value)
	}
	
	func text(_ name: String,
	          optional: Bool = false,
	          unique: Bool = false,
	          default value: NodeRepresentable? = nil
		) {
		self.custom(name, type: "TEXT", optional: optional, unique: unique, default: value)
	}
}

// PSQL.Date and PSQL.DateTime

struct PSQL {
	struct Date {
		let date: Foundation.Date
		
		init() {
			self.date = Foundation.Date()
		}
		
		init(date: Foundation.Date) {
			self.date = date
		}
		
		static let dateFormatter: DateFormatter = {
			let df = DateFormatter()
			df.dateFormat = "yyyy-MM-dd"
			df.timeZone = TimeZone(abbreviation: "UTC")!
			return df
		}()
	}
	
	struct DateTime {
		let date: Foundation.Date
		
		init() {
			self.date = Foundation.Date()
		}
		
		init(date: Foundation.Date) {
			self.date = date
		}
		
		static let dateFormatter: DateFormatter = {
			let df = DateFormatter()
			df.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
			df.timeZone = TimeZone(abbreviation: "UTC")!
			return df
		}()
	}
}

// MARK: PSQL.Date

extension PSQL.Date {
	var psql_string: String {
		return PSQL.Date.dateFormatter.string(from: self.date)
	}
}

extension String {
	var psql_date: PSQL.Date? {
		guard let date = PSQL.Date.dateFormatter.date(from: self) else {
			return nil
		}
		return PSQL.Date(date: date)
	}
}

extension PSQL.Date: NodeConvertible {
	public func makeNode(context: Context = EmptyNode) -> Node {
		let string = self.psql_string
		return .string(string)
	}
	
	public init(node: Node, in context: Context) throws {
		guard let string = node.string, let date = string.psql_date else {
			throw NodeError.unableToConvert(node: node, expected: "\(String.self)")
		}
		self = date
	}
}


// MARK: PSQL.DateTime

extension PSQL.DateTime {
	var psql_string: String {
		return PSQL.DateTime.dateFormatter.string(from: self.date)
	}
}

extension String {
	var psql_datetime: PSQL.DateTime? {
		guard let date = PSQL.DateTime.dateFormatter.date(from: self) else {
			return nil
		}
		return PSQL.DateTime(date: date)
	}
}

extension PSQL.DateTime: NodeConvertible {
	public func makeNode(context: Context = EmptyNode) -> Node {
		let string = self.psql_string
		return .string(string)
	}
	
	public init(node: Node, in context: Context) throws {
		guard let string = node.string, let date = string.psql_datetime else {
			throw NodeError.unableToConvert(node: node, expected: "\(String.self)")
		}
		self = date
	}
}
