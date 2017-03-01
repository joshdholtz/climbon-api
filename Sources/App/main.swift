import Vapor
import VaporPostgreSQL

let drop = Droplet()

// Adding preparations for models
drop.preparations += Route.self

// Adding database provider
try drop.addProvider(VaporPostgreSQL.Provider.self)

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("api/routes", RouteController())

drop.run()

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
