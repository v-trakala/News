//
//  AuthDTO.swift
//  News
//
//  Created by valery.trakala on 29/09/2026.
//

import Foundation

// MARK: - Request

/// Тело запроса `POST /auth/login`. Наружу из слоя Auth не отдаётся.
/// `expiresInMins` управляет TTL access-токена — дефолт 60 (боевой),
/// в отладке передаётся `1`, чтобы быстро поймать 401 и увидеть refresh-флоу.
struct LoginRequestDTO: Encodable {
	let username: String
	let password: String
	let expiresInMins: Int

	// Явный init нужен только ради default-значения — memberwise init
	// в Swift дефолтов не поддерживает.
	init(username: String, password: String, expiresInMins: Int = 60) {
		self.username = username
		self.password = password
		self.expiresInMins = expiresInMins
	}
}

/// Тело запроса `POST /auth/refresh`. Refresh-токен по контракту dummyjson
/// идёт в теле, не в заголовке.
struct RefreshRequestDTO: Encodable {
	let refreshToken: String
	let expiresInMins: Int

	init(refreshToken: String, expiresInMins: Int = 60) {
		self.refreshToken = refreshToken
		self.expiresInMins = expiresInMins
	}
}

// MARK: - Response

/// Ответ `POST /auth/login`. Содержит и профиль, и пару токенов —
/// маппится в две разные доменные модели: `AuthenticatedSession` (для UI)
/// и `AccessTokenPair` (для TokenStorage).
///
/// Поля `email`, `lastName`, `gender` в ответе есть, но UI их сейчас не показывает —
/// не тащим в модель. Появится экран «Профиль» — добавим тогда.
struct LoginResponseDTO: Decodable {
	let id: Int
	let username: String
	let firstName: String
	let image: String?
	let accessToken: String
	let refreshToken: String
}

extension LoginResponseDTO {
	func toSession() -> AuthenticatedSession {
		AuthenticatedSession(
			id: id,
			username: username,
			firstName: firstName,
			imageURL: image.flatMap(URL.init(string:))
			// flatMap: если image == nil, оставим nil; если строка, пробуем распарсить URL.
			// Битая строка тоже даст nil — не роняем логин из-за косметики.
		)
	}

	func toTokenPair() -> AccessTokenPair {
		AccessTokenPair(
			accessToken: accessToken,
			refreshToken: refreshToken
		)
	}
}

/// Ответ `POST /auth/refresh`. В нём НЕТ данных профиля — только новая пара токенов.
/// Логично: рефреш не запрашивает профиль, он только обновляет сессию.
struct RefreshResponseDTO: Decodable {
	let accessToken: String
	let refreshToken: String
}

extension RefreshResponseDTO {
	func toTokenPair() -> AccessTokenPair {
		AccessTokenPair(
			accessToken: accessToken,
			refreshToken: refreshToken
		)
	}
}

/// Ответ `GET /auth/me` — форма как у `/auth/login`, но без токенов.
/// Нужен на шаге восстановления сессии: проверить валидность токена и
/// получить свежие данные пользователя.
///
/// Пока не используется — понадобится в шаге 8 (Keychain + auto-login).
/// Если не хочешь заводить заранее — удали и добавь тогда, когда позовём `/auth/me`.
struct MeResponseDTO: Decodable {
	let id: Int
	let username: String
	let firstName: String
	let image: String?
}

extension MeResponseDTO {
	func toSession() -> AuthenticatedSession {
		AuthenticatedSession(
			id: id,
			username: username,
			firstName: firstName,
			imageURL: image.flatMap(URL.init(string:))
		)
	}
}
