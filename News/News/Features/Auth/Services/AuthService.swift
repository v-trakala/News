//
//  AuthService.swift
//  News
//
//  Created by valery.trakala on 29/09/2026.
//

/// Контракт слоя Auth.
///
/// Сервис nonisolated — он про бизнес-логику и сеть, не про UI.
/// Запись в SessionState (который @MainActor) делается через await MainActor.run,
/// чтобы граница главного актора была явной.
///
/// Все методы возвращают Void: токены сохраняются в TokenStorage,
/// AuthenticatedSession ставится в SessionState — сервис сам обновляет
/// оба побочных эффекта. Вызывающий просто смотрит на SessionState.
protocol AuthService: Sendable {
	func login(username: String, password: String) async throws
	func logout() async
	func refreshSession() async throws
}

final class AuthServiceDummy: AuthService {
	private let tokenStorage: TokenStorage
	private let apiClient: APIClient
	private let sessionState: SessionState

	init(
		tokenStorage: TokenStorage,
		apiClient: APIClient,
		sessionState: SessionState
	) {
		self.tokenStorage = tokenStorage
		self.apiClient = apiClient
		self.sessionState = sessionState
	}

	func login(username: String, password: String) async throws {
		do {
			let endpoint = AuthEndpoint.login(
				username: username,
				password: password
			).endpoint
			let response = try await apiClient.send(endpoint, as: LoginResponseDTO.self)

			await tokenStorage.save(response.toTokenPair())
			let session = response.toSession()
			await MainActor.run {
				sessionState.state = .authenticated(session)
			}
		} catch APIError.server(let code) where code == 400 {
			throw AuthError.invalidCredentials
		}
	}

	func logout() async {
		await tokenStorage.clear()
		await MainActor.run {
			sessionState.state = .unauthenticated
		}
	}

	func refreshSession() async throws {
		guard let refreshToken = await tokenStorage.load()?.refreshToken else {
			throw AuthError.sessionExpired
		}

		let endpoint = AuthEndpoint.refresh(refreshToken: refreshToken).endpoint
		let response = try await apiClient.send(endpoint, as: RefreshResponseDTO.self)

		await tokenStorage.save(response.toTokenPair())
		// SessionState при refresh НЕ меняем: сессия та же, обновились только токены.
		// UI об этом знать не должен.
	}
}
