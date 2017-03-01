//
//  ResourceController.swift
//  ClimbTime
//
//  Created by Josh Holtz on 3/1/17.
//
//

import Foundation

import Vapor

protocol ResourceController {
	static func register(droplet: Droplet, path: String)
}

extension Droplet {
	func register(path: String, controller: ResourceController.Type) {
		controller.register(droplet: self, path: path)
	}
}
