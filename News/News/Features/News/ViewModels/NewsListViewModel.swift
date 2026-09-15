//
//  NewsListViewModel.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class NewsListViewModel {
	private(set) var state: LoadingState<[Article]> = .idle

	private let service: NewsService

	init(service: NewsService = NewsAPIService()) {
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
			let articles = try await service.fetchArticles()
			state = .loaded(articles)
		} catch {
			guard !error.isCancellation else {
				state = .idle
				return
			}
			state = .failed(error.userFacingMessage)
		}
	}
}
