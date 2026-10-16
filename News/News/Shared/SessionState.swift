//
//  SessionState.swift
//  News
//
//  Created by valery.trakala on 16/10/2026.
//

import SwiftUI

@MainActor
@Observable
final class SessionState {
	enum Kind: Sendable {
		case unauthenticated
		case authenticated(AuthenticatedSession)
	}
	
	var state: Kind = .authenticated(AuthenticatedSession(id: 1, username: "", firstName: "", imageURL: nil))
}
