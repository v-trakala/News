//
//  NewsEndpoint.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import Foundation

/// Каталог запросов конкретной фичи.
///
/// Важно: он лежит рядом с `NewsService`, а НЕ внутри модуля Networking.
/// Иначе низкоуровневый модуль начнет знать про новости, потом про авторизацию,
/// потом про профиль — и превратится в god-object вида `NetworkManager`,
/// который зависит от всех фич сразу. Зависимости должны идти только вниз:
/// Feature -> Networking, никогда наоборот.
nonisolated enum NewsEndpoint {
	case articles(limit: Int, skip: Int)
	case article(id: Int)

	var endpoint: Endpoint {
		switch self {
		case .articles(let limit, let skip):
			return Endpoint(
				path: "posts",
				method: .get,
				query: [
					"limit": String(limit),
					"skip": String(skip)
				]
			)
		case .article(let id):
			return Endpoint(path: "posts/\(id)", method: .get)
		}
	}
}
