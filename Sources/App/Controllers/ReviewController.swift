import Vapor
import HTTP

final class ReviewController: ResourceRepresentable {
	func index(request: Request) throws -> ResponseRepresentable {
		return try Review.all().makeNode().converted(to: JSON.self)
	}
	
	func create(request: Request) throws -> ResponseRepresentable {
		let (_, userId) = try request.protected()
		
		var review = try request.review(userId: userId)
		try review.validate()
		try review.save()
		return review
	}
	
	func show(request: Request, review: Review) throws -> ResponseRepresentable {
		return review
	}
	
	func delete(request: Request, review: Review) throws -> ResponseRepresentable {
		try review.delete()
		return JSON([:])
	}
	
	func update(request: Request, review: Review) throws -> ResponseRepresentable {
		var review = review
		try review.patch(node: request.json?.makeNode())
		try review.save()
		return review
	}
	
	func makeResource() -> Resource<Review> {
		return Resource(
			index: index,
			store: create,
			show: show,
			replace: nil,
			modify: update,
			destroy: delete,
			clear: nil
		)
	}
}

extension Request {
	func review(userId: Int) throws -> Review {
		guard let json = json else { throw Abort.badRequest }
		return try Review(node: json, userId: userId)
	}
}