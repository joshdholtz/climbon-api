import Vapor
import VaporPostgreSQL
import Auth
import Sessions
import Cache
import HTTP

import VaporS3Signer
import S3SignerAWS

import Foundation

let drop = Droplet()

// Enabling CORS
let configuration = CORSConfiguration(allowedOrigin: .originBased,
                                      allowedMethods: [.get, .post, .options, .delete, .patch, .put],
                                      allowedHeaders: ["Accept", "Authorization", "Content-Type", "Cookie"],
                                      allowCredentials: true,
                                      cacheExpiration: 600,
                                      exposedHeaders: ["Cache-Control", "Content-Language", ""])
drop.middleware.insert(CORSMiddleware(configuration: configuration), at: 0)

// Enable S3 Signer
try drop.addProvider(VaporS3Signer.Provider.self)
guard let s3BucketName = drop.config["vapor-S3Signer", "bucket"]?.string else {
	throw Provider.S3ProviderError.config("No 'bucket' key in vapor-S3Signer.json config file.")
}

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

drop.get("api/s3/presignedurl") { (request) -> ResponseRepresentable in
	
	// Must be logged in
	let (_, userId) = try request.protected()
	
	// Make sure signer provider enabled
	guard let s3Signer = drop.s3Signer else {
		throw Abort.serverError
	}
	
	// Generate filename
	let filename = [UUID.init().uuidString, request.query?["name"]?.string]
		.flatMap({$0})
		.joined(separator: "_")
	
	// Generate URL
	let urlString = [
		"https://\(s3Signer.region.host)",
		s3BucketName,
		filename
		].joined(separator: "/")
	
	let presignedURL = try s3Signer.presignedURLV4(
		httpMethod: .put,
		urlString: urlString,
		expiration: TimeFromNow.oneHour,
		headers: [:]
	)
	
	guard let url = URL(string: presignedURL.urlString) else {
			throw Abort.serverError
	}

	return try JSON(node: ["url": presignedURL.urlString])
}

drop.run()
