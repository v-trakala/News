//
//  AuthEndpoints.swift
//  News
//
//  Created by valery.trakala on 28/09/2026.
//
import Foundation

/// Каталог эндпоинтов авторизации. Лежит у фичи, не в `Networking/`, —
/// по тому же правилу, что и `NewsEndpoint`: низкоуровневый модуль не должен
/// знать про фичи.
///
/// `me` и `logout` тут пока нет. У dummyjson нет `POST /auth/logout` —
/// logout это локальное действие (очистка TokenStorage). `GET /auth/me`
/// понадобится в шаге 8 для валидации токена при автологине; добавим тогда.
enum AuthEndpoint {
	case login(username: String, password: String)
	case refresh(refreshToken: String)

	var endpoint: Endpoint {
		switch self {
		case .login(let username, let password):
			let dto = LoginRequestDTO(
				username: username,
				password: password
			)
			return Endpoint(
				path: "auth/login",
				method: .post,
				body: try? JSONEncoder().encode(dto)
			)
		case .refresh(let refreshToken):
			let dto = RefreshRequestDTO(
				refreshToken: refreshToken
			)
			return Endpoint(
				path: "auth/refresh",
				method: .post,
				body: try? JSONEncoder().encode(dto)
			)
		}
	}
}
