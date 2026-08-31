//
//  NewsListView.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import SwiftUI

struct NewsListView: View {
	@State private var viewModel: NewsListViewModel

	init() {
		_viewModel = State(initialValue: NewsListViewModel())
	}

	/// Отдельный init для превью и тестов: сюда прокидывается ViewModel
	/// со стабовым сервисом.
	init(viewModel: NewsListViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		NavigationStack {
			content
				.navigationTitle("News")
				.navigationDestination(for: Article.self) { article in
					NewsDetailsView(articleID: article.id)
				}
		}
		.task {
			await viewModel.loadIfNeeded()
		}
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.state {
		case .idle, .loading:
			ProgressView()
				.controlSize(.large)
				.frame(maxWidth: .infinity, maxHeight: .infinity)

		case .loaded(let articles):
			List(articles) { article in
				NavigationLink(value: article) {
					ArticleRow(article: article)
				}
			}
			.listStyle(.plain)
			.refreshable {
				await viewModel.reload()
			}

		case .failed(let message):
			ContentUnavailableView {
				Label("Не удалось загрузить новости", systemImage: "wifi.exclamationmark")
			} description: {
				Text(message)
			} actions: {
				Button("Повторить") {
					Task { await viewModel.reload() }
				}
			}
		}
	}
}

private struct ArticleRow: View {
	let article: Article

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(article.title)
				.font(.headline)
			Text(article.body)
				.font(.subheadline)
				.foregroundStyle(.secondary)
				.lineLimit(2)
		}
		.padding(.vertical, 4)
	}
}

#Preview("Загружено") {
	NewsListView(viewModel: NewsListViewModel(service: StubNewsService()))
}

#Preview("Ошибка") {
	NewsListView(viewModel: NewsListViewModel(service: StubNewsService(error: APIError.transport(URLError(.notConnectedToInternet)))))
}
