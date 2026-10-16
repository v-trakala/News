//
//  LoginView.swift
//  News
//
//  Created by valery.trakala on 16/10/2026.
//

import SwiftUI

struct LoginView: View {
	@State private var viewModel: LoginViewModel

	init(authService: AuthService) {
		_viewModel = State(initialValue: LoginViewModel(authService: authService))
	}

	// Отдельный init для превью и тестов — принимает уже готовую VM с подменёнными зависимостями.
	init(viewModel: LoginViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		VStack(spacing: 24) {
			Spacer()

			Text("Welcome")
				.font(.largeTitle.bold())

			VStack(spacing: 12) {
				TextField("Username", text: $viewModel.username)
					.textContentType(.username)
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
				SecureField("Password", text: $viewModel.password)
					.textContentType(.password)
			}
			.textFieldStyle(.roundedBorder)

			if let message = viewModel.state.errorMessage {
				Text(message)
					.font(.footnote)
					.foregroundStyle(.red)
					.frame(maxWidth: .infinity, alignment: .leading)
			}

			Button {
				// Button-handler синхронный, поэтому Task { } — единственный
				// способ запустить async-метод VM. Это тот самый случай «граница
				// с императивным миром», разрешённый CLAUDE.md.
				Task { await viewModel.login() }
			} label: {
				if viewModel.state.isLoading {
					ProgressView()
						.frame(maxWidth: .infinity)
				} else {
					Text("Sign in")
						.frame(maxWidth: .infinity)
				}
			}
			.buttonStyle(.borderedProminent)
			.controlSize(.large)
			.disabled(!viewModel.canSubmit)

			Spacer()
		}
		.padding()
	}
}

#if DEBUG

#Preview("Пустая форма") {
	let session = SessionState()
	return LoginView(
		viewModel: LoginViewModel(authService: StubAuthService(sessionState: session))
	)
}

#Preview("Ошибка — неверный пароль") {
	let session = SessionState()
	let vm = LoginViewModel(
		authService: StubAuthService(
			sessionState: session,
			error: AuthError.invalidCredentials
		)
	)
	vm.username = "emilys"
	vm.password = "wrong"
	return LoginView(viewModel: vm)
}

#endif
