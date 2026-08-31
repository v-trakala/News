//
//  Endpoint.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import Foundation

nonisolated enum HTTPMethod: String {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case patch = "PATCH"
	case delete = "DELETE"
}

/// Описание одного запроса в терминах API, без знания про baseURL,
/// заголовки авторизации и URLSession. Сервисы конструируют `Endpoint`,
/// `APIClient` превращает его в `URLRequest`.
nonisolated struct Endpoint {
	let path: String
	var method: HTTPMethod = .get
	var query: [String: String] = [:]
	var headers: [String: String] = [:]
	var body: Data?
}
