//
//  Article.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import Foundation

/// Доменная модель: то, чем оперируют ViewModel и UI.
/// Она специально отделена от DTO (`ArticleDTO`), чтобы смена/версионирование
/// API не тянуло за собой правки по всем экранам.
nonisolated struct Article: Identifiable, Hashable, Sendable {
	let id: Int
	let title: String
	let body: String
	let tags: [String]
	let views: Int
	let likes: Int
}
