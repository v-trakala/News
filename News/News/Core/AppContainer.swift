//
//  ApplicationContainer.swift
//  News
//
//  Created by valery.trakala on 16/10/2026.
//

import SwiftUI

@MainActor
final class AppContainer {
	let tokenStorage: TokenStorage
	let apiClient: APIClient
	let authService: AuthService
	let newsService: NewsService
	let sessionState: SessionState
	
	init() {
		// Собираем снизу вверх: сначала то, у чего нет зависимостей,
		// потом то, что их требует.
		let ts = InMemoryTokenStorage()
		let api = DefaultAPIClient()
		let session = SessionState()

		self.tokenStorage = ts
		self.apiClient = api
		self.sessionState = session
		self.authService = AuthServiceDummy(
			tokenStorage: ts,
			apiClient: api,
			sessionState: session
		)
		self.newsService = NewsAPIService(apiClient: api)
	}
}
