//
//  AuthViewModel.swift
//  SuperDex
//

import Foundation
import Supabase

@MainActor
@Observable
final class AuthViewModel {
    enum State {
        case loading
        case signedOut
        case signedIn(User)
    }

    var state: State = .loading
    var isWorking = false
    var errorMessage: String?

    var currentUser: User? {
        if case .signedIn(let user) = state { return user }
        return nil
    }

    private let client = SupabaseManager.client

    init() {
        Task { await observeAuthChanges() }
    }

    private func observeAuthChanges() async {
        for await (event, session) in client.auth.authStateChanges {
            switch event {
            case .initialSession, .signedIn, .tokenRefreshed, .userUpdated:
                if let user = session?.user {
                    state = .signedIn(user)
                } else {
                    state = .signedOut
                }
            case .signedOut:
                state = .signedOut
            default:
                break
            }
        }
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil
        isWorking = true
        defer { isWorking = false }
        do {
            try await client.auth.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp(email: String, password: String) async {
        errorMessage = nil
        isWorking = true
        defer { isWorking = false }
        do {
            let response = try await client.auth.signUp(email: email, password: password)
            if response.session == nil {
                errorMessage = "Check your email to confirm your account."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        errorMessage = nil
        isWorking = true
        defer { isWorking = false }
        do {
            try await client.auth.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
