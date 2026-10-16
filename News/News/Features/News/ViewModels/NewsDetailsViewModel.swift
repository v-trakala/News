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

	init(articleID: Int, service: NewsService) {
		self.articleID = articleID
		self.service = service
	}

	func loadIfNeeded() async {
		guard case .idle = state else { return }
		state = .loading
		await performLoad()
	}

	func reload() async {
		// Флипаем в .loading только из .failed — см. NewsListViewModel.reload().
		if case .failed = state {
			state = .loading
		}
		await performLoad()
	}

	private func performLoad() async {
		do {
			let article = try await service.fetchArticle(id: articleID)
			state = .loaded(article)
		} catch {
			guard !error.isCancellation else {
				if case .loading = state { state = .idle }
				return
			}
			state = .failed(error.userFacingMessage)
		}
	}
}
