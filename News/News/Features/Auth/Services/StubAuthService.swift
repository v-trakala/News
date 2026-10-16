//
//  StubAuthService.swift
//  News
//
//  Created by valery.trakala on 16/10/2026.
//

import Foundation

#if DEBUG
/// Стаб для превью и ручной проверки состояний логина без сети.
final class StubAuthService: AuthService {
	private let session: AuthenticatedSession
	private let error: Error?
	private let sessionState: SessionState

	init(
		sessionState: SessionState,
		session: AuthenticatedSession = StubAuthService.sampleSession,
		error: Error? = nil
	) {
		self.sessionState = sessionState
		self.session = session
		self.error = error
	}

	func login(username: String, password: String) async throws {
		if let error { throw error }
		let session = self.session
		await MainActor.run {
			sessionState.state = .authenticated(session)
		}
	}

	func logout() async {
		await MainActor.run {
			sessionState.state = .unauthenticated
		}
	}

	func refreshSession() async throws {
		if let error { throw error }
	}

	static let sampleSession = AuthenticatedSession(
		id: 1,
		username: "emilys",
		firstName: "Emily",
		imageURL: URL(string: "https://dummyjson.com/icon/emilys/128")
	)
}
#endif
