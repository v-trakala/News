//
//  APIError.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import Foundation

/// Единая ошибка транспортного слоя.
/// Смысл: наружу (в сервисы и ViewModel) не должны утекать ни `URLError`,
/// ни `DecodingError` — иначе каждый вызывающий будет заново разбирать
/// частные случаи URLSession.
nonisolated enum APIError: Error, Equatable {
	case invalidURL
	/// Ответ не является HTTP-ответом.
	case invalidResponse
	/// 401 — выделен отдельно, потому что на следующих этапах именно он
	/// будет триггерить refresh токена в одном месте.
	case unauthorized
	case server(statusCode: Int)
	case decoding(description: String)
	case transport(URLError)
	case cancelled
}

nonisolated extension APIError {
	/// Сообщение для UI. На реальном проекте здесь были бы локализованные строки.
	var message: String {
		switch self {
		case .invalidURL:
			return "Некорректный адрес запроса."
		case .invalidResponse:
			return "Сервер вернул неожиданный ответ."
		case .unauthorized:
			return "Требуется авторизация."
		case .server(let statusCode):
			return "Ошибка сервера (\(statusCode))."
		case .decoding:
			return "Не удалось разобрать ответ сервера."
		case .transport:
			return "Проблема с сетью. Проверьте подключение."
		case .cancelled:
			return "Запрос отменен."
		}
	}
}

nonisolated extension Error {
	/// Отмена — это не ошибка для пользователя: SwiftUI отменяет `.task`
	/// при исчезновении экрана, и показывать алерт в этот момент нельзя.
	var isCancellation: Bool {
		if self is CancellationError { return true }
		if let apiError = self as? APIError, case .cancelled = apiError { return true }
		if let urlError = self as? URLError, urlError.code == .cancelled { return true }
		return false
	}

	var userFacingMessage: String {
		(self as? APIError)?.message ?? localizedDescription
	}
}
