//
//  ArticleDTO.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import Foundation

/// Транспортные модели: повторяют формат ответа dummyjson.com 1:1.
/// Живут внутри слоя сервиса и наружу не отдаются.
nonisolated struct ArticlesPageDTO: Decodable {
	let posts: [ArticleDTO]
	let total: Int
	let skip: Int
	let limit: Int
}

nonisolated struct ArticleDTO: Decodable {
	struct Reactions: Decodable {
		let likes: Int
		let dislikes: Int
	}

	let id: Int
	let title: String
	let body: String
	// Опциональные — потому что на детальном ответе поля могут отсутствовать,
	// и падать декодером из-за этого нельзя.
	let tags: [String]?
	let views: Int?
	let reactions: Reactions?
}

nonisolated extension ArticleDTO {
	func toDomain() -> Article {
		Article(
			id: id,
			title: title,
			body: body,
			tags: tags ?? [],
			views: views ?? 0,
			likes: reactions?.likes ?? 0
		)
	}
}
