//
//  AuthEndpoints.swift
//  News
//
//  Created by valery.trakala on 28/09/2026.
//
import Foundation

private struct LoginRequestDTO: Encodable {
	let username: String
	let password: String
	let expiresInMins: Int
}

private struct RefreshRequestDTO: Encodable {
	let refreshToken: String
	let expiresInMins: Int
}

enum AuthEndpoint {
	case login(username: String, password: String, expiresInMins: Int)
	
	var endpoint: Endpoint {
		switch self {
		case .login(let username, let password, let expiresInMins):
			let dto = LoginRequestDTO(
				username: username,
				password: password,
				expiresInMins: expiresInMins
			)
			return Endpoint(
				path: "auth/login",
				method: .post,
				body: try? JSONEncoder().encode(dto)
			)
		}
	}
}


/*
 POST https://dummyjson.com/auth/login
 Content-Type: application/json

 {
	"username": "emilys",
	"password": "emilyspass",
	"expiresInMins": 1
 }
 
 {
	"id": 1,
	"username": "emilys",
	"email": "emily.johnson@x.dummyjson.com",
	"firstName": "Emily",
	"lastName": "Johnson",
	"gender": "female",
	"image": "https://dummyjson.com/icon/emilys/128",
	"accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
	"refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 }
 
 
 { "message": "Invalid credentials" }
 
 
 ----------------
 
 POST https://dummyjson.com/auth/refresh
 Content-Type: application/json

 {
	"refreshToken": "<тот, что получили при логине>",
	"expiresInMins": 1
 }
 
 {
	"accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
	"refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 }
 
 { "message": "Invalid/Expired token" }
 
 
 
 ----------------
 
 GET https://dummyjson.com/auth/me
 Authorization: Bearer <accessToken>
 
 {
	"id": 1,
	"username": "emilys",
	"email": "emily.johnson@x.dummyjson.com",
	"firstName": "Emily",
	"lastName": "Johnson",
	...
 }
 
 
 { "name": "JsonWebTokenError", "message": "invalid signature" }
 
 
 */
