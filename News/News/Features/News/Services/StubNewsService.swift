//
//  StubNewsService.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import Foundation

#if DEBUG
/// Стаб для превью и ручной проверки состояний без сети.
/// Ровно та причина, по которой `NewsService` — протокол.
final class StubNewsService: NewsService {
	private let articles: [Article]
	private let error: Error?
	private let delay: Duration

	init(
		articles: [Article] = StubNewsService.sampleArticles,
		error: Error? = nil,
		delay: Duration = .zero
	) {
		self.articles = articles
		self.error = error
		self.delay = delay
	}

	func fetchArticles(limit: Int, skip: Int) async throws -> [Article] {
		try await waitAndThrowIfNeeded()
		return Array(articles.dropFirst(skip).prefix(limit))
	}

	func fetchArticle(id: Int) async throws -> Article {
		try await waitAndThrowIfNeeded()
		guard let article = articles.first(where: { $0.id == id }) else {
			throw APIError.server(statusCode: 404)
		}
		return article
	}

	private func waitAndThrowIfNeeded() async throws {
		if delay != .zero {
			try await Task.sleep(for: delay)
		}
		if let error {
			throw error
		}
	}

	static let sampleArticles: [Article] = (1...12).map { index in
		Article(
			id: index,
			title: "Sample headline number \(index)",
			body: String(repeating: "Sample article body for item \(index). ", count: 8),
			tags: ["sample", index.isMultiple(of: 2) ? "tech" : "world"],
			views: index * 137,
			likes: index * 7
		)
	}
}
#endif
