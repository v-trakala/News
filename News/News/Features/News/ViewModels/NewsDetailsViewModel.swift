//
//  NewsDetailsViewModel.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class NewsDetailsViewModel {
	private(set) var state: LoadingState<Article> = .idle

	private let articleID: Int
	private let service: NewsService

	init(articleID: Int, service: NewsService = NewsAPIService()) {
		self.articleID = articleID
		self.service = service
	}

	func loadIfNeeded() async {
		guard case .idle = state else { return }
		await load()
	}

	func reload() async {
		await load()
	}

	private func load() async {
		state = .loading
		do {
			let article = try await service.fetchArticle(id: articleID)
			state = .loaded(article)
		} catch {
			guard !error.isCancellation else {
				state = .idle
				return
			}
			state = .failed(error.userFacingMessage)
		}
	}
}
