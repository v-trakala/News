//
//  AuthenticatedSession.swift
//  News
//
//  Created by valery.trakala on 28/09/2026.
//

import Foundation


struct AuthenticatedSession: Identifiable, Hashable, Sendable {
	let id: Int
	let username: String
	let firstName: String
	let imageURL: URL?
}
