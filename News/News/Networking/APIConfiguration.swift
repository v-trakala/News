//
//  APIConfiguration.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import Foundation

/// Все, что зависит от окружения (dev/stage/prod), живет здесь, а не размазано по сервисам.
nonisolated enum APIConfiguration {
	/// dummyjson.com — бесплатный публичный API без ключа.
	/// Дает /posts (список), /posts/{id} (детали) и /auth/login — как раз то,
	/// что нужно для этапов 0..N (пагинация, токены, refresh).
	static let baseURL = URL(string: "https://dummyjson.com")!
}
