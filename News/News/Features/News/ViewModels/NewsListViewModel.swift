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
	/// UI читает только это свойство — одно состояние, никаких противоречивых флагов.
	private(set) var state: LoadingState<[Article]> = .idle

	private let service: NewsService

	/// Этап 0: зависимость приходит через default-аргумент — это «наивный DI».
	/// Работает, но прячет граф зависимостей; на следующем этапе заменим
	/// на явную сборку (фабрика/контейнер) в одной точке приложения.
	init(service: NewsService = NewsAPIService()) {
		self.service = service
	}

	/// Вызывается из `.task` — SwiftUI сам отменит операцию при уходе с экрана.
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
			// Отмена — не ошибка: возвращаемся в idle, чтобы при повторном
			// появлении экрана загрузка началась заново.
			guard !error.isCancellation else {
				state = .idle
				return
			}
			state = .failed(error.userFacingMessage)
		}
	}
}
