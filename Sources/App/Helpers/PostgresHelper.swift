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
	
	func text(_ name: String,
	          optional: Bool = false,
	          unique: Bool = false,
	          default value: NodeRepresentable? = nil
		) {
		self.custom(name, type: "TEXT", optional: optional, unique: unique, default: value)
	}
}

private let dateFormatter: DateFormatter = {
	let df = DateFormatter()
	df.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
	df.timeZone = TimeZone(abbreviation: "UTC")!
	return df
}()

extension Date {
	var psql_string: String {
		return dateFormatter.string(from: self)
	}
}

extension String {
	var psql_date: Date? {
		return dateFormatter.date(from: self)
	}
}

extension Date: NodeConvertible {
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
