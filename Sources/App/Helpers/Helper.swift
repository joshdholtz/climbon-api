import Foundation

import HTTP
import Node
import Sessions
import Turnstile

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

private let currentUserIDKey = "current_user_id"
extension Sessions.Session {
	var currentUser: User? {
		get {
			if let userID = data[currentUserIDKey]?.int, let user = try? User.find(userID) {
				return user
			}
			return nil
		}
		set {
			data[currentUserIDKey] = newValue?.id
		}
	}
}


public class UsernamePasswordSession: Credentials {
	/// Username or email address
	public let username: String
	
	/// Password (unhashed)
	public let password: String
	
	/// Request
	public let request: Request
	
	/// Initializer for PasswordCredentials
	public init(username: String, password: String, request: Request) {
		self.username = username
		self.password = password
		self.request = request
	}
}
