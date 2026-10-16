//
//  ContentView.swift
//  News
//
//  Created by valery.trakala on 16/08/2026.
//

import SwiftUI

@main
struct Application: App {
	@State var container = AppContainer()
	
	var body: some Scene {
		WindowGroup {
			ContainerView(container: container)
		}
	}
}


struct ContainerView: View {
	let container: AppContainer
	
	var body: some View {
		switch container.sessionState.state {
		case .unauthenticated:
			EmptyView()
		case .authenticated(let session):
			NewsApp(service: container.newsService)
		}
	}
}
