import Foundation

import Vapor
import HTTP
import Node
import Sessions
import Turnstile

extension NodeBacked {
	func exists<T: NodeInitializable>(_ key: String, _ exists: (T) -> ()) throws {
		guard let _ = self[key] else { return }
		
		if let value: T = try extract(key) {
			exists(value)
		}
		
		return
	}
	
	func exists<T: NodeInitializable>(_ key: String, _ exists: (T?) -> ()) throws {
		guard let _ = self[key] else { return }
		
		if let value: T = try extract(key) {
			exists(value)
		} else {
			exists(nil)
		}
		
		return
	}
	
	func exists<T: NodeInitializable>(_ key: String, _ exists: ([T]?) -> ()) throws {
		guard let _ = self[key] else { return }
		
		if let value: [T] = try extract(key) {
			exists(value)
		} else {
			exists(nil)
		}
		
		return
	}
}

//private let currentUserIDKey = "current_user_id"
//extension Sessions.Session {
//	var currentUser: User? {
//		get {
//			if let userID = data[currentUserIDKey]?.int, let user = try? User.find(userID) {
//				return user
//			}
//			return nil
//		}
//		set {
//			data[currentUserIDKey] = newValue?.id
//		}
//	}
//}

extension Request {
	func user() -> User? {
		guard let user = try? auth.user() as? User else {
			return nil
		}
		
		return user
	}
	
	func protected() throws -> (User, Int) {
		guard let user = user(), let userId = user.id?.int else {
			throw Abort.custom(status: .forbidden, message: "Invalid credentials.")
		}
		
		return (user, userId)
	}
	
	func usernamePassword() throws -> UsernamePassword {
		guard let json = json else { throw Abort.badRequest }
		
		guard let username: String = try json.extract("username"),
			let password: String = try json.extract("password") else {
				throw Abort.custom(status: .badRequest, message: "Invalid credentials")
		}
		
		return UsernamePassword(username: username, password: password)
	}
}

//public class UsernamePasswordSession: Credentials {
//	/// Username or email address
//	public let username: String
//	
//	/// Password (unhashed)
//	public let password: String
//	
//	/// Request
//	public let request: Request
//	
//	/// Initializer for PasswordCredentials
//	public init(username: String, password: String, request: Request) {
//		self.username = username
//		self.password = password
//		self.request = request
//	}
//}
