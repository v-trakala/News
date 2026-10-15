//
//  TokenStorage.swift
//  News
//
//  Created by valery.trakala on 15/10/2026.
//

protocol TokenStorage: Sendable {
	func load() async -> AccessTokenPair?
	func save(_ pair: AccessTokenPair) async
	func clear() async
}
