import Vapor
import VaporPostgreSQL

let drop = Droplet()

// Adding preparations for models
drop.preparations += Post.self

// Adding database provider
try drop.addProvider(VaporPostgreSQL.Provider.self)

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.register(path: "posts", controller: PostController.self)

drop.run()
