//
//  HomeViewModel.swift
//  HomeScreen
//

import SwiftUI
import Supabase
import Auth

@MainActor
@Observable
final class HomeViewModel {
    var searchText = ""
    var groups: [CardGroup] = []
    var showingNewGroupSheet = false
    var selectedGroup: CardGroup?
    var selectedProfile: ProfileCard?
    var groupBeingEdited: CardGroup?
    var groupPendingDeletion: CardGroup?
    var isLoading = false
    var errorMessage: String?

    private let service = GroupService()
    private(set) var currentUserId: UUID?

    func load(for user: User) async {
        if currentUserId == user.id { return }

        currentUserId = user.id
        isLoading = true
        defer { isLoading = false }

        do {
            groups = try await service.fetchAll(userId: user.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearOnSignOut() {
        currentUserId = nil
        groups = []
        selectedGroup = nil
        selectedProfile = nil
        searchText = ""
    }

    func createGroup(
        name: String,
        description: String?,
        eventDate: Date?,
        wallpaperData: Data?,
        members: [GroupMember] = []
    ) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let trimmedDescription = description?.trimmingCharacters(in: .whitespaces)
        let group = CardGroup(
            name: trimmedName,
            descriptionText: trimmedDescription?.isEmpty == false ? trimmedDescription : nil,
            eventDate: eventDate,
            wallpaperData: wallpaperData,
            members: members
        )
        groups.append(group)
        upsertRemote(group)
    }

    @discardableResult
    func addMembers(_ newMembers: [GroupMember], toGroupId groupId: UUID) -> Int {
        guard let idx = groups.firstIndex(where: { $0.id == groupId }) else { return 0 }
        var existingNames = Set(groups[idx].members.map { $0.name.lowercased() })
        var added = 0
        for member in newMembers where !existingNames.contains(member.name.lowercased()) {
            groups[idx].members.append(member)
            existingNames.insert(member.name.lowercased())
            added += 1
        }
        if added > 0 {
            upsertRemote(groups[idx])
        }
        return added
    }

    func prepareNewGroup() {
        showingNewGroupSheet = true
    }

    func updateGroup(
        id: UUID,
        name: String,
        description: String?,
        eventDate: Date?,
        wallpaperData: Data?
    ) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        guard let idx = groups.firstIndex(where: { $0.id == id }) else { return }

        let trimmedDescription = description?.trimmingCharacters(in: .whitespaces)
        groups[idx].name = trimmedName
        groups[idx].descriptionText = (trimmedDescription?.isEmpty == false) ? trimmedDescription : nil
        groups[idx].eventDate = eventDate
        groups[idx].wallpaperData = wallpaperData

        if selectedGroup?.id == id { selectedGroup = groups[idx] }

        upsertRemote(groups[idx])
    }

    func deleteGroup(id: UUID) {
        guard let idx = groups.firstIndex(where: { $0.id == id }) else { return }
        let removed = groups.remove(at: idx)
        if selectedGroup?.id == removed.id { selectedGroup = nil }
        if groupBeingEdited?.id == removed.id { groupBeingEdited = nil }
        deleteRemote(removed.id)
    }

    private func upsertRemote(_ group: CardGroup) {
        guard let userId = currentUserId else { return }
        Task { [service] in
            do {
                try await service.upsert(group, userId: userId)
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func deleteRemote(_ id: UUID) {
        guard let userId = currentUserId else { return }
        Task { [service] in
            do {
                try await service.delete(id: id, userId: userId)
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
