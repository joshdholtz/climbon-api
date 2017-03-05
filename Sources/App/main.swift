import Vapor
import VaporPostgreSQL
import Auth
import Sessions

let drop = Droplet()

// Adding preparations for models
drop.preparations += User.self
drop.preparations += Location.self
drop.preparations += Route.self
drop.preparations += Review.self

// Auth
let auth = AuthMiddleware(user: User.self)
drop.middleware.append(auth)

// Sessions
let memory = MemorySessions()
let sessions = SessionsMiddleware(sessions: memory)
drop.middleware.append(sessions)

// Adding database provider
try drop.addProvider(VaporPostgreSQL.Provider.self)

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("api/locations", LocationController())
drop.resource("api/reviews", ReviewController())
drop.resource("api/routes", RouteController())
drop.resource("api/users", UserController())

let sessionsControllers = SessionController()
drop.post("api/login", handler: sessionsControllers.login)
drop.get("api/current", handler: sessionsControllers.current)

drop.run()
