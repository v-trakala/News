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
///  - сюда, и только сюда, потом добавляются retry / логирование / метрики;
///  - URLSession можно заменить (background session, gRPC-мост, mock-сервер)
///    не трогая ни один сервис.
///
/// `nonisolated`: в проекте включен `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`,
/// то есть по умолчанию весь код исполняется на главном акторе. Сетевой слой
/// и сервисы явно выводятся из-под MainActor, чтобы парсинг и ожидание ответа
/// не занимали главный поток. UI и ViewModel, наоборот, остаются на MainActor.
nonisolated protocol HTTPClient: Sendable {
	func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

nonisolated final class URLSessionHTTPClient: HTTPClient {
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
