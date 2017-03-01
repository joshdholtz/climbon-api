import Vapor
import HTTP

final class PostController: ResourceController {
	static func register(droplet: Droplet, path: String) {
		let controller = PostController()
		
		drop.get(path, handler: controller.index)
		drop.post(path, handler: controller.create)
		drop.patch(path, String.self, handler: controller.update)
	}
	
	func index(request: Request) throws -> ResponseRepresentable {
		return try Post.all().makeNode().converted(to: JSON.self)
	}

	func create(request: Request) throws -> ResponseRepresentable {
		var post = try request.post()
		try post.save()
		return post
	}
	
	func update(request: Request, id: String) throws -> ResponseRepresentable {
		let new = try request.post()
		
		guard var post = try Post.find(id) else {
			throw Abort.notFound
		}
		post.content = new.content
		try post.save()
		return post
	}
}

extension Request {
	func post() throws -> Post {
		guard let json = json else { throw Abort.badRequest }
		print("JSON: \(json)")
		return try Post(node: json)
	}
}

//final class PostController: ResourceRepresentable {
//    func index(request: Request) throws -> ResponseRepresentable {
//        return try Post.all().makeNode().converted(to: JSON.self)
//    }
//
//    func create(request: Request) throws -> ResponseRepresentable {
//        var post = try request.post()
//        try post.save()
//        return post
//    }
//
//    func show(request: Request, post: Post) throws -> ResponseRepresentable {
//        return post
//    }
//
//    func delete(request: Request, post: Post) throws -> ResponseRepresentable {
//        try post.delete()
//        return JSON([:])
//    }
//
//    func clear(request: Request) throws -> ResponseRepresentable {
//        try Post.query().delete()
//        return JSON([])
//    }
//
//    func update(request: Request, post: Post) throws -> ResponseRepresentable {
//		let testPost = try? Post(from: "1")
//		print("post post: \(testPost??.id), \(testPost??.content)")
//		let new = try request.post()
//		var post = post
//		post.content = new.content
//		try post.save()
//        return post
//    }
//
//    func replace(request: Request, post: Post) throws -> ResponseRepresentable {
//        print("in replace")
//        try post.delete()
//        return try create(request: request)
//    }
//
//    func makeResource() -> Resource<Post> {
//        return Resource(
//            index: index,
//            store: create,
//            show: show,
//            replace: replace,
//            modify: update,
//            destroy: delete,
//            clear: clear
//        )
//    }
//}
//
