//
//  NewsApp.swift
//  News
//
//  Created by valery.trakala on 16/08/2026.
//

import SwiftUI

struct NewsApp: View {
	let service: NewsService
	var body: some View {
		NewsListView(service: service)
	}
}


#Preview {
	NewsApp(service: StubNewsService())
}
