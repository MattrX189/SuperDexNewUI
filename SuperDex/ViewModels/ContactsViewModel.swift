//
//  ContactsViewModel.swift
//  SuperDex
//

import SwiftUI
import Supabase
import Auth

@MainActor
@Observable
final class ContactsViewModel {
    var contacts: [Contact] = []
    var isLoading = false
    var errorMessage: String?

    private let service = ContactService()
    private(set) var currentUserId: UUID?

    func load(for user: User) async {
        if currentUserId == user.id { return }

        currentUserId = user.id
        isLoading = true
        defer { isLoading = false }

        do {
            contacts = try await service.fetchAll(userId: user.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearOnSignOut() {
        currentUserId = nil
        contacts = []
    }

    @discardableResult
    func add(_ contact: Contact) async -> Bool {
        guard let userId = currentUserId else { return false }
        do {
            try await service.upsert(contact, userId: userId)
            contacts.append(contact)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
