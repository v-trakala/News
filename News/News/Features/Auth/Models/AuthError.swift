//
//  AuthError.swift
//  News
//
//  Created by valery.trakala on 28/09/2026.
//

import Foundation

enum AuthError: Error, Equatable {
	case invalidCredentials
	case sessionExpired
	case network(APIError)
}
