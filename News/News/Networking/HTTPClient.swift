//
//  HTTPClient.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import Foundation

/// Самый низкий уровень: URLRequest -> (Data, HTTPURLResponse).
/// Ничего не знает ни про baseURL, ни про JSON, ни про домен.
///
/// Зачем отдельный протокол:
///  - в тестах подменяется stub-ом (или URLProtocol) без сети;
///  - сюда, и только сюда, добавляются retry / логирование / метрики;
///  - URLSession можно заменить (background session, gRPC-мост, mock-сервер)
///    не трогая ни один сервис.

nonisolated protocol HTTPClient: Sendable {
	func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

final class URLSessionHTTPClient: HTTPClient {
	private let session: URLSession
	
	init(session: URLSession = .shared) {
		self.session = session
	}
	
	func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
		do {
			let (data, response) = try await session.data(for: request)
			guard let httpResponse = response as? HTTPURLResponse else {
				throw APIError.invalidResponse
			}
			return (data, httpResponse)
		} catch let error as URLError {
			throw error.code == .cancelled ? APIError.cancelled : APIError.transport(error)
		}
	}
}



