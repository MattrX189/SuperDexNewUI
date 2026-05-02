//
//  LoginView.swift
//  SuperDex
//

import SwiftUI

struct LoginView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case signIn = "Sign In"
        case signUp = "Sign Up"
        var id: Self { self }
    }

    @Environment(AuthViewModel.self) private var auth

    @State private var mode: Mode = .signIn
    @State private var email = ""
    @State private var password = ""

    private var canSubmit: Bool {
        !email.isEmpty && password.count >= 6 && !auth.isWorking
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Text("SuperDex")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    Text(mode == .signIn ? "Welcome back" : "Create your account")
                        .foregroundStyle(.white.opacity(0.6))
                }

                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .colorScheme(.dark)

                VStack(spacing: 12) {
                    fieldBackground {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .foregroundStyle(.white)
                    }

                    fieldBackground {
                        SecureField("Password", text: $password)
                            .textContentType(mode == .signUp ? .newPassword : .password)
                            .foregroundStyle(.white)
                    }
                }

                if let message = auth.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: submit) {
                    HStack {
                        Spacer()
                        if auth.isWorking {
                            ProgressView().tint(.black)
                        } else {
                            Text(mode.rawValue).fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .background(canSubmit ? Color.white : Color.white.opacity(0.3))
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!canSubmit)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
        .onChange(of: mode) { _, _ in auth.errorMessage = nil }
    }

    @ViewBuilder
    private func fieldBackground<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func submit() {
        Task {
            switch mode {
            case .signIn:
                await auth.signIn(email: email, password: password)
            case .signUp:
                await auth.signUp(email: email, password: password)
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthViewModel())
}
