import Foundation

import Node

extension NodeBacked {
	func exists<T: NodeInitializable>(_ key: String, _ exists: (T?) -> ()) throws {
		guard let _ = self[key] else { return }
		
		if let value: T = try extract(key) {
			exists(value)
		} else {
			exists(nil)
		}
		
		return
	}
}
