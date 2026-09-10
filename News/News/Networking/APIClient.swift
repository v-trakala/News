//
//  APIClient.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import Foundation

/// Уровень между сервисами и транспортом: собрать запрос (через `RequestBuilder`),
/// отправить (через `HTTPClient`), проверить статус-код, декодировать JSON.
///
/// Сервисы (`NewsService`, позже `AuthService`) знают только этот протокол
/// и ничего не знают про URLSession, baseURL и заголовки.
protocol APIClient: Sendable {
	func send<Response: Decodable>(_ endpoint: Endpoint, as type: Response.Type) async throws -> Response
}

final class DefaultAPIClient: APIClient {
	private let requestBuilder: RequestBuilder
	private let httpClient: HTTPClient
	private let decoder: JSONDecoder
	
	init(
		requestBuilder: RequestBuilder = DefaultRequestBuilder(),
		httpClient: HTTPClient = URLSessionHTTPClient(),
		decoder: JSONDecoder = JSONDecoder()
	) {
		self.requestBuilder = requestBuilder
		self.httpClient = httpClient
		self.decoder = decoder
	}
	
	func send<Response: Decodable>(_ endpoint: Endpoint, as type: Response.Type) async throws -> Response {
		let request = try requestBuilder.makeRequest(for: endpoint)
		let (data, response) = try await httpClient.perform(request)
		
		switch response.statusCode {
		case 200..<300:
			break
		case 401:
			throw APIError.unauthorized
		default:
			throw APIError.server(statusCode: response.statusCode)
		}
		
		do {
			return try decoder.decode(type, from: data)
		} catch {
			throw APIError.decoding(description: String(describing: error))
		}
	}
}
