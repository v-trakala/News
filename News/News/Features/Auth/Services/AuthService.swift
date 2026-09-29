//
//  AuthService.swift
//  News
//
//  Created by valery.trakala on 29/09/2026.
//


protocol AuthService {
	func login(username: String, password: String) async throws -> AuthenticatedSession
	func logout() async throws
	func refreshSession() async throws -> AuthenticatedSession
}

final class AuthServiceDummy: AuthService {
	// `tokenStorage: AnyObject` — плейсхолдер до шага 3. Как только появится
	// протокол `TokenStorage`, поменяем на него — и сможем реально сохранять
	// пару токенов после логина/refresh.
	private let tokenStorage: AnyObject
	private let apiClient: APIClient

	init(tokenStorage: AnyObject, apiClient: APIClient) {
		self.tokenStorage = tokenStorage
		self.apiClient = apiClient
	}
	
	func login(username: String, password: String) async throws -> AuthenticatedSession {
		return AuthenticatedSession(id: 1, username: "", firstName: "", imageURL: nil)
	}
	
	func logout() async throws {
		
	}
	
	func refreshSession() async throws -> AuthenticatedSession {
		return AuthenticatedSession(id: 1, username: "", firstName: "", imageURL: nil)
	}
	
	private func refresh() async throws {
		
	}
}
