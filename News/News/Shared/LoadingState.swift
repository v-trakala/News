//
//  LoadingState.swift
//  News
//
//  Created by valery.trakala on 31/08/2026.
//

import Foundation

/// Состояние асинхронной загрузки одним значением вместо трех независимых
/// (`isLoading` + `data` + `error`), которые легко привести в невозможную
/// комбинацию (грузим и уже есть ошибка и данные одновременно).
enum LoadingState<Value: Sendable>: Sendable {
	case idle
	case loading
	case loaded(Value)
	case failed(String)

	var value: Value? {
		if case .loaded(let value) = self { return value }
		return nil
	}

	var isLoading: Bool {
		if case .loading = self { return true }
		return false
	}

	var errorMessage: String? {
		if case .failed(let message) = self { return message }
		return nil
	}
}
