//
//  UserProfileViewModel.swift
//  HomeScreen
//

import SwiftUI
import Supabase
import Auth

@MainActor
@Observable
final class UserProfileViewModel {
    var profile = UserProfileData()
    var isEditing = false
    var isLoading = false
    var errorMessage: String?

    private let service = ProfileService()
    private var saveTask: Task<Void, Never>?
    private(set) var currentUserId: UUID?

    func load(for user: User) async {
        if currentUserId == user.id { return }

        currentUserId = user.id
        isLoading = true
        defer { isLoading = false }

        do {
            if let remote = try await service.fetch(userId: user.id) {
                profile = remote
            } else {
                var seeded = UserProfileData()
                if let email = user.email {
                    seeded.email = email
                }
                profile = seeded
                try await service.upsert(seeded, userId: user.id)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearOnSignOut() {
        saveTask?.cancel()
        saveTask = nil
        currentUserId = nil
        profile = UserProfileData()
    }

    func saveProfile() {
        guard !isLoading else { return }
        guard let userId = currentUserId else { return }

        saveTask?.cancel()
        let snapshot = profile
        saveTask = Task { [service] in
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            do {
                try await service.upsert(snapshot, userId: userId)
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
