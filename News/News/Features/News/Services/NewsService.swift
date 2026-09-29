//
//  NewsService.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import Foundation

protocol NewsService: Sendable {
	func fetchArticles(limit: Int, skip: Int) async throws -> [Article]
	func fetchArticle(id: Int) async throws -> Article
}

extension NewsService {
	/// Дефолты для первой страницы (в протоколе default-аргументы недоступны).
	func fetchArticles() async throws -> [Article] {
		try await fetchArticles(limit: 20, skip: 0)
	}
}

final class NewsAPIService: NewsService {
	private let apiClient: APIClient

	init(apiClient: APIClient = DefaultAPIClient()) {
		self.apiClient = apiClient
	}

	func fetchArticles(limit: Int, skip: Int) async throws -> [Article] {
		let page = try await apiClient.send(
			NewsEndpoint.articles(limit: limit, skip: skip).endpoint,
			as: ArticlesPageDTO.self
		)
		return page.posts.map { $0.toDomain() }
	}

	func fetchArticle(id: Int) async throws -> Article {
		let dto = try await apiClient.send(
			NewsEndpoint.article(id: id).endpoint,
			as: ArticleDTO.self
		)
		return dto.toDomain()
	}
}
