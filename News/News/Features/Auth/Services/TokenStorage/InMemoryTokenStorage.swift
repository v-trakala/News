//
//  InMemoryTokenStorage.swift
//  News
//
//  Created by valery.trakala on 15/10/2026.
//

actor InMemoryTokenStorage: TokenStorage {
	private var pair: AccessTokenPair?
	
	func load() async -> AccessTokenPair? {
		return pair
	}
	
	func save(_ pair: AccessTokenPair) async {
		self.pair = pair
	}
	
	func clear() async {
		pair = nil
	}
}
