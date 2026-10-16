//
//  LoginViewModel.swift
//  News
//
//  Created by valery.trakala on 16/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class LoginViewModel {
	var username: String = ""
	var password: String = ""

	// Состояние запроса. Void потому что успех = SessionState обновлён сервисом,
	// самому экрану нести данные некуда — View перейдёт на NewsListView.
	private(set) var state: LoadingState<Void> = .idle

	private let authService: AuthService

	init(authService: AuthService) {
		self.authService = authService
	}

	/// Можно ли нажать «войти». View дизейблит кнопку, когда false.
	/// Валидация минимальная: оба поля непустые, запрос не идёт.
	var canSubmit: Bool {
		!username.isEmpty && !password.isEmpty && !state.isLoading
	}

	func login() async {
		guard canSubmit else { return }
		state = .loading
		do {
			try await authService.login(username: username, password: password)

		} catch where error.isCancellation {

			state = .idle
		} catch AuthError.invalidCredentials {
			state = .failed("Неверный логин или пароль")
		} catch {
			state = .failed(error.userFacingMessage)
		}
	}
}
