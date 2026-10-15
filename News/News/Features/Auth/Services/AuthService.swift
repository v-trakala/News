//
//  AuthService.swift
//  News
//
//  Created by valery.trakala on 29/09/2026.
//


protocol AuthService: Sendable {
	func login(username: String, password: String) async throws -> AuthenticatedSession
	func logout() async
	func refreshSession() async throws
}

final class AuthServiceDummy: AuthService {
	private let tokenStorage: TokenStorage
	private let apiClient: APIClient

	init(tokenStorage: TokenStorage, apiClient: APIClient) {
		self.tokenStorage = tokenStorage
		self.apiClient = apiClient
	}
	
	func login(username: String, password: String) async throws -> AuthenticatedSession {
		do {
			let endpoint = AuthEndpoint.login(username: username, password: password).endpoint
			let response = try await apiClient.send(endpoint, as: LoginResponseDTO.self)
			
			let tokenPair = response.toTokenPair()
			await tokenStorage.save(tokenPair)
			
			return response.toSession()
		} catch APIError.server(let code) where code == 400 {
			throw AuthError.invalidCredentials
		}
	}
	
	func logout() async {
		await tokenStorage.clear()
	}
	
	func refreshSession() async throws {
		guard let refreshToken = await tokenStorage.load()?.refreshToken else {
			throw AuthError.sessionExpired
		}
		
		let endpoint = AuthEndpoint.refresh(refreshToken: refreshToken).endpoint
		let response = try await apiClient.send(endpoint, as: RefreshResponseDTO.self)
		
		await tokenStorage.save(response.toTokenPair())
		
	}
}
