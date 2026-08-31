//
//  NewsDetailsView.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import SwiftUI

struct NewsDetailsView: View {
	@State private var viewModel: NewsDetailsViewModel

	/// Экран получает только идентификатор и сам грузит детали —
	/// это и есть второй запрос (`/posts/{id}`), а не переиспользование
	/// объекта из списка.
	init(articleID: Int) {
		_viewModel = State(initialValue: NewsDetailsViewModel(articleID: articleID))
	}

	init(viewModel: NewsDetailsViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		content
			.navigationTitle("Article")
			.navigationBarTitleDisplayMode(.inline)
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

		case .loaded(let article):
			ScrollView {
				VStack(alignment: .leading, spacing: 12) {
					Text(article.title)
						.font(.title2.bold())

					HStack(spacing: 12) {
						Label("\(article.views)", systemImage: "eye")
						Label("\(article.likes)", systemImage: "hand.thumbsup")
					}
					.font(.footnote)
					.foregroundStyle(.secondary)

					if !article.tags.isEmpty {
						Text(article.tags.map { "#\($0)" }.joined(separator: " "))
							.font(.footnote)
							.foregroundStyle(.tint)
					}

					Text(article.body)
						.font(.body)
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding()
			}

		case .failed(let message):
			ContentUnavailableView {
				Label("Не удалось загрузить статью", systemImage: "doc.questionmark")
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

#Preview {
	NavigationStack {
		NewsDetailsView(viewModel: NewsDetailsViewModel(articleID: 1, service: StubNewsService()))
	}
}
