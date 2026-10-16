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

	let service: NewsService

	init(service: NewsService) {
		self.service = service
	}

	func loadIfNeeded() async {
		guard case .idle = state else { return }
		state = .loading
		await performLoad()
	}

	func reload() async {
		if case .failed = state {
			state = .loading
		}
		await performLoad()
	}

	private func performLoad() async {
		do {
			let articles = try await service.fetchArticles()
			//
			try? await Task.sleep(nanoseconds: 2_000_000_000)
			//
			state = .loaded(articles)
		} catch {
			guard !error.isCancellation else { return }
			state = .failed(error.userFacingMessage)
		}
	}
}
