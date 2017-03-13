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
	
	func textArray(_ name: String,
	          optional: Bool = false,
	          unique: Bool = false,
	          default value: NodeRepresentable? = nil
		) {
		self.custom(name, type: "TEXT[]", optional: optional, unique: unique, default: value)
	}
}

// PG.Date and PG.DateTime

struct PG {
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
	
	struct TextArray {
		let array: [String]
		
		init() {
			self.array = []
		}
		
		init(array: [String]?) {
			self.array = array ?? []
		}
		
		init(string: String) {
			guard let data = string.data(using: .utf8),
				let ughJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String],
				let json = ughJson else {
				self.array = []
				return
			}
			
			self.array = json
		}
	}
}

// MARK: PG.Date

extension PG.Date {
	var psql_string: String {
		return PG.Date.dateFormatter.string(from: self.date)
	}
}

extension String {
	var psql_date: PG.Date? {
		guard let date = PG.Date.dateFormatter.date(from: self) else {
			return nil
		}
		return PG.Date(date: date)
	}
}

extension PG.Date: NodeConvertible {
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


// MARK: PG.DateTime

extension PG.DateTime {
	var pq_string: String {
		return PG.DateTime.dateFormatter.string(from: self.date)
	}
}

extension String {
	var pq_datetime: PG.DateTime? {
		guard let date = PG.DateTime.dateFormatter.date(from: self) else {
			return nil
		}
		return PG.DateTime(date: date)
	}
}

extension PG.DateTime: NodeConvertible {
	public func makeNode(context: Context = EmptyNode) -> Node {
		let string = self.pq_string
		return .string(string)
	}
	
	public init(node: Node, in context: Context) throws {
		guard let string = node.string, let date = string.pq_datetime else {
			throw NodeError.unableToConvert(node: node, expected: "\(String.self)")
		}
		self = date
	}
}

// MARK: PG.TextArray

extension PG.TextArray: NodeConvertible {
	public func makeNode(context: Context = EmptyNode) -> Node {
		// TODO: This is super unsafe and probably needs to escape quotes
		let string = array.map { (string) -> String in
			return "\"\(string)\""
		}.joined(separator: ",")
		return .string("{\(string)}")
	}
	
	public init(node: Node, in context: Context) throws {
		guard let string = node.string else {
			throw NodeError.unableToConvert(node: node, expected: "\(String.self)")
		}
		self = PG.TextArray(string: string)
	}
}
