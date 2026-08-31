//
//  RequestBuilder.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import Foundation

/// Единственная ответственность: `Endpoint` (что мы хотим позвать)
/// -> `URLRequest` (как это выглядит на проводе).
///
/// Почему отдельный тип, а не приватный метод в `APIClient`:
///  - это чистая функция без сети: тестируется без стабов и ожиданий
///    (проверяем итоговый URL, метод, заголовки, body);
///  - здесь одно место для «общих» заголовков: Accept, App-Version,
///    Accept-Language, а на следующих этапах — Authorization;
///  - `APIClient` перестает знать про baseURL и правила формирования URL.
nonisolated protocol RequestBuilder: Sendable {
	func makeRequest(for endpoint: Endpoint) throws -> URLRequest
}

nonisolated final class DefaultRequestBuilder: RequestBuilder {
	private let baseURL: URL
	private let defaultHeaders: [String: String]

	init(
		baseURL: URL = APIConfiguration.baseURL,
		defaultHeaders: [String: String] = ["Accept": "application/json"]
	) {
		self.baseURL = baseURL
		self.defaultHeaders = defaultHeaders
	}

	func makeRequest(for endpoint: Endpoint) throws -> URLRequest {
		guard var components = URLComponents(
			url: baseURL.appending(path: endpoint.path),
			resolvingAgainstBaseURL: false
		) else {
			throw APIError.invalidURL
		}

		if !endpoint.query.isEmpty {
			// Сортировка — чтобы URL был детерминированным и его можно было
			// сравнивать в тестах (у словаря порядок не определен).
			components.queryItems = endpoint.query
				.sorted { $0.key < $1.key }
				.map { URLQueryItem(name: $0.key, value: $0.value) }
		}

		guard let url = components.url else {
			throw APIError.invalidURL
		}

		var request = URLRequest(url: url)
		request.httpMethod = endpoint.method.rawValue
		request.httpBody = endpoint.body

		// Заголовки эндпоинта важнее дефолтных — поэтому применяем их вторыми.
		for (field, value) in defaultHeaders {
			request.setValue(value, forHTTPHeaderField: field)
		}
		for (field, value) in endpoint.headers {
			request.setValue(value, forHTTPHeaderField: field)
		}
		if endpoint.body != nil, request.value(forHTTPHeaderField: "Content-Type") == nil {
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		}

		return request
	}
}
