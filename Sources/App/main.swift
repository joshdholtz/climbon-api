import Vapor
import VaporPostgreSQL
import Auth
import Sessions
import Cache

let drop = Droplet()

// Enabling CORS
let configuration = CORSConfiguration(allowedOrigin: .originBased,
                                      allowedMethods: [.get, .post, .options, .delete, .patch, .put],
                                      allowedHeaders: ["Accept", "Authorization", "Content-Type", "Cookie"],
                                      allowCredentials: true,
                                      cacheExpiration: 600,
                                      exposedHeaders: ["Cache-Control", "Content-Language", ""])
drop.middleware.insert(CORSMiddleware(configuration: configuration), at: 0)

// Adding preparations for models
//drop.preparations += User.self
drop.preparations = [
	Location.self,
	Review.self,
	Route.self,
	User.self,
	
	FluentCache.Entity.self,
	
	Migration001CreateUser.self,
	Migration002CreateLocation.self,
	Migration003CreateRoute.self,
	Migration004CreateReview.self,
	Migration005ModifyRouteAddSetDate.self
]

// Adding database provider
try drop.addProvider(VaporPostgreSQL.Provider.self)

// Auth
let cache = FluentCache(database: drop.database!)
let auth = AuthMiddleware(user: User.self, cache: cache)
drop.middleware.append(auth)

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
drop.post("api/session", handler: sessionsControllers.login)
drop.get("api/session", handler: sessionsControllers.current)
drop.delete("api/session", handler: sessionsControllers.logout)

drop.run()
